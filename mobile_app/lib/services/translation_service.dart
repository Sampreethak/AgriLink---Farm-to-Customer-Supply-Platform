import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config.dart';
import '../core/localization.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final Map<String, String> _localCache = {};

  Future<String> translateText(
    String text, {
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return clean;
    final key = '$targetLanguage:$clean';
    if (_localCache.containsKey(key)) return _localCache[key]!;

    try {
      final res = await _dio.post('/ai/translate', data: {
        'text': clean,
        'target_language': targetLanguage,
        'source_language': sourceLanguage,
      });
      if (res.statusCode == 200 && res.data != null) {
        final translated = (res.data['translated_text'] ?? clean).toString();
        _localCache[key] = translated;
        return translated;
      }
    } catch (_) {}
    return clean;
  }

  Future<void> savePersonaLanguage(String persona, String languageCode) async {
    try {
      await _dio.post('/users/language', data: {
        'persona': persona.toUpperCase(),
        'language': languageCode,
      });
    } catch (_) {}
  }
}

class PersonaLanguageSelector extends StatelessWidget {
  final String persona;
  final ValueChanged<String>? onChanged;

  const PersonaLanguageSelector({
    super.key,
    required this.persona,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final activeLang = langProvider.getPersonaLanguage(persona);
    return PopupMenuButton<String>(
      tooltip: 'Preferred Language ($persona)',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.translate, size: 18),
          const SizedBox(width: 4),
          Text(
            activeLang.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onSelected: (code) async {
        await langProvider.setPersonaLanguage(persona, code);
        await TranslationService().savePersonaLanguage(persona, code);
        if (onChanged != null) onChanged!(code);
      },
      itemBuilder: (context) => LanguageProvider.languages.entries
          .map((e) => PopupMenuItem<String>(
                value: e.key,
                child: Row(
                  children: [
                    if (e.key == activeLang)
                      const Icon(Icons.check, size: 16, color: Colors.green)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(e.value),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
