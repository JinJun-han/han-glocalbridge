import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'lesson_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppTheme.teal)),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  const SizedBox(height: 16),
                  _buildDailyGoalCard(provider),
                  const SizedBox(height: 16),
                  _buildStatsRow(provider),
                  const SizedBox(height: 20),
                  _buildNextLessonCard(context, provider),
                  const SizedBox(height: 20),
                  _buildLevelCards(context, provider),
                  const SizedBox(height: 20),
                  _buildSkillsGrid(provider),
                  const SizedBox(height: 20),
                  _buildInfoBanner(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border:
                      Border.all(color: AppTheme.teal.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.directions_boat_filled_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Glocal Korean',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      '\u0939\u093e\u0928\u0935\u093e \u0913\u0938\u0928 \u0928\u0947\u092a\u093e\u0932\u0940 \u0915\u0930\u094d\u092e\u091a\u093e\u0930\u0940',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              _buildXpBadge(provider),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.factory_rounded,
                    color: Colors.white54, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Hanwha Ocean (\ud55c\ud654\uc624\uc158) \u2022 \uc870\uc120\uc5c5 \ud2b9\ud654',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${provider.streak}\uc77c \uc5f0\uc18d',
                    style: const TextStyle(
                        color: AppTheme.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpBadge(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.gold.withValues(alpha: 0.25),
            AppTheme.gold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: AppTheme.gold, size: 16),
          const SizedBox(width: 3),
          Text(
            '${provider.totalXP}',
            style: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w800,
                fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(AppProvider provider) {
    final progress = provider.dailyGoal > 0
        ? (provider.todayCompleted / provider.dailyGoal).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = provider.dailyGoalReached;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete
            ? AppTheme.success.withValues(alpha: 0.08)
            : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.cardBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 28,
            lineWidth: 5,
            percent: progress,
            center: isComplete
                ? const Icon(Icons.check, color: AppTheme.success, size: 20)
                : Text(
                    '${provider.todayCompleted}',
                    style: const TextStyle(
                        color: AppTheme.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
            progressColor: isComplete ? AppTheme.success : AppTheme.teal,
            backgroundColor: isComplete
                ? AppTheme.success.withValues(alpha: 0.15)
                : AppTheme.teal.withValues(alpha: 0.12),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete
                      ? '\uc624\ub298 \ubaa9\ud45c \ub2ec\uc131! \ud83c\udf89'
                      : '\uc624\ub298\uc758 \ud559\uc2b5 \ubaa9\ud45c',
                  style: TextStyle(
                    color: isComplete ? AppTheme.success : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.todayCompleted} / ${provider.dailyGoal} \ub808\uc2a8 \uc644\ub8cc',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: Colors.deepOrange, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${provider.streak}',
                  style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppProvider provider) {
    final progress = provider.overallProgress;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.cardBorder.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 26,
                  lineWidth: 5,
                  percent: progress.clamp(0.0, 1.0),
                  center: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                  progressColor: AppTheme.teal,
                  backgroundColor: AppTheme.teal.withValues(alpha: 0.12),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('\uc804\uccb4 \uc9c4\ub3c4',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      Text(
                        '${provider.completedLessons.length}/${provider.lessonData?.totalLessons ?? 320}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildMiniStat(
            Icons.check_circle_rounded,
            '${provider.completedLessons.length}',
            '\uc644\ub8cc',
            AppTheme.success),
        const SizedBox(width: 10),
        _buildMiniStat(
            Icons.quiz_rounded,
            '${provider.quizScores.length}',
            '\ud035\uc988',
            AppTheme.listening),
      ],
    );
  }

  Widget _buildMiniStat(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppTheme.cardBorder.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextLessonCard(BuildContext context, AppProvider provider) {
    final nextLesson = provider.nextRecommendedLesson;
    if (nextLesson == null) return const SizedBox.shrink();

    final color = AppTheme.skillColor(nextLesson.skill);
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: nextLesson))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(AppTheme.skillIcon(nextLesson.skill),
                  color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.play_circle_rounded,
                          color: AppTheme.teal, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        '\ub2e4\uc74c \ud559\uc2b5 | \u0905\u0930\u094d\u0915\u094b \u092a\u093e\u0920',
                        style: TextStyle(
                            color: AppTheme.teal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextLesson.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${nextLesson.level}\uae09 ${AppTheme.skillNameKr(nextLesson.skill)} \u2022 ${nextLesson.category}',
                    style: TextStyle(color: color, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCards(BuildContext context, AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\ud559\uc2b5 \ub808\ubca8 | \u0938\u093f\u0915\u093e\u0907 \u0938\u094d\u0924\u0930',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final level = '${index + 3}';
              final progress = provider.getLevelProgress(level);
              final colors = <List<Color>>[
                [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
                [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
                [const Color(0xFFE65100), const Color(0xFFFF7043)],
                [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
              ];
              final levelNames = ['\uae30\ucd08', '\uc911\uae09', '\uace0\uae09', '\uc804\ubb38'];
              final npNames = ['\u0906\u0927\u093e\u0930\u092d\u0942\u0924', '\u092e\u0927\u094d\u092f\u092e', '\u0909\u0928\u094d\u0928\u0924', '\u0935\u093f\u0936\u0947\u0937\u091c\u094d\u091e'];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors[index],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors[index][0].withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$level\uae09',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(levelNames[index],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text(npNames[index],
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9)),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 3,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsGrid(AppProvider provider) {
    final skills = ['listening', 'reading', 'speaking', 'writing'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            '\uc601\uc5ed\ubcc4 \ud559\uc2b5 | \u0915\u094d\u0937\u0947\u0924\u094d\u0930 \u0905\u0928\u0941\u0938\u093e\u0930',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: skills.map((skill) {
            double totalProg = 0;
            for (var level in ['3', '4', '5', '6']) {
              totalProg += provider.getSkillProgress(level, skill);
            }
            totalProg /= 4;
            final color = AppTheme.skillColor(skill);
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(AppTheme.skillIcon(skill), color: color, size: 20),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppTheme.skillNameKr(skill),
                              style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          Text(AppTheme.skillNameNp(skill),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(totalProg * 100).toInt()}%',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: totalProg.clamp(0.0, 1.0),
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(color),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 3,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.teal.withValues(alpha: 0.08),
            AppTheme.darkBlue.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.15)),
      ),
      child: const Column(
        children: [
          Icon(Icons.school_rounded, color: AppTheme.teal, size: 28),
          SizedBox(height: 6),
          Text(
            '\uc0ac\ud68c\ud1b5\ud569\ud504\ub85c\uadf8\ub7a8 1\ud0c0 \uac15\uc0ac\uc758 \uac15\uc758',
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
          Text(
            '\u0938\u092e\u093e\u091c \u090f\u0915\u0940\u0915\u0930\u0923 \u0915\u093e\u0930\u094d\u092f\u0915\u094d\u0930\u092e \u0936\u0940\u0930\u094d\u0937 \u092a\u094d\u0930\u0936\u093f\u0915\u094d\u0937\u0915',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
          SizedBox(height: 6),
          Text(
            'Developed by Elim G Mission | \uc5d8\ub9bcG\uc120\uad50\ud68c',
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
