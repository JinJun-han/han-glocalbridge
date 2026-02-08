import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/lesson_model.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String _selectedLevel = '3';
  bool _quizStarted = false;
  List<_QuizItem> _quizItems = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (_quizStarted) {
          if (_currentIndex >= _quizItems.length) {
            return _buildQuizResults(provider);
          }
          return _buildQuizInProgress(provider);
        }
        return _buildQuizHome(provider);
      },
    );
  }

  Widget _buildQuizHome(AppProvider provider) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF006064)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: const Icon(Icons.quiz_rounded,
                          color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '\uc885\ud569 \ud035\uc988 \ub3c4\uc804!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '\u0935\u094d\u092f\u093e\u092a\u0915 \u0915\u094d\u0935\u093f\u091c \u091a\u0941\u0928\u094c\u0924\u0940!',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\ub808\ubca8\ubcc4 10\ubb38\uc81c \ub79c\ub364 \ucd9c\uc81c',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    '\ub808\ubca8 \uc120\ud0dd | \u0938\u094d\u0924\u0930 \u091b\u093e\u0928\u094d\u0928\u0941\u0939\u094b\u0938\u094d',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ...['3', '4', '5', '6'].map((level) {
                final isSelected = _selectedLevel == level;
                final colors = {
                  '3': const Color(0xFF1565C0),
                  '4': const Color(0xFF2E7D32),
                  '5': const Color(0xFFE65100),
                  '6': const Color(0xFF6A1B9A),
                };
                final names = {
                  '3': '\uae30\ucd08 | \u0906\u0927\u093e\u0930\u092d\u0942\u0924',
                  '4': '\uc911\uae09 | \u092e\u0927\u094d\u092f\u092e',
                  '5': '\uace0\uae09 | \u0909\u0928\u094d\u0928\u0924',
                  '6': '\uc804\ubb38 | \u0935\u093f\u0936\u0947\u0937\u091c\u094d\u091e',
                };
                final qCount = provider
                    .getLessonsByLevel(level)
                    .where((l) => l.quiz.isNotEmpty)
                    .length;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors[level]!.withValues(alpha: 0.1)
                          : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? colors[level]!
                            : AppTheme.cardBorder.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors[level]!.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('$level\uae09',
                                style: TextStyle(
                                    color: colors[level],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(names[level]!,
                                  style: TextStyle(
                                      color: isSelected
                                          ? colors[level]
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text('$qCount \ubb38\uc81c \uc900\ube44\ub428',
                                  style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: colors[level], size: 22),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _startQuiz(provider),
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text(
                    '\ud035\uc988 \uc2dc\uc791 | \u0915\u094d\u0935\u093f\u091c \u0938\u0941\u0930\u0941 \u0917\u0930\u094d\u0928\u0941\u0939\u094b\u0938\u094d',
                    style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz(AppProvider provider) {
    final lessons = provider
        .getLessonsByLevel(_selectedLevel)
        .where((l) => l.quiz.isNotEmpty)
        .toList();
    if (lessons.isEmpty) return;
    lessons.shuffle(Random());
    final selected = lessons.take(min(10, lessons.length)).toList();
    _quizItems =
        selected.map((l) => _QuizItem(lesson: l, quiz: l.quiz[0])).toList();
    setState(() {
      _quizStarted = true;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Widget _buildQuizInProgress(AppProvider provider) {
    final item = _quizItems[_currentIndex];
    final progress = (_currentIndex + 1) / _quizItems.length;
    final color = AppTheme.skillColor(item.lesson.skill);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white54),
                    onPressed: () =>
                        setState(() => _quizStarted = false),
                  ),
                  Expanded(
                    child: Text(
                      '\ubb38\uc81c ${_currentIndex + 1} / ${_quizItems.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.teal.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation(AppTheme.teal),
                borderRadius: BorderRadius.circular(4),
                minHeight: 3,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.lesson.level}\uae09 ${AppTheme.skillNameKr(item.lesson.skill)}',
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.quiz.question,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ...item.quiz.options.asMap().entries.map((entry) {
                      final i = entry.key;
                      final option = entry.value;
                      final isSelected = _selectedAnswer == i;
                      final isCorrect = i == item.quiz.answer;
                      Color optBg =
                          Colors.white.withValues(alpha: 0.03);
                      Color borderColor = Colors.white12;
                      if (_answered) {
                        if (isCorrect) {
                          optBg = AppTheme.success
                              .withValues(alpha: 0.15);
                          borderColor = AppTheme.success;
                        } else if (isSelected) {
                          optBg =
                              AppTheme.error.withValues(alpha: 0.15);
                          borderColor = AppTheme.error;
                        }
                      } else if (isSelected) {
                        optBg = color.withValues(alpha: 0.1);
                        borderColor = color;
                      }
                      return GestureDetector(
                        onTap: _answered
                            ? null
                            : () => setState(
                                () => _selectedAnswer = i),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: optBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(option,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14)),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                    if (!_answered)
                      ElevatedButton(
                        onPressed: _selectedAnswer != null
                            ? () {
                                setState(() {
                                  _answered = true;
                                  if (_selectedAnswer ==
                                      item.quiz.answer) {
                                    _score++;
                                  }
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          minimumSize:
                              const Size(double.infinity, 48),
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: 0.05),
                        ),
                        child: const Text(
                            '\ud655\uc778 | \u091c\u093e\u0901\u091a \u0917\u0930\u094d\u0928\u0941\u0939\u094b\u0938\u094d'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex++;
                            _selectedAnswer = null;
                            _answered = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.teal,
                          minimumSize:
                              const Size(double.infinity, 48),
                        ),
                        child: Text(
                          _currentIndex + 1 < _quizItems.length
                              ? '\ub2e4\uc74c \ubb38\uc81c | \u0905\u0930\u094d\u0915\u094b \u092a\u094d\u0930\u0936\u094d\u0928'
                              : '\uacb0\uacfc \ubcf4\uae30 | \u0928\u0924\u093f\u091c\u093e',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResults(AppProvider provider) {
    final percentage = (_score / _quizItems.length * 100).toInt();
    final passed = percentage >= 60;
    if (passed) provider.incrementStreak();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: passed
                          ? [AppTheme.gold, AppTheme.success]
                          : [AppTheme.error, Colors.deepOrange],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (passed ? AppTheme.gold : AppTheme.error)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    passed
                        ? Icons.celebration_rounded
                        : Icons.sentiment_dissatisfied_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  passed
                      ? '\ucd95\ud558\ud569\ub2c8\ub2e4! | \u092c\u0927\u093e\u0908 \u091b!'
                      : '\ub2e4\uc2dc \ub3c4\uc804! | \u092b\u0947\u0930\u093f \u092a\u094d\u0930\u092f\u093e\u0938!',
                  style: TextStyle(
                    color: passed ? AppTheme.gold : AppTheme.error,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (passed ? AppTheme.success : AppTheme.error)
                        .withValues(alpha: 0.1),
                    border: Border.all(
                      color: passed ? AppTheme.success : AppTheme.error,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        color: passed ? AppTheme.success : AppTheme.error,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '$_score / ${_quizItems.length} correct',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _quizStarted = false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.teal),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('\ub3cc\uc544\uac00\uae30',
                            style: TextStyle(color: AppTheme.teal)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _startQuiz(provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.teal,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('\ub2e4\uc2dc \ub3c4\uc804'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizItem {
  final Lesson lesson;
  final Quiz quiz;
  _QuizItem({required this.lesson, required this.quiz});
}
