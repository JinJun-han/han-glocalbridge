import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/lesson_model.dart';

class AppProvider extends ChangeNotifier {
  LessonData? _lessonData;
  Map<String, dynamic>? _introData;
  String _selectedLevel = '3';
  String _selectedSkill = 'listening';
  Set<String> _completedLessons = {};
  Map<String, int> _quizScores = {};
  Set<String> _bookmarkedVocab = {};
  int _streak = 0;
  int _totalXP = 0;
  bool _isLoading = true;
  int _dailyGoal = 3;
  int _todayCompleted = 0;
  String _lastStudyDate = '';
  double _ttsRate = 0.7;

  // Getters
  LessonData? get lessonData => _lessonData;
  Map<String, dynamic>? get introData => _introData;
  String get selectedLevel => _selectedLevel;
  String get selectedSkill => _selectedSkill;
  Set<String> get completedLessons => _completedLessons;
  Map<String, int> get quizScores => _quizScores;
  Set<String> get bookmarkedVocab => _bookmarkedVocab;
  int get streak => _streak;
  int get totalXP => _totalXP;
  bool get isLoading => _isLoading;
  int get dailyGoal => _dailyGoal;
  int get todayCompleted => _todayCompleted;
  String get lastStudyDate => _lastStudyDate;
  double get ttsRate => _ttsRate;

  // Computed
  List<Lesson> get currentLessons {
    if (_lessonData == null) return [];
    return _lessonData!.lessons
        .where((l) => l.level == _selectedLevel && l.skill == _selectedSkill)
        .toList();
  }

  List<Lesson> getLessonsByLevel(String level) {
    if (_lessonData == null) return [];
    return _lessonData!.lessons.where((l) => l.level == level).toList();
  }

  List<Lesson> getLessonsByLevelAndSkill(String level, String skill) {
    if (_lessonData == null) return [];
    return _lessonData!.lessons
        .where((l) => l.level == level && l.skill == skill)
        .toList();
  }

  List<Lesson> getLessonsByCategory(String category) {
    if (_lessonData == null) return [];
    return _lessonData!.lessons.where((l) => l.category == category).toList();
  }

  Set<String> get allCategories {
    if (_lessonData == null) return {};
    return _lessonData!.lessons.map((l) => l.category).toSet();
  }

  List<Vocabulary> get allVocabulary {
    if (_lessonData == null) return [];
    final allVocab = <Vocabulary>[];
    for (final lesson in _lessonData!.lessons) {
      allVocab.addAll(lesson.vocabulary);
    }
    return allVocab;
  }

  List<Vocabulary> get bookmarkedVocabulary {
    if (_lessonData == null) return [];
    final all = allVocabulary;
    return all.where((v) => _bookmarkedVocab.contains(v.korean)).toList();
  }

  double getLevelProgress(String level) {
    final levelLessons = getLessonsByLevel(level);
    if (levelLessons.isEmpty) return 0.0;
    final completed =
        levelLessons.where((l) => _completedLessons.contains(l.id)).length;
    return completed / levelLessons.length;
  }

  double getSkillProgress(String level, String skill) {
    final lessons = getLessonsByLevelAndSkill(level, skill);
    if (lessons.isEmpty) return 0.0;
    final completed =
        lessons.where((l) => _completedLessons.contains(l.id)).length;
    return completed / lessons.length;
  }

  double get overallProgress {
    if (_lessonData == null || _lessonData!.lessons.isEmpty) return 0.0;
    return _completedLessons.length / _lessonData!.lessons.length;
  }

  bool get dailyGoalReached => _todayCompleted >= _dailyGoal;

  Lesson? get nextRecommendedLesson {
    if (_lessonData == null) return null;
    for (final lesson in _lessonData!.lessons) {
      if (!_completedLessons.contains(lesson.id)) return lesson;
    }
    return null;
  }

