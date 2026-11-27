import 'tts_helper_stub.dart'
    if (dart.library.js_interop) 'tts_helper_web.dart';

class TtsHelper {
  static void speak(String text, {String languageCode = 'en'}) {
    speakPlatformText(text, languageCode);
  }

  static void stop() {
    stopPlatformSpeech();
  }
}
