import 'package:flutter/material.dart';

class AppTheme {
  // Core Deep Ocean palette
  static const Color deepOcean = Color(0xFF0A1628);
  static const Color navyBlue = Color(0xFF0F2038);
  static const Color darkBlue = Color(0xFF1A237E);
  static const Color cardBg = Color(0xFF132035);
  static const Color surfaceBg = Color(0xFF172842);
  static const Color cardBorder = Color(0xFF1E3454);

  // Accent colors
  static const Color teal = Color(0xFF00BCD4);
  static const Color tealLight = Color(0xFF4DD0E1);
  static const Color tealDark = Color(0xFF00838F);
  static const Color gold = Color(0xFFFFD54F);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);

  // Skill colors
  static const Color listening = Color(0xFF42A5F5);
  static const Color reading = Color(0xFF66BB6A);
  static const Color speaking = Color(0xFFFF7043);
  static const Color writing = Color(0xFFAB47BC);

  // Category colors
  static const Map<String, Color> categoryColors = {
    'safety': Color(0xFFEF5350),
    'tools': Color(0xFF78909C),
    'daily': Color(0xFF4FC3F7),
    'report': Color(0xFFFFB74D),
    'work_instruction': Color(0xFF81C784),
    'blueprint': Color(0xFF7986CB),
    'reporting': Color(0xFFE57373),
    'business_document': Color(0xFF4DB6AC),
    'emergency': Color(0xFFFF5252),
    'quality': Color(0xFF9575CD),
    'meeting': Color(0xFF64B5F6),
    'technical': Color(0xFF90A4AE),
  };

  static const Map<String, IconData> categoryIcons = {
    'safety': Icons.health_and_safety_rounded,
    'tools': Icons.construction_rounded,
    'daily': Icons.wb_sunny_rounded,
    'report': Icons.assignment_rounded,
    'work_instruction': Icons.engineering_rounded,
    'blueprint': Icons.architecture_rounded,
    'reporting': Icons.summarize_rounded,
    'business_document': Icons.description_rounded,
    'emergency': Icons.local_hospital_rounded,
    'quality': Icons.verified_rounded,
    'meeting': Icons.groups_rounded,
    'technical': Icons.precision_manufacturing_rounded,
  };

  static const Map<String, String> categoryNamesKr = {
    'safety': '\uc548\uc804',
    'tools': '\ub3c4\uad6c',
    'daily': '\uc77c\uc0c1',
    'report': '\ubcf4\uace0',
    'work_instruction': '\uc791\uc5c5\uc9c0\uc2dc',
    'blueprint': '\ub3c4\uba74',
    'reporting': '\ub9ac\ud3ec\ud305',
    'business_document': '\uc5c5\ubb34\ubb38\uc11c',
    'emergency': '\ube44\uc0c1',
    'quality': '\ud488\uc9c8',
    'meeting': '\ud68c\uc758',
    'technical': '\uae30\uc220',
  };

  static const Map<String, String> categoryNamesNp = {
    'safety': '\u0938\u0941\u0930\u0915\u094d\u0937\u093e',
    'tools': '\u0914\u091c\u093e\u0930',
    'daily': '\u0926\u0948\u0928\u093f\u0915',
    'report': '\u092a\u094d\u0930\u0924\u093f\u0935\u0947\u0926\u0928',
    'work_instruction': '\u0915\u093e\u0930\u094d\u092f \u0928\u093f\u0930\u094d\u0926\u0947\u0936',
    'blueprint': '\u0928\u0915\u094d\u0938\u093e',
    'reporting': '\u0930\u093f\u092a\u094b\u0930\u094d\u091f\u093f\u0919',
    'business_document': '\u0935\u094d\u092f\u0935\u0938\u093e\u092f \u0926\u0938\u094d\u0924\u093e\u0935\u0947\u091c',
    'emergency': '\u0906\u092a\u0924\u0915\u093e\u0932\u0940\u0928',
    'quality': '\u0917\u0941\u0923\u0938\u094d\u0924\u0930',
    'meeting': '\u092c\u0948\u0920\u0915',
    'technical': '\u092a\u094d\u0930\u093e\u0935\u093f\u0927\u093f\u0915',
  };

  static Color skillColor(String skill) {
    switch (skill) {
      case 'listening': return listening;
      case 'reading': return reading;
      case 'speaking': return speaking;
      case 'writing': return writing;
      default: return teal;
    }
  }

  static IconData skillIcon(String skill) {
    switch (skill) {
      case 'listening': return Icons.headphones_rounded;
      case 'reading': return Icons.auto_stories_rounded;
      case 'speaking': return Icons.record_voice_over_rounded;
      case 'writing': return Icons.edit_note_rounded;
      default: return Icons.school_rounded;
    }
  }

  static String skillNameKr(String skill) {
    switch (skill) {
      case 'listening': return '\ub4e3\uae30';
      case 'reading': return '\uc77d\uae30';
      case 'speaking': return '\ub9d0\ud558\uae30';
      case 'writing': return '\uc4f0\uae30';
      default: return skill;
    }
  }

  static String skillNameNp(String skill) {
    switch (skill) {
      case 'listening': return '\u0938\u0941\u0928\u094d\u0928\u0941';
      case 'reading': return '\u092a\u0922\u094d\u0928\u0941';
      case 'speaking': return '\u092c\u094b\u0932\u094d\u0928\u0941';
      case 'writing': return '\u0932\u0947\u0916\u094d\u0928\u0941';
      default: return skill;
    }
  }

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? teal;
  }

  static IconData getCategoryIcon(String category) {
    return categoryIcons[category] ?? Icons.folder_rounded;
  }

  static ThemeData get darkOceanTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepOcean,
      primaryColor: teal,
      colorScheme: const ColorScheme.dark(
        primary: teal,
        secondary: tealLight,
        surface: cardBg,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cardBorder.withValues(alpha: 0.5)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white60),
      ),
    );
  }
}
