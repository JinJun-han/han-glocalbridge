import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:async';

class TtsService {
  static double _rate = 0.7;
  static bool _initialized = false;

  static double get rate => _rate;

  static void setRate(double rate) {
    _rate = rate.clamp(0.3, 1.5);
  }

  /// Initialize TTS engine - warm up voices
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      // Force browser to load voice list
      globalContext.callMethod('eval'.toJS, '''
        (function(){
          if (window.speechSynthesis) {
            window.speechSynthesis.getVoices();
            window.speechSynthesis.cancel();
            // Chrome requires onvoiceschanged event
            if (window.speechSynthesis.onvoiceschanged !== undefined) {
              window.speechSynthesis.onvoiceschanged = function() {
                window.__ttsVoicesLoaded = true;
              };
            }
            // Warm up with silent utterance
            var u = new SpeechSynthesisUtterance('');
            u.volume = 0;
            u.lang = 'ko-KR';
            window.speechSynthesis.speak(u);
            window.speechSynthesis.cancel();
          }
        })()
      '''.toJS);
      _initialized = true;
    } catch (e) {
      // TTS not available
    }
  }

  static Future<void> speak(String text, {String language = 'ko-KR'}) async {
    try {
      // Ensure initialized
      if (!_initialized) await initialize();

      // Cancel any ongoing speech first
      stop();

      // Small delay to let cancel complete
      await Future.delayed(const Duration(milliseconds: 50));

      final escaped = text
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'")
          .replaceAll('\n', ' ')
          .replaceAll('\r', ' ');

      final js = '''
        (function(){
          try {
            if (!window.speechSynthesis) return;
            
            // Cancel any previous speech
            window.speechSynthesis.cancel();
            
            // Chrome bug fix: resume if paused
            window.speechSynthesis.resume();
            
            var u = new SpeechSynthesisUtterance('$escaped');
            u.lang = '$language';
            u.rate = $_rate;
            u.pitch = 1.0;
            u.volume = 1.0;
            
            // Try to find a Korean voice
            var voices = window.speechSynthesis.getVoices();
            if (voices && voices.length > 0) {
              for (var i = 0; i < voices.length; i++) {
                if (voices[i].lang && voices[i].lang.indexOf('ko') === 0) {
                  u.voice = voices[i];
                  break;
                }
              }
            }
            
            // Chrome 14-second bug workaround
            window.__ttsTimer && clearInterval(window.__ttsTimer);
            window.__ttsTimer = setInterval(function(){
              if (window.speechSynthesis && !window.speechSynthesis.speaking) {
                clearInterval(window.__ttsTimer);
              } else {
                window.speechSynthesis.pause();
                window.speechSynthesis.resume();
              }
            }, 10000);
            
            u.onend = function() {
              clearInterval(window.__ttsTimer);
            };
            u.onerror = function() {
              clearInterval(window.__ttsTimer);
            };
            
            window.speechSynthesis.speak(u);
          } catch(e) {}
        })()
      ''';
      globalContext.callMethod('eval'.toJS, js.toJS);
    } catch (e) {
      // TTS not available
    }
  }

  static void stop() {
    try {
      globalContext.callMethod('eval'.toJS, '''
        (function(){
          try {
            if (window.speechSynthesis) {
              window.speechSynthesis.cancel();
              window.__ttsTimer && clearInterval(window.__ttsTimer);
            }
          } catch(e) {}
        })()
      '''.toJS);
    } catch (e) {
      // ignore
    }
  }
}
