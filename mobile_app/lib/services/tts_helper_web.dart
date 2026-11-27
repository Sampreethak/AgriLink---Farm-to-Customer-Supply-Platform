import 'dart:js_interop';

@JS('SpeechSynthesisUtterance')
extension type _SpeechSynthesisUtterance._(JSObject _) implements JSObject {
  external factory _SpeechSynthesisUtterance(JSString text);
  external set lang(JSString value);
  external set rate(JSNumber value);
}

@JS('window.speechSynthesis.cancel')
external void _cancelSpeech();

@JS('window.speechSynthesis.speak')
external void _speakUtterance(_SpeechSynthesisUtterance utterance);

const Map<String, String> _bcp47Map = {
  'en': 'en-IN',
  'kn': 'kn-IN',
  'hi': 'hi-IN',
  'te': 'te-IN',
  'ta': 'ta-IN',
  'ml': 'ml-IN',
};

void speakPlatformText(String text, String langCode) {
  try {
    final clean = text
        .replaceAll(RegExp(r'[*_#`•🌾🧪🌿⚠️⏱️🛡️]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (clean.isEmpty) return;
    _cancelSpeech();
    final utterance = _SpeechSynthesisUtterance(clean.toJS);
    utterance.lang = (_bcp47Map[langCode.toLowerCase()] ?? 'en-IN').toJS;
    utterance.rate = 0.95.toJS;
    _speakUtterance(utterance);
  } catch (_) {}
}

void stopPlatformSpeech() {
  try {
    _cancelSpeech();
  } catch (_) {}
}
