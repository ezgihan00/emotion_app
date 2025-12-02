import 'dart:math';
import 'package:flutter/material.dart';

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
            "Merhaba, ben duygusal destek asistanın 💜\n"
            "Bana gününü, hislerini, aklındaki her şeyi yazabilirsin. "
            "Mesajlarını duygusal olarak analiz etmeye çalışacağım.",
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

    await Future.delayed(const Duration(milliseconds: 500));

    final reply = _fakeAnalyze(text);

    setState(() {
      _messages.add(reply);
      _isSending = false;
    });
    _scrollToBottom();
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

  ChatMessage _fakeAnalyze(String userText) {
    final rand = Random();
    final emotions = ["Mutlu", "Üzgün", "Kaygılı", "Öfkeli", "Yorgun", "Nötr"];
    final emotion = emotions[rand.nextInt(emotions.length)];
    final score = 0.70 + rand.nextDouble() * 0.30; // 0.70–1.00
    final lower = userText.toLowerCase();

    String replyText;
    if (lower.contains("iyi") || lower.contains("mutlu")) {
      replyText =
          "İyi hissetmene sevindim 🌟 Bu duyguyu sürdürmek için neler yapıyorsun, biraz anlatmak ister misin?";
    } else if (lower.contains("kötü") ||
        lower.contains("üzgün") ||
        lower.contains("mutsuz")) {
      replyText =
          "Üzgün hissettiğini duymak zor 😔 İstersen detaylıca anlat, birlikte adım adım bakabiliriz.";
    } else if (lower.contains("kaygı") ||
        lower.contains("anksiyete") ||
        lower.contains("endişe")) {
      replyText =
          "Kaygı yaşamak çok yorucu olabiliyor… 😥 Şu an seni en çok endişelendiren şey ne?";
    } else {
      replyText =
          "Anlattıklarını anlıyorum 💜 Bu durum seni nasıl hissettirdi, biraz daha açmak ister misin?";
    }

    replyText +=
        "\n\n(Analiz sonucu: $emotion, güven: ${(score * 100).toStringAsFixed(1)}%)";

    return ChatMessage(
      text: replyText,
      isUser: false,
      emotion: emotion,
      score: score,
    );
  }

  Color _bubbleColor(ChatMessage msg, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (msg.isUser) {
      return scheme.primary;
    } else {
      // açık modda açık, koyu modda koyu ama kontrastı iyi bir yüzey
      return scheme.surfaceVariant;
    }
  }

  Alignment _bubbleAlign(ChatMessage msg) {
    return msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
  }

  CrossAxisAlignment _columnAlign(ChatMessage msg) {
    return msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  Color _emotionColor(String? emotion) {
    if (emotion == null) return Colors.grey.shade500;
    switch (emotion.toLowerCase()) {
      case "mutlu":
        return const Color(0xFF4CAF50);
      case "üzgün":
        return const Color(0xFFF44336);
      case "kaygılı":
        return Colors.orange;
      case "öfkeli":
        return const Color(0xFFD32F2F);
      case "yorgun":
        return Colors.blueGrey;
      case "nötr":
      default:
        return Colors.grey;
    }
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = _bubbleColor(msg, context);

    // ✅ kullanıcı balonu: onPrimary (genelde beyaz)
    // ✅ asistan balonu: onSurface (dark/light'a göre otomatik ayarlanır)
    final textColor = msg.isUser ? scheme.onPrimary : scheme.onSurface;

    return Align(
      alignment: _bubbleAlign(msg),
      child: Column(
        crossAxisAlignment: _columnAlign(msg),
        children: [
          if (!msg.isUser && msg.emotion != null && msg.score != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _emotionColor(msg.emotion).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _emotionColor(msg.emotion).withOpacity(0.6),
                    width: 0.8,
                  ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 4,
            ),
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
                  "Buraya yazdığın mesajlar duygusal olarak analiz edilecek. "
                  "Şimdilik analizler demo (mock), backend hazır olduğunda gerçek modele bağlanacak.",
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              color: scaffoldBg,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
          ),
          // Alt input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceVariant.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Bugün nasılsın, neler yaşadın?",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: IconButton(
                    onPressed: _isSending ? null : _sendMessage,
                    icon:
                        _isSending
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.send_rounded),
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
