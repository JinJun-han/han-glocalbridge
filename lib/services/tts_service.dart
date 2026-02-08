import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class TtsService {
  static double _rate = 0.7;

  static double get rate => _rate;

  static void setRate(double rate) {
    _rate = rate.clamp(0.3, 1.5);
  }

  static Future<void> speak(String text, {String language = 'ko-KR'}) async {
    try {
      stop();
      final escaped = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\n', ' ');
      final js = '''
        (function(){
          var u = new SpeechSynthesisUtterance('$escaped');
          u.lang = '$language';
          u.rate = $_rate;
          u.pitch = 1.0;
          u.volume = 1.0;
          window.speechSynthesis.speak(u);
        })()
      ''';
      globalContext.callMethod('eval'.toJS, js.toJS);
    } catch (e) {
      // TTS not available
    }
  }

  static void stop() {
    try {
      globalContext.callMethod('eval'.toJS,
          'window.speechSynthesis && window.speechSynthesis.cancel()'.toJS);
    } catch (e) {
      // ignore
    }
  }
}