  List<Lesson> getRecentlyCompleted({int limit = 5}) {
    if (_lessonData == null) return [];
    return _lessonData!.lessons
        .where((l) => _completedLessons.contains(l.id))
        .take(limit)
        .toList();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final lessonStr =
          await rootBundle.loadString('assets/data/lessons_data.json');
      final lessonJson = json.decode(lessonStr) as Map<String, dynamic>;
      _lessonData = LessonData.fromJson(lessonJson);

      final introStr =
          await rootBundle.loadString('assets/data/introduction_data.json');
      _introData = json.decode(introStr) as Map<String, dynamic>;

      _loadProgress();
      _checkDailyReset();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadProgress() {
    final box = Hive.box('progress');
    final completed = box.get('completedLessons', defaultValue: <String>[]);
    _completedLessons = Set<String>.from(
        completed is List ? completed.cast<String>() : <String>[]);
    _streak = box.get('streak', defaultValue: 0) as int;
    _totalXP = box.get('totalXP', defaultValue: 0) as int;
    _dailyGoal = box.get('dailyGoal', defaultValue: 3) as int;
    _todayCompleted = box.get('todayCompleted', defaultValue: 0) as int;
    _lastStudyDate = box.get('lastStudyDate', defaultValue: '') as String;
    _ttsRate = (box.get('ttsRate', defaultValue: 0.7) as num).toDouble();
    final bookmarks = box.get('bookmarkedVocab', defaultValue: <String>[]);
    _bookmarkedVocab = Set<String>.from(
        bookmarks is List ? bookmarks.cast<String>() : <String>[]);
    final scores = box.get('quizScores', defaultValue: <String, dynamic>{});
    if (scores is Map) {
      _quizScores = Map<String, int>.from(
          scores.map((key, value) => MapEntry(key.toString(), value as int)));
    }
  }

  void _checkDailyReset() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastStudyDate != today) {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);
      if (_lastStudyDate != yesterday && _lastStudyDate.isNotEmpty) {
        _streak = 0; // Streak broken
      }
      _todayCompleted = 0;
      _lastStudyDate = today;
      _saveProgress();
    }
  }

  void _saveProgress() {
    final box = Hive.box('progress');
    box.put('completedLessons', _completedLessons.toList());
    box.put('streak', _streak);
    box.put('totalXP', _totalXP);
    box.put('dailyGoal', _dailyGoal);
    box.put('todayCompleted', _todayCompleted);
    box.put('lastStudyDate', _lastStudyDate);
    box.put('ttsRate', _ttsRate);
    box.put('quizScores', _quizScores);
    box.put('bookmarkedVocab', _bookmarkedVocab.toList());
  }

  void setLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  void setSkill(String skill) {
    _selectedSkill = skill;
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    _dailyGoal = goal.clamp(1, 20);
    _saveProgress();
    notifyListeners();
  }

  void setTtsRate(double rate) {
    _ttsRate = rate.clamp(0.3, 1.5);
    _saveProgress();
    notifyListeners();
  }

  void toggleBookmarkVocab(String korean) {
    if (_bookmarkedVocab.contains(korean)) {
      _bookmarkedVocab.remove(korean);
    } else {
      _bookmarkedVocab.add(korean);
    }
    _saveProgress();
    notifyListeners();
  }

  void completeLesson(String lessonId) {
    if (!_completedLessons.contains(lessonId)) {
      _completedLessons.add(lessonId);
      _totalXP += 10;
      _todayCompleted++;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (_lastStudyDate != today) {
        _streak++;
        _lastStudyDate = today;
      } else if (_todayCompleted == 1) {
        _streak++;
      }
      _saveProgress();
      notifyListeners();
    }
  }

  void saveQuizScore(String lessonId, int score) {
    _quizScores[lessonId] = score;
    if (score >= 80) _totalXP += 20;
    _saveProgress();
    notifyListeners();
  }

  void incrementStreak() {
    _streak++;
    _totalXP += 5;
    _saveProgress();
    notifyListeners();
  }

  void resetProgress() {
    _completedLessons.clear();
    _quizScores.clear();
    _bookmarkedVocab.clear();
    _streak = 0;
    _totalXP = 0;
    _todayCompleted = 0;
    _saveProgress();
    notifyListeners();
  }
}
