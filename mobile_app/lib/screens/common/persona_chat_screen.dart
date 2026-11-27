import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/config.dart';
import '../../core/localization.dart';
import '../../services/translation_service.dart';
import '../../services/tts_helper.dart';
import '../../widgets/voice_input_field.dart';
import '../../widgets/multilingual_keyboard.dart';

class PersonaChatScreen extends StatefulWidget {
  final String currentPersona; // FARMER, CUSTOMER, DELIVERY, AGGREGATOR
  final String currentUserName;

  const PersonaChatScreen({
    super.key,
    required this.currentPersona,
    required this.currentUserName,
  });

  @override
  State<PersonaChatScreen> createState() => _PersonaChatScreenState();
}

class _PersonaChatScreenState extends State<PersonaChatScreen> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final TextEditingController _msgController = TextEditingController();
  late String _selectedChannel;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _showKeyboard = false;

  static const List<Map<String, String>> _channels = [
    {'id': 'farmer-delivery', 'label': 'Farmer ↔ Delivery'},
    {'id': 'customer-delivery', 'label': 'Customer ↔ Delivery'},
    {'id': 'farmer-aggregator', 'label': 'Farmer ↔ Aggregator'},
    {'id': 'aggregator-delivery', 'label': 'Aggregator ↔ Delivery'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.currentPersona.toUpperCase();
    if (p == 'CUSTOMER') {
      _selectedChannel = 'customer-delivery';
    } else if (p == 'AGGREGATOR') {
      _selectedChannel = 'farmer-aggregator';
    } else {
      _selectedChannel = 'farmer-delivery';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  String _recipientForChannel(String channel) {
    final parts = channel.split('-');
    final me = widget.currentPersona.toLowerCase();
    for (final part in parts) {
      if (part != me) return part.toUpperCase();
    }
    return parts.last.toUpperCase();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final viewerLang = Provider.of<LanguageProvider>(context, listen: false)
        .getPersonaLanguage(widget.currentPersona);
    try {
      final res = await _dio.get('/messages', queryParameters: {
        'channel': _selectedChannel,
        'viewer_language': viewerLang,
      });
      if (res.statusCode == 200 && res.data != null && mounted) {
        final list = List<Map<String, dynamic>>.from(
          (res.data['messages'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e)),
        );
        setState(() {
          _messages = list;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _msgController.text).trim();
    if (text.isEmpty || _isSending) return;
    final senderLang = Provider.of<LanguageProvider>(context, listen: false)
        .getPersonaLanguage(widget.currentPersona);

    setState(() => _isSending = true);
    _msgController.clear();

    try {
      await _dio.post('/messages', data: {
        'channel': _selectedChannel,
        'sender_persona': widget.currentPersona.toUpperCase(),
        'sender_name': widget.currentUserName,
        'recipient_persona': _recipientForChannel(_selectedChannel),
        'text': text,
        'sender_language': senderLang,
      });
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Send error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final viewerLang = langProvider.getPersonaLanguage(widget.currentPersona);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multilingual Connect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '${widget.currentPersona} • Preferred: ${viewerLang.toUpperCase()}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            tooltip: 'Stop Audio',
            onPressed: () => TtsHelper.stop(),
          ),
          PersonaLanguageSelector(
            persona: widget.currentPersona,
            onChanged: (_) => _loadMessages(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Channel Selector
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _channels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final ch = _channels[i];
                final active = ch['id'] == _selectedChannel;
                return ChoiceChip(
                  label: Text(ch['label']!, style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.black87)),
                  selected: active,
                  selectedColor: AppColors.primaryGreen,
                  onSelected: (_) {
                    setState(() => _selectedChannel = ch['id']!);
                    _loadMessages();
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet. Speak or type in your language!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final m = _messages[i];
                          final isMe = (m['sender_persona'] ?? '').toString().toUpperCase() ==
                              widget.currentPersona.toUpperCase();
                          final translated = (m['translated_text'] ?? m['text'] ?? '').toString();
                          final original = (m['original_text'] ?? m['text'] ?? '').toString();
                          final srcLang = (m['sender_language'] ?? 'en').toString().toUpperCase();
                          final showOriginal = translated != original;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primaryGreen : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isMe ? Colors.transparent : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${m['sender_name'] ?? m['sender_persona']} (${m['sender_persona']}) • $srcLang',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isMe ? Colors.white70 : Colors.green.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    translated,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  if (showOriginal) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Original ($srcLang): $original',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        (m['created_at'] ?? '').toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe ? Colors.white70 : Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () => TtsHelper.speak(translated, languageCode: viewerLang),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isMe
                                                ? Colors.white.withValues(alpha: 0.2)
                                                : AppColors.primaryGreen.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.volume_up_rounded,
                                                size: 14,
                                                color: isMe ? Colors.white : AppColors.primaryGreen,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                'Listen',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isMe ? Colors.white : AppColors.primaryGreen,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Input Bar with Mic + Send
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showKeyboard ? Icons.keyboard_hide : Icons.keyboard_alt_outlined,
                      color: AppColors.primaryGreen,
                    ),
                    tooltip: 'Multilingual Keyboard (${viewerLang.toUpperCase()})',
                    onPressed: () => setState(() => _showKeyboard = !_showKeyboard),
                  ),
                  Expanded(
                    child: VoiceInputField(
                      controller: _msgController,
                      hintText: 'Speak or type in ${viewerLang.toUpperCase()}...',
                      prefixIcon: Icons.chat_outlined,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryGreen,
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: () => _sendMessage(),
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (_showKeyboard)
            MultilingualKeyboard(
              controller: _msgController,
              languageCode: viewerLang,
              onClose: () => setState(() => _showKeyboard = false),
            ),
        ],
      ),
    );
  }
}
