import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/lesson_model.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLevel = '3';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Custom header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: AppTheme.teal, size: 24),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\ud559\uc2b5 | \u092a\u093e\u0920\u0939\u0930\u0942',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Category filter
                      GestureDetector(
                        onTap: () => _showCategoryFilter(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.teal.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.filter_list_rounded,
                                  color: AppTheme.teal, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCategory == 'all'
                                    ? '\uc804\uccb4'
                                    : AppTheme.categoryNamesKr[
                                            _selectedCategory] ??
                                        _selectedCategory,
                                style: const TextStyle(
                                    color: AppTheme.teal, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Level selector
                _buildLevelSelector(provider),
                const SizedBox(height: 4),
                // Skill tabs
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: AppTheme.cardBorder.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.teal,
                    indicatorWeight: 2.5,
                    labelColor: AppTheme.teal,
                    unselectedLabelColor: Colors.white38,
                    labelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(
                          icon: Icon(Icons.headphones_rounded, size: 18),
                          text: '\ub4e3\uae30'),
                      Tab(
                          icon: Icon(Icons.auto_stories_rounded, size: 18),
                          text: '\uc77d\uae30'),
                      Tab(
                          icon: Icon(Icons.record_voice_over_rounded, size: 18),
                          text: '\ub9d0\ud558\uae30'),
                      Tab(
                          icon: Icon(Icons.edit_note_rounded, size: 18),
                          text: '\uc4f0\uae30'),
                    ],
                  ),
                ),
                // Lesson list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLessonList(provider, 'listening'),
                      _buildLessonList(provider, 'reading'),
                      _buildLessonList(provider, 'speaking'),
                      _buildLessonList(provider, 'writing'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelSelector(AppProvider provider) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final level = '${index + 3}';
          final isSelected = _selectedLevel == level;
          final colors = [
            const Color(0xFF1565C0),
            const Color(0xFF2E7D32),
            const Color(0xFFE65100),
            const Color(0xFF6A1B9A),
          ];
          final names = ['\uae30\ucd08', '\uc911\uae09', '\uace0\uae09', '\uc804\ubb38'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedLevel = level);
              provider.setLevel(level);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors[index].withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? colors[index] : Colors.white24,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$level\uae09 ${names[index]}',
                  style: TextStyle(
                    color: isSelected ? colors[index] : Colors.white38,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, AppProvider provider) {
    final categories = provider.allCategories.toList()..sort();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '\uce74\ud14c\uace0\ub9ac \ud544\ud130 | \u0936\u094d\u0930\u0947\u0923\u0940 \u091b\u093e\u0928\u094d\u0928\u0941\u0939\u094b\u0938\u094d',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('all', '\uc804\uccb4', Icons.apps_rounded,
                    AppTheme.teal),
                ...categories.take(12).map((cat) {
                  return _buildCategoryChip(
                    cat,
                    AppTheme.categoryNamesKr[cat] ?? cat,
                    AppTheme.getCategoryIcon(cat),
                    AppTheme.getCategoryColor(cat),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
      String value, String label, IconData icon, Color color) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? color : Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? color : Colors.white54,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonList(AppProvider provider, String skill) {
    var lessons = provider.getLessonsByLevelAndSkill(_selectedLevel, skill);
    if (_selectedCategory != 'all') {
      lessons = lessons.where((l) => l.category == _selectedCategory).toList();
    }
    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppTheme.skillIcon(skill), size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              _selectedCategory != 'all'
                  ? '\ud574\ub2f9 \uce74\ud14c\uace0\ub9ac\uc5d0 \ub808\uc2a8\uc774 \uc5c6\uc2b5\ub2c8\ub2e4'
                  : '\ub808\uc2a8\uc774 \uc5c6\uc2b5\ub2c8\ub2e4',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _buildLessonCard(
            context, provider, lessons[index], index, skill);
      },
    );
  }

  Widget _buildLessonCard(BuildContext context, AppProvider provider,
      Lesson lesson, int index, String skill) {
    final isCompleted = provider.completedLessons.contains(lesson.id);
    final color = AppTheme.skillColor(skill);
    final catColor = AppTheme.getCategoryColor(lesson.category);
    final quizScore = provider.quizScores[lesson.id];

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCompleted
              ? color.withValues(alpha: 0.06)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? color.withValues(alpha: 0.3)
                : AppTheme.cardBorder.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Number / Check
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded, color: color, size: 20)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      color: isCompleted ? color : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppTheme.categoryNamesKr[lesson.category] ??
                              lesson.category,
                          style: TextStyle(
                              color: catColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (quizScore != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.star_rounded,
                            color: AppTheme.gold, size: 12),
                        Text(' $quizScore%',
                            style: TextStyle(
                              color: quizScore >= 80
                                  ? AppTheme.success
                                  : AppTheme.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
