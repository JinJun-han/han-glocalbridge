class LessonData {
  final String version;
  final int totalLessons;
  final List<String> levels;
  final List<String> skills;
  final List<Lesson> lessons;

  LessonData({
    required this.version,
    required this.totalLessons,
    required this.levels,
    required this.skills,
    required this.lessons,
  });

  factory LessonData.fromJson(Map<String, dynamic> json) {
    return LessonData(
      version: json['version'] ?? '1.0',
      totalLessons: json['total_lessons'] ?? 0,
      levels: List<String>.from(json['levels'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      lessons: (json['lessons'] as List? ?? [])
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Lesson {
  final String id;
  final String level;
  final String skill;
  final String title;
  final String description;
  final String category;
  final List<LessonContent> content;
  final List<Vocabulary> vocabulary;
  final List<Quiz> quiz;

  Lesson({
    required this.id,
    required this.level,
    required this.skill,
    required this.title,
    required this.description,
    required this.category,
    required this.content,
    required this.vocabulary,
    required this.quiz,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      level: json['level'] ?? '',
      skill: json['skill'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      content: (json['content'] as List? ?? [])
          .map((e) => LessonContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      vocabulary: (json['vocabulary'] as List? ?? [])
          .map((e) => Vocabulary.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz: (json['quiz'] as List? ?? [])
          .map((e) => Quiz.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonContent {
  final String korean;
  final String nepali;

  LessonContent({required this.korean, required this.nepali});

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      korean: json['korean'] ?? '',
      nepali: json['nepali'] ?? '',
    );
  }
}

class Vocabulary {
  final String korean;
  final String nepali;

  Vocabulary({required this.korean, required this.nepali});

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      korean: json['korean'] ?? '',
      nepali: json['nepali'] ?? '',
    );
  }
}

class Quiz {
  final String question;
  final List<String> options;
  final int answer;

  Quiz({required this.question, required this.options, required this.answer});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? 0,
    );
  }
}
