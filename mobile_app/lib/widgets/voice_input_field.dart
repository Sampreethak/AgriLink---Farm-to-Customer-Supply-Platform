import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../core/localization.dart';

class VoiceInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const VoiceInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon = Icons.edit,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<VoiceInputField> createState() => _VoiceInputFieldState();
}

class _VoiceInputFieldState extends State<VoiceInputField> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen(String localeId) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech error: ${errorNotification.errorMsg}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: localeId,
          onResult: (result) {
            setState(() {
              widget.controller.text = result.recognizedWords;
              if (widget.onChanged != null) {
                widget.onChanged!(result.recognizedWords);
              }
            });
          },
          onSoundLevelChange: (level) {
            setState(() {
              _soundLevel = level;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  String _getLocaleId(String langCode) {
    switch (langCode) {
      case 'hi':
        return 'hi_IN';
      case 'kn':
        return 'kn_IN';
      case 'te':
        return 'te_IN';
      case 'ta':
        return 'ta_IN';
      case 'ml':
        return 'ml_IN';
      case 'en':
      default:
        return 'en_IN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final localeId = _getLocaleId(langProvider.currentLanguage);

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon),
            contentPadding: const EdgeInsets.only(
              left: 16,
              right: 60, // Give room for mic icon and visualizer
              top: 16,
              bottom: 16,
            ),
          ),
        ),
        Positioned(
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isListening)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 12 + (_soundLevel * 2),
                  height: 12 + (_soundLevel * 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? AppColors.accent : AppColors.primaryGreen,
                ),
                onPressed: () => _listen(localeId),
                tooltip: langProvider.translate('voice_search'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
