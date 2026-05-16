import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/lesson_content.dart';

class LessonState {
  final int currentSection; // 0: Reading, 1: Listening, 2: Writing, 3: Speaking
  final LessonContent? content;
  final bool isLoading;
  final Map<String, dynamic> answers;

  LessonState({
    this.currentSection = 0,
    this.content,
    this.isLoading = false,
    this.answers = const {},
  });

  LessonState copyWith({
    int? currentSection,
    LessonContent? content,
    bool? isLoading,
    Map<String, dynamic>? answers,
  }) {
    return LessonState(
      currentSection: currentSection ?? this.currentSection,
      content: content ?? this.content,
      isLoading: isLoading ?? this.isLoading,
      answers: answers ?? this.answers,
    );
  }
}

final lessonNotifierProvider = StateNotifierProvider.family<LessonNotifier, LessonState, String>((ref, lessonId) {
  return LessonNotifier(lessonId);
});

class LessonNotifier extends StateNotifier<LessonState> {
  final String lessonId;

  LessonNotifier(this.lessonId) : super(LessonState()) {
    _loadContent();
  }

  Future<void> _loadContent() async {
    state = state.copyWith(isLoading: true);
    
    // In a real app, fetch from Supabase or generate via Edge Function
    // Mocking content for now
    await Future.delayed(const Duration(seconds: 1));
    
    final mockContent = LessonContent(
      grammarExplanation: "The Present Simple is used to talk about facts, habits, and routines. For example: 'I drink coffee every morning.' To form the negative, use 'do not' or 'does not'. Remember to add '-s' to the verb for he/she/it.",
      readingPassage: "My name is Sarah and I live in London. Every morning, I wake up at 7 AM. I usually have tea and toast for breakfast. After that, I take the bus to my office. I work as a graphic designer. I love my job because it is very creative. In the evening, I sometimes meet my friends at a local cafe. We talk about our day and enjoy the atmosphere.",
      listeningTranscript: "Alex: Hi Sarah, what do you usually do on weekends?\nSarah: Well, I usually go to the park on Saturdays. I like jogging in the morning. Then, I visit my parents for lunch.\nAlex: That sounds nice. Do you go out in the evening?\nSarah: Sometimes. I occasionally go to the cinema if there's a good movie.",
      writingPrompt: "Write 3-4 sentences about your typical morning routine. Use the Present Simple tense.",
      speakingPrompt: "Tell me about your favorite hobby and why you enjoy it. Speak for about 30-45 seconds.",
      vocabularyList: [
        VocabularyItem(word: 'Routine', definition: 'A sequence of actions regularly followed.', example: 'My morning routine starts with yoga.'),
        VocabularyItem(word: 'Creative', definition: 'Involving the use of the imagination or original ideas.', example: 'She has a very creative mind.'),
        VocabularyItem(word: 'Atmosphere', definition: 'The pervading tone or mood of a place.', example: 'The cafe has a cozy atmosphere.'),
      ],
      readingQuestions: [
        ReadingQuestion(id: 'r1', question: "Where does Sarah live?", type: 'mcq', options: ["Paris", "London", "New York", "Berlin"], answer: "London"),
        ReadingQuestion(id: 'r2', question: "What does she have for breakfast?", type: 'mcq', options: ["Coffee and eggs", "Tea and toast", "Cereal", "Fruit"], answer: "Tea and toast"),
      ],
      listeningExercises: [
        ListeningExercise(id: 'l1', sentenceWithBlank: "Sarah usually goes to the _____ on Saturdays.", answer: "park"),
        ListeningExercise(id: 'l2', sentenceWithBlank: "She likes _____ in the morning.", answer: "jogging"),
      ],
    );

    state = state.copyWith(content: mockContent, isLoading: false);
  }

  void setSection(int section) {
    state = state.copyWith(currentSection: section);
  }

  void saveAnswer(String id, dynamic value) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[id] = value;
    state = state.copyWith(answers: newAnswers);
  }
}
