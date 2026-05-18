import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/data/profile_provider.dart';

class PlacementQuestion {
  final String id;
  final String type; // "mcq", "writing", "speaking"
  final String skill; // "grammar", "vocabulary", "writing", "speaking"
  final String concept; // The "idea of the question" shown to the user
  final String text;
  final List<String> options;
  final String correctAnswer;

  PlacementQuestion({
    required this.id,
    required this.type,
    required this.skill,
    required this.concept,
    required this.text,
    required this.options,
    required this.correctAnswer,
  });

  factory PlacementQuestion.fromJson(Map<String, dynamic> json) {
    return PlacementQuestion(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'mcq',
      skill: json['skill']?.toString() ?? 'grammar',
      concept: json['concept']?.toString() ?? 'Grammar Practice',
      text: json['text']?.toString() ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer']?.toString() ?? '',
    );
  }
}

class PlacementAnswer {
  final String questionId;
  final String type;
  final String skill;
  final String text;
  final String correctAnswer;
  final String userAnswer;

  PlacementAnswer({
    required this.questionId,
    required this.type,
    required this.skill,
    required this.text,
    required this.correctAnswer,
    required this.userAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'type': type,
      'skill': skill,
      'text': text,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
    };
  }
}

class PlacementState {
  final List<PlacementQuestion> questions;
  final int currentQuestionIndex;
  final List<PlacementAnswer> answers;
  final String estimatedLevel;
  final int score;
  final String feedback;
  final bool isLoading;
  final bool isFinished;
  final bool hasStarted;

  PlacementState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.answers = const [],
    this.estimatedLevel = 'A1',
    this.score = 0,
    this.feedback = '',
    this.isLoading = false,
    this.isFinished = false,
    this.hasStarted = false,
  });

  PlacementState copyWith({
    List<PlacementQuestion>? questions,
    int? currentQuestionIndex,
    List<PlacementAnswer>? answers,
    String? estimatedLevel,
    int? score,
    String? feedback,
    bool? isLoading,
    bool? isFinished,
    bool? hasStarted,
  }) {
    return PlacementState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      estimatedLevel: estimatedLevel ?? this.estimatedLevel,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
      hasStarted: hasStarted ?? this.hasStarted,
    );
  }
}

final placementProvider = StateNotifierProvider<PlacementNotifier, PlacementState>((ref) {
  return PlacementNotifier(ref);
});

class PlacementNotifier extends StateNotifier<PlacementState> {
  final Ref _ref;

  PlacementNotifier(this._ref) : super(PlacementState());

  // Starts the test and fetches all questions in one swift request!
  Future<void> startTest() async {
    state = state.copyWith(isLoading: true, hasStarted: true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'generate-placement-question',
      );

      final List<dynamic> list = response.data is List ? response.data : [response.data];
      final questions = list.map((q) => PlacementQuestion.fromJson(q)).toList();

      state = state.copyWith(
        questions: questions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void submitAnswer(String questionId, String answerText) {
    if (state.questions.isEmpty) return;

    final currentQuestion = state.questions[state.currentQuestionIndex];
    final answer = PlacementAnswer(
      questionId: questionId,
      type: currentQuestion.type,
      skill: currentQuestion.skill,
      text: currentQuestion.text,
      correctAnswer: currentQuestion.correctAnswer,
      userAnswer: answerText,
    );

    final newAnswers = [...state.answers, answer];
    final isLast = state.currentQuestionIndex + 1 >= state.questions.length;

    if (isLast) {
      state = state.copyWith(
        answers: newAnswers,
        isLoading: true,
      );
      _gradeAllAnswers(newAnswers);
    } else {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        answers: newAnswers,
      );
    }
  }

  Future<void> _gradeAllAnswers(List<PlacementAnswer> allAnswers) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'grade-placement-answer',
        body: {
          'answers': allAnswers.map((a) => a.toJson()).toList(),
        },
      );

      final result = response.data;
      final finalLevel = result['estimated_level'] ?? 'A1';
      final score = result['score'] ?? 0;
      final feedback = result['feedback'] ?? 'Exam grading complete!';

      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      // Update student profile level
      await Supabase.instance.client.from('profiles').update({
        'level': finalLevel,
      }).eq('id', userId);

      // Save placement exam result
      await Supabase.instance.client.from('placement_results').insert({
        'user_id': userId,
        'final_level': finalLevel,
        'total_score': score,
        'answers': allAnswers.map((a) => a.toJson()).toList(),
      });

      // Trigger curriculum generation for the newly diagnosed level
      try {
        await Supabase.instance.client.functions.invoke(
          'generate-curriculum',
          body: {'levelId': finalLevel},
        );

        // Find the first lesson of the newly generated curriculum
        final firstLesson = await Supabase.instance.client
            .from('lessons')
            .select('*, modules!inner(*)')
            .eq('modules.level_id', finalLevel)
            .eq('order_index', 0)
            .eq('modules.order_index', 0)
            .maybeSingle();

        if (firstLesson != null) {
          await Supabase.instance.client.from('user_lesson_progress').upsert({
            'user_id': userId,
            'lesson_id': firstLesson['id'],
            'is_unlocked': true,
          });
        }
      } catch (e) {
        print('DEBUG: Curriculum generation failed: $e');
      }

      // Invalidate profiles to automatically update user profile level from unassigned -> diagnosed level
      _ref.invalidate(profileProvider);

      state = state.copyWith(
        estimatedLevel: finalLevel,
        score: score,
        feedback: feedback,
        isFinished: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isFinished: true,
        isLoading: false,
      );
    }
  }
}
