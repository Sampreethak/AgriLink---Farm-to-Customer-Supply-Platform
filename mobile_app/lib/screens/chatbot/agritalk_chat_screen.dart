import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/config.dart';
import '../../core/localization.dart';
import '../../widgets/voice_input_field.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
  });
}

class AgriTalkChatScreen extends StatefulWidget {
  final String? initialQuery;
  const AgriTalkChatScreen({super.key, this.initialQuery});

  @override
  State<AgriTalkChatScreen> createState() => _AgriTalkChatScreenState();
}

class _AgriTalkChatScreenState extends State<AgriTalkChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void initState() {
    super.initState();
    _addInitialGreeting();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _sendMessage(widget.initialQuery!);
    }
  }

  void _addInitialGreeting() {
    final lang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;
    String greeting;
    if (lang == 'kn') {
      greeting = "🌾 ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮ AgriTalk AI ಕೃಷಿ ಸಹಾಯಕ.\nಬೆಳೆ ಬೆಲೆಗಳು, ರೋಗ ನಿಯಂತ್ರಣ, ಮಂಡಿ ದರಗಳು ಅಥವಾ ಆರ್ಡರ್ ಸ್ಥಿತಿಯ ಬಗ್ಗೆ ಯಾವುದೇ ಪ್ರಶ್ನೆ ಕೇಳಿ.";
    } else if (lang == 'hi') {
      greeting = "🌾 नमस्ते! मैं आपका एग्रीलिंक एआई सहायक (AgriTalk) हूँ।\nमंडी भाव, कीट नियंत्रण, 68% किसान हिस्सेदारी या डिलीवरी की स्थिति के बारे में पूछें।";
    } else {
      greeting = "🌾 Hello! I am your **AgriTalk AI Assistant**.\nAsk me anything about live Mandi rates, crop disease diagnosis, fair-share pricing, or order tracking.";
    }

    _messages.add(ChatMessage(
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage(String queryText) async {
    final text = queryText.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    final lang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    try {
      final response = await _dio.post(
        '/nlp/query',
        data: {
          'query': text,
          'language': lang,
          'role': 'FARMER',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final botReply = response.data['response'] ?? 'I could not understand that. Please try again.';
        final intent = response.data['intent'];

        setState(() {
          _messages.add(ChatMessage(
            text: botReply,
            isUser: false,
            timestamp: DateTime.now(),
            intent: intent,
          ));
        });
      }
    } catch (e) {
      // Offline / Fallback response
      String fallback;
      if (text.toLowerCase().contains('tomato') || text.contains('ಟೊಮ್ಯಾಟೊ') || text.contains('टमाटर')) {
        fallback = "🍅 **Tomato Fair Market Rate (Mandya-BLR):**\n- AgriLink Farmer Payout: **₹24.84/kg (68%)**\n- APMC Mandi Modal: ₹25.77/kg\n- Fair Consumer Price: ₹36.53/kg";
      } else if (text.toLowerCase().contains('share') || text.contains('ಲಾಭ') || text.contains('हिस्सा')) {
        fallback = "📊 **AgriLink Fair Share:** Farmer (68%) | Aggregator (10%) | Delivery (14%) | Platform (8%).";
      } else {
        fallback = "🛡️ **AgriTalk Tip:** For healthy crops, maintain balanced NPK ratios and spray cold-pressed neem oil (1500 ppm) for sucking pest control.";
      }

      setState(() {
        _messages.add(ChatMessage(
          text: fallback,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final suggestions = langProvider.currentLanguage == 'kn'
        ? ["🍅 ಟೊಮ್ಯಾಟೋ ಬೆಲೆ ಎಷ್ಟು?", "🌾 ರಾಗಿ ಬೆಳೆ ಸಲಹೆ", "📊 ೬೮% ರೈತರ ಲಾಭ", "📦 ನನ್ನ ಆರ್ಡರ್ ಎಲ್ಲಿದೆ?"]
        : langProvider.currentLanguage == 'hi'
            ? ["🍅 टमाटर का क्या भाव है?", "🌾 गेहूं फसल सलाह", "📊 68% किसान हिस्सा", "📦 ऑर्डर ट्रैकिंग"]
            : ["🍅 Today's Tomato Price", "🌾 Pest & Disease Advice", "📊 68% Farmer Payout", "📦 Track Active Orders"];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(Icons.smart_toy, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("AgriTalk AI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Multilingual Farm Assistant", style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: "Change Language",
            onPressed: () {
              _showLanguageDialog(langProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggestions bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => ActionChip(
                label: Text(suggestions[i], style: const TextStyle(fontSize: 12)),
                backgroundColor: AppColors.primaryGreen.withOpacity(0.08),
                side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
                onPressed: () => _sendMessage(suggestions[i]),
              ),
            ),
          ),
          const Divider(height: 1),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("AgriTalk AI is thinking...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

          // Bottom Input Bar with Multilingual Voice Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: VoiceInputField(
                      controller: _textController,
                      hintText: langProvider.currentLanguage == 'kn'
                          ? "ಇಲ್ಲಿ ಪ್ರಶ್ನೆ ಟೈಪ್ ಮಾಡಿ ಅಥವಾ ಮಾತನಾಡಿ..."
                          : langProvider.currentLanguage == 'hi'
                              ? "यहाँ प्रश्न लिखें या बोलें..."
                              : "Ask AgriTalk (Type or speak)...",
                      prefixIcon: Icons.chat_bubble_outline,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryGreen,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primaryGreen : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: Border.all(
            color: msg.isUser ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 10,
                color: msg.isUser ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select AgriTalk Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English"),
              leading: const Text("🇺🇸"),
              onTap: () {
                provider.setLanguage('en');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text("ಕನ್ನಡ (Kannada)"),
              leading: const Text("🇮🇳"),
              onTap: () {
                provider.setLanguage('kn');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text("हिंदी (Hindi)"),
              leading: const Text("🇮🇳"),
              onTap: () {
                provider.setLanguage('hi');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
