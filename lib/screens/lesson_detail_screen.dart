import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/tts_service.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _currentQuizIndex = 0;
  int? _selectedQuizAnswer;
  bool _quizSubmitted = false;
  int _contentIndex = 0;
  bool _studyMode = false; // sentence-by-sentence mode
  double _localTtsRate = 0.7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final provider = context.read<AppProvider>();
    _localTtsRate = provider.ttsRate;
    TtsService.setRate(_localTtsRate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.skillColor(widget.lesson.skill);
    final catColor = AppTheme.getCategoryColor(widget.lesson.category);

    if (_studyMode) {
      return _buildStudyMode(color);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white70),
                  ),
                  Expanded(
                    child: Text(
                      widget.lesson.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppTheme.skillIcon(widget.lesson.skill),
                            color: color, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.lesson.level}\uae09',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // TTS Speed Control
            _buildTtsControl(color),
            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: AppTheme.cardBorder.withValues(alpha: 0.3)),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: color,
                indicatorWeight: 2.5,
                labelColor: color,
                unselectedLabelColor: Colors.white38,
                labelStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                      icon: Icon(Icons.article_rounded, size: 16),
                      text: '\ud559\uc2b5'),
                  Tab(
                      icon: Icon(Icons.translate_rounded, size: 16),
                      text: '\uc5b4\ud718'),
                  Tab(
                      icon: Icon(Icons.quiz_rounded, size: 16),
                      text: '\ud035\uc988'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildContentTab(color),
                  _buildVocabTab(color),
                  _buildQuizTab(color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTtsControl(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.speed_rounded, color: Colors.white38, size: 16),
          const SizedBox(width: 6),
          Text('\ubc1c\ud654 \uc18d\ub3c4',
              style: TextStyle(color: Colors.white38, fontSize: 10)),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.15),
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _localTtsRate,
                min: 0.3,
                max: 1.5,
                divisions: 12,
                onChanged: (v) {
                  setState(() => _localTtsRate = v);
                  TtsService.setRate(v);
                  context.read<AppProvider>().setTtsRate(v);
                },
              ),
            ),
          ),
          Text(
            '${_localTtsRate.toStringAsFixed(1)}x',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _studyMode = true),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.repeat_rounded, color: color, size: 14),
                  const SizedBox(width: 4),
                  Text('\ubc18\ubcf5',
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyMode(Color color) {
    final contents = widget.lesson.content;
    if (contents.isEmpty) {
      return Scaffold(
        body: Center(
            child: Text('\ub0b4\uc6a9\uc774 \uc5c6\uc2b5\ub2c8\ub2e4',
                style: TextStyle(color: Colors.white54))),
      );
    }
    final current = contents[_contentIndex % contents.length];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _studyMode = false),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    '\ubc18\ubcf5 \uc5f0\uc2b5 ${_contentIndex + 1}/${contents.length}',
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: (_contentIndex + 1) / contents.length,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    current.korean,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      current.nepali,
                      style: TextStyle(
                          color: color, fontSize: 18, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // TTS Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleButton(
                    Icons.replay_rounded, '\ub2e4\uc2dc', color,
                    () => TtsService.speak(current.korean)),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => TtsService.speak(current.korean),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.volume_up_rounded,
                        color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(width: 20),
                _buildCircleButton(
                    Icons.slow_motion_video_rounded, '\ub290\ub9ac\uac8c', color,
                    () {
                  TtsService.setRate(0.4);
                  TtsService.speak(current.korean);
                  Future.delayed(const Duration(seconds: 3), () {
                    TtsService.setRate(_localTtsRate);
                  });
                }),
              ],
            ),
            const Spacer(),
            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _contentIndex > 0
                          ? () => setState(() => _contentIndex--)
                          : null,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('\uc774\uc804'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color.withValues(alpha: 0.3)),
                        foregroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _contentIndex < contents.length - 1
                          ? () => setState(() => _contentIndex++)
                          : () => setState(() => _studyMode = false),
                      icon: Icon(
                          _contentIndex < contents.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.check_rounded,
                          size: 18),
                      label: Text(_contentIndex < contents.length - 1
                          ? '\ub2e4\uc74c'
                          : '\uc644\ub8cc'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: color, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildContentTab(Color color) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Lesson description header
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(AppTheme.skillIcon(widget.lesson.skill),
                  color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.lesson.description,
                        style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.getCategoryColor(
                                    widget.lesson.category)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppTheme.categoryNamesKr[
                                    widget.lesson.category] ??
                                widget.lesson.category,
                            style: TextStyle(
                                color: AppTheme.getCategoryColor(
                                    widget.lesson.category),
                                fontSize: 9,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content items
        ...widget.lesson.content.asMap().entries.map((entry) {
          final i = entry.key;
          final content = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: color.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                            child: Text('${i + 1}',
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold))),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () =>
                            TtsService.speak(content.korean),
                        icon: Icon(Icons.volume_up_rounded,
                            color: color, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.korean,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            margin: const EdgeInsets.only(
                                right: 6, top: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text('NP',
                                style: TextStyle(
                                    color: Color(0xFFE53935),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text(
                              content.nepali,
                              style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        // Complete button
        ElevatedButton.icon(
          onPressed: () {
            context.read<AppProvider>().completeLesson(widget.lesson.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    '\ud559\uc2b5 \uc644\ub8cc! +10 XP | \u092a\u093e\u0920 \u092a\u0942\u0930\u093e! +10 XP'),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          icon: const Icon(Icons.check_circle_rounded, size: 20),
          label: const Text('\ud559\uc2b5 \uc644\ub8cc | \u092a\u0942\u0930\u093e \u092d\u092f\u094b'),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildVocabTab(Color color) {
    final provider = context.watch<AppProvider>();
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        ...widget.lesson.vocabulary.map((vocab) {
          final isBookmarked =
              provider.bookmarkedVocab.contains(vocab.korean);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isBookmarked
                      ? AppTheme.gold.withValues(alpha: 0.3)
                      : color.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vocab.korean,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(vocab.nepali,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => TtsService.speak(vocab.korean),
                  icon: Icon(Icons.volume_up_rounded,
                      color: color, size: 20),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  onPressed: () =>
                      provider.toggleBookmarkVocab(vocab.korean),
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color:
                        isBookmarked ? AppTheme.gold : Colors.white24,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuizTab(Color color) {
    if (widget.lesson.quiz.isEmpty) {
      return const Center(
          child: Text('\ud035\uc988\uac00 \uc5c6\uc2b5\ub2c8\ub2e4',
              style: TextStyle(color: Colors.white38)));
    }

    final quiz = widget.lesson.quiz[_currentQuizIndex % widget.lesson.quiz.length];

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.quiz_rounded, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text('\ubb38\uc81c | \u092a\u094d\u0930\u0936\u094d\u0928',
                      style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              Text(quiz.question,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5)),
              const SizedBox(height: 16),
              ...quiz.options.asMap().entries.map((entry) {
                final i = entry.key;
                final option = entry.value;
                final isSelected = _selectedQuizAnswer == i;
                final isCorrect = i == quiz.answer;
                Color optionBg = Colors.white.withValues(alpha: 0.03);
                Color borderCol = Colors.white12;
                if (_quizSubmitted) {
                  if (isCorrect) {
                    optionBg = AppTheme.success.withValues(alpha: 0.15);
                    borderCol = AppTheme.success;
                  } else if (isSelected) {
                    optionBg = AppTheme.error.withValues(alpha: 0.15);
                    borderCol = AppTheme.error;
                  }
                } else if (isSelected) {
                  optionBg = color.withValues(alpha: 0.12);
                  borderCol = color;
                }
                return GestureDetector(
                  onTap: _quizSubmitted
                      ? null
                      : () =>
                          setState(() => _selectedQuizAnswer = i),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: optionBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? color.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.03),
                          ),
                          child: Center(
                            child: _quizSubmitted && isCorrect
                                ? const Icon(Icons.check,
                                    color: AppTheme.success, size: 14)
                                : _quizSubmitted &&
                                        isSelected &&
                                        !isCorrect
                                    ? const Icon(Icons.close,
                                        color: AppTheme.error,
                                        size: 14)
                                    : Text('${i + 1}',
                                        style: TextStyle(
                                            color: isSelected
                                                ? color
                                                : Colors.white38,
                                            fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(option,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14))),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              if (!_quizSubmitted)
                ElevatedButton(
                  onPressed: _selectedQuizAnswer != null
                      ? () {
                          setState(() {
                            _quizSubmitted = true;
                          });
                          final score =
                              _selectedQuizAnswer == quiz.answer
                                  ? 100
                                  : 0;
                          context
                              .read<AppProvider>()
                              .saveQuizScore(widget.lesson.id, score);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(double.infinity, 46),
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: const Text('\uc81c\ucd9c | \u092a\u0947\u0936 \u0917\u0930\u094d\u0928\u0941\u0939\u094b\u0938\u094d',
                      style: TextStyle(fontSize: 14)),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedQuizAnswer == quiz.answer
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedQuizAnswer == quiz.answer
                            ? Icons.celebration_rounded
                            : Icons.info_rounded,
                        color: _selectedQuizAnswer == quiz.answer
                            ? AppTheme.success
                            : AppTheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedQuizAnswer == quiz.answer
                              ? '\uc815\ub2f5! +20 XP | \u0938\u0939\u0940 \u091c\u0935\u093e\u092b!'
                              : '\uc624\ub2f5. \ub2e4\uc2dc \ub3c4\uc804\ud558\uc138\uc694! | \u0917\u0932\u0924 \u091c\u0935\u093e\u092b',
                          style: TextStyle(
                            color: _selectedQuizAnswer == quiz.answer
                                ? AppTheme.success
                                : AppTheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
