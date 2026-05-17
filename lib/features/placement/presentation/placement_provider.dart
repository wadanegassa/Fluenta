import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/score_calculator.dart';

class PlacementQuestion {
  final String id;
  final String skill;
  final String text;
  final List<String> options;
  final String correctAnswer;

  PlacementQuestion({
    required this.id,
    required this.skill,
    required this.text,
    required this.options,
    required this.correctAnswer,
  });

  factory PlacementQuestion.fromJson(Map<String, dynamic> json) {
    return PlacementQuestion(
      id: json['id'],
      skill: json['skill'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
    );
  }
}

class PlacementAnswer {
  final String questionId;
  final bool isCorrect;
  final String? userAnswer;
  final int difficulty;

  PlacementAnswer({
    required this.questionId,
    required this.isCorrect,
    this.userAnswer,
    required this.difficulty,
  });
}

class PlacementState {
  final int currentQuestionIndex;
  final int currentDifficulty; // 1-10, starts at 5
  final String estimatedLevel;
  final List<PlacementAnswer> answers;
  final PlacementQuestion? currentQuestion;
  final bool isLoading;
  final bool isFinished;

  PlacementState({
    this.currentQuestionIndex = 0,
    this.currentDifficulty = 5,
    this.estimatedLevel = 'A1',
    this.answers = const [],
    this.currentQuestion,
    this.isLoading = false,
    this.isFinished = false,
  });

  PlacementState copyWith({
    int? currentQuestionIndex,
    int? currentDifficulty,
    String? estimatedLevel,
    List<PlacementAnswer>? answers,
    PlacementQuestion? currentQuestion,
    bool? isLoading,
    bool? isFinished,
  }) {
    return PlacementState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      estimatedLevel: estimatedLevel ?? this.estimatedLevel,
      answers: answers ?? this.answers,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

final placementProvider = StateNotifierProvider<PlacementNotifier, PlacementState>((ref) {
  return PlacementNotifier();
});

class PlacementNotifier extends StateNotifier<PlacementState> {
  PlacementNotifier() : super(PlacementState()) {
    _fetchNextQuestion();
  }

  static const int totalQuestions = 15;

  Future<void> _fetchNextQuestion() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'generate-placement-question',
        body: {
          'difficulty': state.currentDifficulty,
          'excludedIds': state.answers.map((a) => a.questionId).toList(),
        },
      );

      final question = PlacementQuestion.fromJson(response.data);
      state = state.copyWith(
        currentQuestion: question,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void submitAnswer(String questionId, bool isCorrect, {String? userAnswer}) {
    final newAnswers = [...state.answers, PlacementAnswer(
      questionId: questionId,
      isCorrect: isCorrect,
      userAnswer: userAnswer,
      difficulty: state.currentDifficulty,
    )];

    int newDifficulty = state.currentDifficulty;
    if (isCorrect) {
      if (newDifficulty < 10) newDifficulty++;
    } else {
      if (newDifficulty > 1) newDifficulty--;
    }

    final newLevel = ScoreCalculator.levelFromDifficulty(newDifficulty);
    final isFinished = state.currentQuestionIndex + 1 >= totalQuestions;

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      currentDifficulty: newDifficulty,
      estimatedLevel: newLevel,
      answers: newAnswers,
      isFinished: isFinished,
    );

    if (isFinished) {
      _saveResult();
    } else {
      _fetchNextQuestion();
    }
  }

  Future<void> _saveResult() async {
    state = state.copyWith(isLoading: true);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    
    // Update profile level
    await Supabase.instance.client.from('profiles').update({
      'level': state.estimatedLevel,
    }).eq('id', userId);

    // Save placement result
    await Supabase.instance.client.from('placement_results').insert({
      'user_id': userId,
      'final_level': state.estimatedLevel,
      'total_score': state.answers.where((a) => a.isCorrect).length,
      'answers': state.answers.map((a) => {
        'question_id': a.questionId,
        'is_correct': a.isCorrect,
        'user_answer': a.userAnswer,
        'difficulty': a.difficulty,
      }).toList(),
    });

    state = state.copyWith(isLoading: false);
  }
}
