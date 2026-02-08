import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('progress');
  await Hive.openBox('settings');
  // Initialize TTS engine early for voice loading
  TtsService.initialize();
  runApp(const KoreanBridgeApp());
}

class KoreanBridgeApp extends StatelessWidget {
  const KoreanBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'Glocal Korean',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkOceanTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
