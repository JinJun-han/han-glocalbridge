import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/lesson_model.dart';
import '../services/tts_service.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _flashcardMode = false;
  int _flashcardIndex = 0;
  bool _showAnswer = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        if (_flashcardMode) {
          return _buildFlashcardView(provider);
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(provider),
                const SizedBox(height: 8),
                _buildSearchBar(),
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
                    tabs: [
                      Tab(
                          text:
                              '\uc804\uccb4 \ub2e8\uc5b4 (${provider.allVocabulary.length})'),
                      Tab(
                          text:
                              '\uc990\uaca8\ucc3e\uae30 (${provider.bookmarkedVocabulary.length})'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVocabList(provider, provider.allVocabulary),
                      _buildVocabList(
                          provider, provider.bookmarkedVocabulary),
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

  Widget _buildHeader(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.abc_rounded, color: AppTheme.teal, size: 28),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\ub2e8\uc5b4\uc7a5 | \u0936\u092c\u094d\u0926 \u092a\u0941\u0938\u094d\u0924\u0915',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final vocab = provider.allVocabulary;
              if (vocab.isEmpty) return;
              setState(() {
                _flashcardMode = true;
                _flashcardIndex = 0;
                _showAnswer = false;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.teal.withValues(alpha: 0.2),
                    AppTheme.tealDark.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.style_rounded, color: AppTheme.teal, size: 16),
                  SizedBox(width: 6),
                  Text('\ud50c\ub798\uc2dc\uce74\ub4dc',
                      style: TextStyle(
                          color: AppTheme.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppTheme.cardBorder.withValues(alpha: 0.3)),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: '\ub2e8\uc5b4 \uac80\uc0c9... | \u0936\u092c\u094d\u0926 \u0916\u094b\u091c\u094d\u0928\u0941\u0939\u094b\u0938\u094d...',
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            prefixIcon: const Icon(Icons.search_rounded,
                color: Colors.white24, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildVocabList(AppProvider provider, List<Vocabulary> vocab) {
    var filtered = vocab;
    if (_searchQuery.isNotEmpty) {
      filtered = vocab
          .where((v) =>
              v.korean.toLowerCase().contains(_searchQuery) ||
              v.nepali.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Remove duplicates
    final seen = <String>{};
    final unique = <Vocabulary>[];
    for (final v in filtered) {
      if (seen.add(v.korean)) unique.add(v);
    }

    if (unique.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            const Text('\ub2e8\uc5b4\ub97c \ucc3e\uc744 \uc218 \uc5c6\uc2b5\ub2c8\ub2e4',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      itemCount: unique.length,
      itemBuilder: (context, index) {
        final v = unique[index];
        final isBookmarked = provider.bookmarkedVocab.contains(v.korean);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isBookmarked
                    ? AppTheme.gold.withValues(alpha: 0.3)
                    : AppTheme.cardBorder.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.korean,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(v.nepali,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => TtsService.speak(v.korean),
                icon: const Icon(Icons.volume_up_rounded,
                    color: AppTheme.teal, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                onPressed: () => provider.toggleBookmarkVocab(v.korean),
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppTheme.gold : Colors.white24,
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlashcardView(AppProvider provider) {
    final vocab = provider.allVocabulary;
    final seen = <String>{};
    final unique = <Vocabulary>[];
    for (final v in vocab) {
      if (seen.add(v.korean)) unique.add(v);
    }

    if (unique.isEmpty) {
      return Scaffold(
        body: Center(
            child: Text('\ub2e8\uc5b4\uac00 \uc5c6\uc2b5\ub2c8\ub2e4',
                style: TextStyle(color: Colors.white54))),
      );
    }

    // Shuffle on first load
    if (_flashcardIndex == 0 && !_showAnswer) {
      unique.shuffle(Random());
    }

    final current = unique[_flashcardIndex % unique.length];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _flashcardMode = false),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    '${_flashcardIndex + 1} / ${unique.length}',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: (_flashcardIndex + 1) / unique.length,
                backgroundColor: AppTheme.teal.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppTheme.teal),
                borderRadius: BorderRadius.circular(4),
                minHeight: 3,
              ),
            ),
            const Spacer(),
            // Card
            GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.85,
                height: 280,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _showAnswer
                        ? [
                            AppTheme.teal.withValues(alpha: 0.15),
                            AppTheme.tealDark.withValues(alpha: 0.08),
                          ]
                        : [
                            AppTheme.cardBg,
                            AppTheme.surfaceBg,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _showAnswer
                        ? AppTheme.teal.withValues(alpha: 0.4)
                        : AppTheme.cardBorder.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _showAnswer
                          ? AppTheme.teal.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      current.korean,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_showAnswer) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: 60,
                        height: 1,
                        color: AppTheme.teal.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        current.nepali,
                        style: const TextStyle(
                          color: AppTheme.tealLight,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      Text(
                        '\ud0ed\ud558\uc5ec \ub73b \ud655\uc778',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // TTS button
            IconButton(
              onPressed: () => TtsService.speak(current.korean),
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.teal.withValues(alpha: 0.15),
                  border:
                      Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.volume_up_rounded,
                    color: AppTheme.teal, size: 28),
              ),
            ),
            const Spacer(),
            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFlashcardButton(
                    Icons.arrow_back_rounded,
                    '\uc774\uc804',
                    _flashcardIndex > 0
                        ? () => setState(() {
                              _flashcardIndex--;
                              _showAnswer = false;
                            })
                        : null,
                  ),
                  _buildFlashcardButton(
                    provider.bookmarkedVocab.contains(current.korean)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    '\uc990\uaca8\ucc3e\uae30',
                    () => provider.toggleBookmarkVocab(current.korean),
                    color: provider.bookmarkedVocab.contains(current.korean)
                        ? AppTheme.gold
                        : Colors.white38,
                  ),
                  _buildFlashcardButton(
                    Icons.arrow_forward_rounded,
                    '\ub2e4\uc74c',
                    _flashcardIndex < unique.length - 1
                        ? () => setState(() {
                              _flashcardIndex++;
                              _showAnswer = false;
                            })
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardButton(
      IconData icon, String label, VoidCallback? onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onTap != null
                  ? (color ?? AppTheme.teal).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.03),
              border: Border.all(
                color: onTap != null
                    ? (color ?? AppTheme.teal).withValues(alpha: 0.3)
                    : Colors.white12,
              ),
            ),
            child: Icon(icon,
                color: onTap != null
                    ? (color ?? AppTheme.teal)
                    : Colors.white24,
                size: 24),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: onTap != null ? Colors.white54 : Colors.white24,
                  fontSize: 10)),
        ],
      ),
    );
  }
}
