import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../services/translation_service.dart';

class MultilingualKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final String languageCode;
  final VoidCallback? onClose;

  const MultilingualKeyboard({
    super.key,
    required this.controller,
    required this.languageCode,
    this.onClose,
  });

  @override
  State<MultilingualKeyboard> createState() => _MultilingualKeyboardState();
}

class _MultilingualKeyboardState extends State<MultilingualKeyboard> {
  bool _isConverting = false;

  static const Map<String, List<String>> _quickWords = {
    'kn': ['ನಮಸ್ಕಾರ', 'ಟೊಮ್ಯಾಟೊ', 'ಈರುಳ್ಳಿ', 'ಸಿದ್ಧವಾಗಿದೆ', 'ಬರುತ್ತಿದ್ದೇನೆ', 'ಎಷ್ಟು ಬೆಲೆ?', 'ಧನ್ಯವಾದಗಳು'],
    'hi': ['नमस्ते', 'टमाटर', 'प्याज', 'तैयार है', 'आ रहा हूँ', 'कितने रुपये?', 'धन्यवाद'],
    'te': ['నమస్కారం', 'టమోటా', 'ఉల్లిపాయ', 'సిద్ధంగా ఉంది', 'వస్తున్నాను', 'ధన్యవాదాలు'],
    'ta': ['வணக்கம்', 'தக்காளி', 'வெங்காயம்', 'தயாராக உள்ளது', 'வருகிறேன்', 'நன்றி'],
    'ml': ['നമസ്കാരം', 'തക്കാളി', 'ഉള്ളി', 'തയ്യാറാണ്', 'വരുന്നുണ്ട്', 'നന്ദി'],
    'en': ['Hello', 'Ready for pickup', 'On my way', 'In stock', 'Thank you'],
  };

  static const Map<String, List<String>> _charKeys = {
    'kn': [
      'ಅ', 'ಆ', 'ಇ', 'ಈ', 'ಉ', 'ಎ', 'ಏ', 'ಒ', 'ಓ',
      'ಕ', 'ಖ', 'ಗ', 'ಚ', 'ಜ', 'ಟ', 'ಡ', 'ಣ', 'ತ', 'ದ', 'ನ',
      'ಪ', 'ಬ', 'ಭ', 'ಮ', 'ಯ', 'ರ', 'ಲ', 'ವ', 'ಶ', 'ಸ', 'ಹ', 'ಳ',
      'ಾ', 'ಿ', 'ೀ', 'ು', 'ೂ', 'ೆ', 'ೇ', 'ೊ', 'ೋ', '್', 'ಂ',
    ],
    'hi': [
      'अ', 'आ', 'इ', 'ई', 'उ', 'ए', 'ऐ', 'ओ', 'औ',
      'क', 'ख', 'ग', 'च', 'ज', 'ट', 'ड', 'त', 'द', 'न',
      'प', 'ब', 'भ', 'म', 'य', 'र', 'ल', 'व', 'श', 'स', 'ह',
      'ा', 'ि', 'ी', 'ु', 'ू', 'े', 'ै', 'ो', 'ौ', '्', 'ं',
    ],
    'te': [
      'అ', 'ఆ', 'ఇ', 'ఈ', 'ఉ', 'ఎ', 'ఏ', 'ఒ', 'ఓ',
      'క', 'గ', 'చ', 'జ', 'ట', 'డ', 'త', 'ద', 'న',
      'ప', 'బ', 'మ', 'య', 'ర', 'ల', 'వ', 'శ', 'స', 'హ',
      'ా', 'ి', 'ీ', 'ు', 'ూ', 'ె', 'ే', 'ొ', 'ో', '్', 'ం',
    ],
    'ta': [
      'அ', 'ஆ', 'இ', 'ஈ', 'உ', 'எ', 'ஏ', 'ஒ', 'ஓ',
      'க', 'ச', 'ட', 'த', 'ந', 'ப', 'ம', 'ய', 'ர', 'ல', 'வ', 'ழ', 'ள', 'ற', 'ன',
      'ா', 'ி', 'ீ', 'ு', 'ூ', 'ெ', 'ே', 'ொ', 'ோ', '்',
    ],
    'ml': [
      'അ', 'ആ', 'ഇ', 'ഈ', 'ഉ', 'എ', 'ഏ', 'ഒ', 'ഓ',
      'ക', 'ഗ', 'ച', 'ജ', 'ട', 'ഡ', 'ത', 'ദ', 'ന',
      'പ', 'ബ', 'മ', 'യ', 'ര', 'ല', 'വ', 'ശ', 'സ', 'ഹ', 'ള', 'ഴ',
      'ാ', 'ി', 'ീ', 'ു', 'ൂ', 'െ', 'േ', 'ൊ', 'ോ', '്', 'ം',
    ],
    'en': [
      'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
      'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
      'z', 'x', 'c', 'v', 'b', 'n', 'm',
    ],
  };

  void _insertText(String value) {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final updated = text.replaceRange(start, end, value);
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }

  void _backspace() {
    final text = widget.controller.text;
    if (text.isEmpty) return;
    final sel = widget.controller.selection;
    final pos = sel.isValid ? sel.start : text.length;
    if (pos <= 0) return;
    final updated = text.substring(0, pos - 1) + text.substring(pos);
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: pos - 1),
    );
  }

  Future<void> _convertPhonetic() async {
    final raw = widget.controller.text.trim();
    if (raw.isEmpty || _isConverting) return;
    setState(() => _isConverting = true);
    final converted = await TranslationService().transliterateText(
      raw,
      targetLanguage: widget.languageCode,
    );
    if (mounted) {
      widget.controller.value = TextEditingValue(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
      setState(() => _isConverting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.languageCode.toLowerCase();
    final words = _quickWords[code] ?? _quickWords['en']!;
    final keys = _charKeys[code] ?? _charKeys['en']!;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Helper Bar: Phonetic Convert + Close
          Row(
            children: [
              Text(
                '${code.toUpperCase()} Keyboard',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 8),
              if (code != 'en')
                ElevatedButton.icon(
                  onPressed: _isConverting ? null : _convertPhonetic,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: _isConverting
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.auto_fix_high, size: 13),
                  label: Text('Aa → ${code.toUpperCase()} Convert', style: const TextStyle(fontSize: 11)),
                ),
              const Spacer(),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.keyboard_hide, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onClose,
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Quick Farm/Delivery Phrases
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: words.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => ActionChip(
                label: Text(words[i], style: const TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.white,
                onPressed: () => _insertText('${words[i]} '),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Character Keys Grid
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              ...keys.map((ch) => InkWell(
                    onTap: () => _insertText(ch),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(ch, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  )),
              InkWell(
                onTap: () => _insertText(' '),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 68,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text('Space', style: TextStyle(fontSize: 11)),
                ),
              ),
              InkWell(
                onTap: _backspace,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 44,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Icon(Icons.backspace_outlined, size: 16, color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
