import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'introduction_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  _buildProfileHeader(provider),
                  const SizedBox(height: 16),
                  _buildStatsGrid(provider),
                  const SizedBox(height: 16),
                  _buildDailyGoalSetting(context, provider),
                  const SizedBox(height: 16),
                  _buildLevelProgressList(provider),
                  const SizedBox(height: 16),
                  _buildSkillBars(provider),
                  const SizedBox(height: 16),
                  _buildQuickLinks(context),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildResetButton(context, provider),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(AppProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.teal, width: 2.5),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hanwha Ocean Worker',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const Text(
            '\ud55c\ud654\uc624\uc158 \ub124\ud314 \uadfc\ub85c\uc790',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                  Icons.bolt, '${provider.totalXP} XP', AppTheme.gold),
              const SizedBox(width: 8),
              _buildBadge(Icons.local_fire_department_rounded,
                  '${provider.streak}\uc77c', Colors.deepOrange),
              const SizedBox(width: 8),
              _buildBadge(Icons.check_circle,
                  '${provider.completedLessons.length}', AppTheme.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AppProvider provider) {
    final totalLessons = provider.lessonData?.totalLessons ?? 320;
    final completed = provider.completedLessons.length;
    final quizzes = provider.quizScores.length;
    final avgScore = quizzes > 0
        ? (provider.quizScores.values.reduce((a, b) => a + b) / quizzes)
            .toInt()
        : 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _buildStatTile('\uc644\ub8cc \ub808\uc2a8', '$completed / $totalLessons',
            Icons.menu_book_rounded, AppTheme.teal),
        _buildStatTile('\ud035\uc988 \ud69f\uc218', '$quizzes',
            Icons.quiz_rounded, AppTheme.listening),
        _buildStatTile('\ud3c9\uade0 \uc810\uc218', '$avgScore%',
            Icons.analytics_rounded, AppTheme.gold),
        _buildStatTile('\ub2e8\uc5b4 \uc990\uaca8\ucc3e\uae30',
            '${provider.bookmarkedVocab.length}',
            Icons.bookmark_rounded, Colors.orange),
      ],
    );
  }

  Widget _buildStatTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDailyGoalSetting(
      BuildContext context, AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.cardBorder.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: AppTheme.teal, size: 20),
              SizedBox(width: 8),
              Text('\uc77c\uc77c \ud559\uc2b5 \ubaa9\ud45c | \u0926\u0948\u0928\u093f\u0915 \u0932\u0915\u094d\u0937\u094d\u092f',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 3, 5, 10].map((goal) {
              final isSelected = provider.dailyGoal == goal;
              return GestureDetector(
                onTap: () => provider.setDailyGoal(goal),
                child: Container(
                  width: 60,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.teal.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.teal
                          : Colors.white12,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('$goal',
                          style: TextStyle(
                              color: isSelected
                                  ? AppTheme.teal
                                  : Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text('\ub808\uc2a8',
                          style: TextStyle(
                              color: isSelected
                                  ? AppTheme.teal
                                  : Colors.white30,
                              fontSize: 9)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressList(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            '\ub808\ubca8\ubcc4 \uc9c4\ub3c4 | \u0938\u094d\u0924\u0930 \u0905\u0928\u0941\u0938\u093e\u0930 \u092a\u094d\u0930\u0917\u0924\u093f',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...['3', '4', '5', '6'].map((level) {
          final progress = provider.getLevelProgress(level);
          final colors = {
            '3': const Color(0xFF1565C0),
            '4': const Color(0xFF2E7D32),
            '5': const Color(0xFFE65100),
            '6': const Color(0xFF6A1B9A),
          };
          final names = {
            '3': '\uae30\ucd08',
            '4': '\uc911\uae09',
            '5': '\uace0\uae09',
            '6': '\uc804\ubb38',
          };
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.cardBorder.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors[level]!.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('$level\uae09',
                        style: TextStyle(
                            color: colors[level],
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(names[level]!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13)),
                          Text('${(progress * 100).toInt()}%',
                              style: TextStyle(
                                  color: colors[level],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor:
                            colors[level]!.withValues(alpha: 0.1),
                        valueColor:
                            AlwaysStoppedAnimation(colors[level]!),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSkillBars(AppProvider provider) {
    final skills = ['listening', 'reading', 'speaking', 'writing'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            '\uc601\uc5ed\ubcc4 \ud604\ud669 | \u0915\u094d\u0937\u0947\u0924\u094d\u0930 \u0905\u0928\u0941\u0938\u093e\u0930 \u0938\u094d\u0925\u093f\u0924\u093f',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.cardBorder.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: skills.map((skill) {
              double totalProgress = 0;
              for (var level in ['3', '4', '5', '6']) {
                totalProgress += provider.getSkillProgress(level, skill);
              }
              totalProgress /= 4;
              final color = AppTheme.skillColor(skill);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(AppTheme.skillIcon(skill),
                        color: color, size: 18),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 45,
                      child: Text(AppTheme.skillNameKr(skill),
                          style: TextStyle(
                              color: color, fontSize: 12)),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: totalProgress.clamp(0.0, 1.0),
                        backgroundColor:
                            color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(color),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(totalProgress * 100).toInt()}%',
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\ube60\ub978 \uc774\ub3d9',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const IntroductionScreen())),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.cardBorder.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.people_rounded,
                    color: AppTheme.teal, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\uc790\uae30\uc18c\uac1c \uc5f0\uc2b5 | \u0906\u0924\u094d\u092e-\u092a\u0930\u093f\u091a\u092f',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(
                          '\ub3d9\ub8cc\ub4e4\uacfc \uc778\uc0ac \ub098\ub204\uace0 \ud559\uc2b5 \ubaa9\ud45c \uacf5\uc720\ud558\uae30',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white24, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.cardBorder.withValues(alpha: 0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppTheme.teal, size: 18),
              SizedBox(width: 8),
              Text('About',
                  style: TextStyle(
                      color: AppTheme.teal,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          Text('Glocal Korean v2.0',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text(
            '\uc0ac\ud68c\ud1b5\ud569\ud504\ub85c\uadf8\ub7a8 1\ud0c0 \uac15\uc0ac\uc758 \uac15\uc758 \uc81c\uc791\n\ud55c\ud654\uc624\uc158 \ub124\ud314 \uadfc\ub85c\uc790 \ub9de\ucda4\ud615 \ud55c\uad6d\uc5b4 \ud559\uc2b5\n\nDeveloped by Elim G Mission\n\uc5d8\ub9bcG\uc120\uad50\ud68c | \ud55c\uc9c4\uc900 \ubaa9\uc0ac',
            style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
          ),
          SizedBox(height: 8),
          Text(
            '3\uae09~6\uae09 | 320 Lessons\n\ub4e3\uae30 \u00b7 \uc77d\uae30 \u00b7 \ub9d0\ud558\uae30 \u00b7 \uc4f0\uae30\n\ud55c\uad6d\uc5b4 \u00b7 \u0928\u0947\u092a\u093e\u0932\u0940 \u00b7 English',
            style: TextStyle(
                color: Colors.white24, fontSize: 10, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(
      BuildContext context, AppProvider provider) {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.cardBg,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('\uc9c4\ub3c4 \ucd08\uae30\ud654',
                style: TextStyle(color: Colors.white)),
            content: const Text(
              '\ubaa8\ub4e0 \ud559\uc2b5 \uc9c4\ub3c4\uac00 \ucd08\uae30\ud654\ub429\ub2c8\ub2e4.\n\uc815\ub9d0 \ucd08\uae30\ud654\ud558\uc2dc\uaca0\uc2b5\ub2c8\uae4c?',
              style: TextStyle(color: Colors.white54),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('\ucde8\uc18c',
                    style: TextStyle(color: Colors.white38)),
              ),
              TextButton(
                onPressed: () {
                  provider.resetProgress();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('\ucd08\uae30\ud654 \uc644\ub8cc!'),
                      backgroundColor: AppTheme.teal,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: const Text('\ucd08\uae30\ud654',
                    style: TextStyle(color: AppTheme.error)),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.refresh_rounded,
          color: AppTheme.error, size: 18),
      label: const Text(
          '\uc9c4\ub3c4 \ucd08\uae30\ud654 | \u092a\u094d\u0930\u0917\u0924\u093f \u0930\u093f\u0938\u0947\u091f',
          style: TextStyle(color: AppTheme.error, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }
}
