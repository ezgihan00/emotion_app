import 'package:flutter/material.dart';
import '../services/api_demo.dart';

class TextAnalysisPage extends StatefulWidget {
  const TextAnalysisPage({super.key});

  @override
  State<TextAnalysisPage> createState() => _TextAnalysisPageState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? emotion;
  final double? score;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.emotion,
    this.score,
  });
}

class _TextAnalysisPageState extends State<TextAnalysisPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text:
            "Merhaba, ben duygusal destek asistanın \n"
            "Bana gününü, hislerini, aklındaki her şeyi yazabilirsin. "
            "Mesajlarını duygusal olarak analiz edeceğim.",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(text: text, isUser: true));
      _textController.clear();
    });
    _scrollToBottom();

    try {
      final result = await SentimentApi.analyze(text);

      setState(() {
        _messages.add(
          ChatMessage(
            text: "Seni anlıyorum ",
            isUser: false,
            emotion: result["label"],
            score: (result["score"] as num).toDouble(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Sunucuya bağlanılamadı 😔 Lütfen tekrar dene.",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Color _emotionColor(String? emotion) {
    if (emotion == null) return Colors.grey;
    switch (emotion.toLowerCase()) {
      case "pozitif":
      case "mutlu":
        return const Color(0xFF4CAF50);
      case "negatif":
      case "üzgün":
        return const Color(0xFFF44336);
      case "kaygılı":
        return Colors.orange;
      case "öfkeli":
        return const Color(0xFFD32F2F);
      case "nötr":
      default:
        return Colors.grey;
    }
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = msg.isUser ? scheme.primary : scheme.surfaceVariant;
    final textColor = msg.isUser ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!msg.isUser && msg.emotion != null && msg.score != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _emotionColor(msg.emotion)),
                ),
                child: Text(
                  "${msg.emotion} • ${(msg.score! * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _emotionColor(msg.emotion),
                  ),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(msg.isUser ? 16 : 4),
                topRight: Radius.circular(msg.isUser ? 4 : 16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
            ),
            child: Text(msg.text, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Duygu Analizi Sohbeti",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Yazdığın mesajlar backend üzerinden gerçek zamanlı analiz edilir.",
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _messages.length,
              itemBuilder:
                  (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: scheme.surface),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Bugün nasılsın?",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _sendMessage,
                  icon:
                      _isSending
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send_rounded),
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
