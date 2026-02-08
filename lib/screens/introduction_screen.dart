import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/tts_service.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  String _selectedLevel = '3';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final introData = provider.introData;
        if (introData == null) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: AppTheme.teal)),
          );
        }

        final levels = introData['levels'] as List? ?? [];
        final currentLevel = levels.firstWhere(
          (l) => l['level'] == _selectedLevel,
          orElse: () => levels.isNotEmpty ? levels[0] : null,
        );

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white70),
                      ),
                      const Expanded(
                        child: Text(
                          '\uc790\uae30\uc18c\uac1c | \u0906\u0924\u094d\u092e-\u092a\u0930\u093f\u091a\u092f',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildLevelTabs(levels),
                if (currentLevel != null)
                  Expanded(child: _buildConversationList(currentLevel)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelTabs(List levels) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: levels.map<Widget>((level) {
          final lvl = level['level'] ?? '';
          final isSelected = _selectedLevel == lvl;
          return GestureDetector(
            onTap: () => setState(() => _selectedLevel = lvl),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.teal.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.teal : Colors.white24,
                ),
              ),
              child: Center(
                child: Text(
                  '$lvl\uae09',
                  style: TextStyle(
                    color: isSelected ? AppTheme.teal : Colors.white38,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConversationList(Map<String, dynamic> level) {
    final conversations = level['conversations'] as List? ?? [];
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.teal.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level['title'] ?? '',
                style: const TextStyle(
                    color: AppTheme.teal,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                level['description'] ?? '',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        ...conversations.asMap().entries.map((entry) {
          final i = entry.key;
          final conv = entry.value as Map<String, dynamic>;
          final korean = conv['korean'] ?? '';
          final nepali = conv['nepali'] ?? '';
          final english = conv['english'] ?? '';
          final category = conv['category'] ?? '';

          final categoryColors = {
            'greeting': Colors.blue,
            'origin': Colors.green,
            'goal': Colors.orange,
            'work': Colors.red,
            'plan': Colors.purple,
            'relationship': Colors.pink,
            'value': Colors.teal,
            'commitment': Colors.amber,
            'closing': Colors.indigo,
            'background': Colors.cyan,
            'career_goal': Colors.deepPurple,
            'study_plan': Colors.lightBlue,
          };
          final color = categoryColors[category] ?? AppTheme.teal;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: color.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(category,
                            style: TextStyle(
                                color: color, fontSize: 9)),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => TtsService.speak(korean),
                        child: Icon(Icons.volume_up_rounded,
                            color: color, size: 20),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        korean,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.4),
                      ),
                      const SizedBox(height: 6),
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
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(3),
                            ),
                            child: const Text('NP',
                                style: TextStyle(
                                    color: Color(0xFFE53935),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text(nepali,
                                style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                    height: 1.3)),
                          ),
                        ],
                      ),
                      if (english.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              margin: const EdgeInsets.only(
                                  right: 6, top: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(3),
                              ),
                              child: const Text('EN',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 8,
                                      fontWeight:
                                          FontWeight.bold)),
                            ),
                            Expanded(
                              child: Text(english,
                                  style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
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
}
