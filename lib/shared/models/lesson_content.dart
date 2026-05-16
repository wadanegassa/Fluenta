class LessonContent {
  final String grammarExplanation;
  final String readingPassage;
  final String listeningTranscript;
  final String writingPrompt;
  final String speakingPrompt;
  final List<VocabularyItem> vocabularyList;
  final List<ReadingQuestion> readingQuestions;
  final List<ListeningExercise> listeningExercises;

  LessonContent({
    required this.grammarExplanation,
    required this.readingPassage,
    required this.listeningTranscript,
    required this.writingPrompt,
    required this.speakingPrompt,
    required this.vocabularyList,
    required this.readingQuestions,
    required this.listeningExercises,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      grammarExplanation: json['grammar_explanation'] ?? '',
      readingPassage: json['reading_passage'] ?? '',
      listeningTranscript: json['listening_transcript'] ?? '',
      writingPrompt: json['writing_prompt'] ?? '',
      speakingPrompt: json['speaking_prompt'] ?? '',
      vocabularyList: (json['vocabulary_list'] as List? ?? [])
          .map((v) => VocabularyItem.fromJson(v))
          .toList(),
      readingQuestions: (json['reading_questions'] as List? ?? [])
          .map((q) => ReadingQuestion.fromJson(q))
          .toList(),
      listeningExercises: (json['listening_exercises'] as List? ?? [])
          .map((e) => ListeningExercise.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grammar_explanation': grammarExplanation,
      'reading_passage': readingPassage,
      'listening_transcript': listeningTranscript,
      'writing_prompt': writingPrompt,
      'speaking_prompt': speakingPrompt,
      'vocabulary_list': vocabularyList.map((v) => v.toJson()).toList(),
      'reading_questions': readingQuestions.map((q) => q.toJson()).toList(),
      'listening_exercises': listeningExercises.map((e) => e.toJson()).toList(),
    };
  }
}

class VocabularyItem {
  final String word;
  final String definition;
  final String example;

  VocabularyItem({
    required this.word,
    required this.definition,
    required this.example,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'example': example,
    };
  }
}

class ReadingQuestion {
  final String id;
  final String question;
  final String type;
  final List<String>? options;
  final String? answer;
  final String? answerKey;

  ReadingQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.answer,
    this.answerKey,
  });

  factory ReadingQuestion.fromJson(Map<String, dynamic> json) {
    return ReadingQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      type: json['type'] ?? '',
      options: (json['options'] as List?)?.map((o) => o.toString()).toList(),
      answer: json['answer'],
      answerKey: json['answer_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'answer': answer,
      'answer_key': answerKey,
    };
  }
}

class ListeningExercise {
  final String id;
  final String sentenceWithBlank;
  final String answer;

  ListeningExercise({
    required this.id,
    required this.sentenceWithBlank,
    required this.answer,
  });

  factory ListeningExercise.fromJson(Map<String, dynamic> json) {
    return ListeningExercise(
      id: json['id'] ?? '',
      sentenceWithBlank: json['sentence_with_blank'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sentence_with_blank': sentenceWithBlank,
      'answer': answer,
    };
  }
}
