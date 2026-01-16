import 'package:flutter/material.dart';
import '../services/sentiment_api.dart';

class TextAnalysisPage extends StatefulWidget {
  const TextAnalysisPage({super.key});

  @override
  State<TextAnalysisPage> createState() => _TextAnalysisPageState();
}

class _Message {
  final bool isUser;
  final String? text; // user msg or welcome
  final Map<String, dynamic>? data; // backend JSON
  final String? error;

  _Message.user(this.text) : isUser = true, data = null, error = null;

  _Message.welcome(this.text) : isUser = false, data = null, error = null;

  _Message.bot(this.data) : isUser = false, text = null, error = null;

  _Message.err(this.error) : isUser = false, text = null, data = null;
}

class _TextAnalysisPageState extends State<TextAnalysisPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _Message.welcome(
        "Merhaba.\n\nNasıl hissettiğini yazabilirsin; ben de analiz edip sana yanıt döneceğim.",
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _loading = true;
      _messages.add(_Message.user(text));
    });
    _scrollToBottom();

    try {
      final data = await SentimentApi.hybridChat(message: text);
      if (!mounted) return;
      setState(() => _messages.add(_Message.bot(data)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(_Message.err(e.toString())));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  // ---------- Safe helpers ----------
  String? _asString(dynamic v) => v == null ? null : v.toString();

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return 0.0;
  }

  bool _asBool(dynamic v) => v is bool ? v : false;

  // Sentiment pick: sentiment -> hf_result -> ml_result
  ({String label, double score, String? source}) _pickSentiment(
    Map<String, dynamic> data,
  ) {
    // 1) sentiment
    final s = _asMap(data["sentiment"]);
    if (s != null) {
      final l = _asString(s["label"]);
      final sc = _asDouble(s["score"]);
      if (l != null && l.trim().isNotEmpty) {
        return (label: l, score: sc, source: _asString(data["source"]));
      }
    }

    // 2) hf_result
    final hf = _asMap(data["hf_result"]);
    if (hf != null) {
      final l = _asString(hf["label"]);
      final sc = _asDouble(hf["score"]);
      if (l != null && l.trim().isNotEmpty) {
        return (label: l, score: sc, source: _asString(data["source"]));
      }
    }

    // 3) ml_result
    final ml = _asMap(data["ml_result"]);
    if (ml != null) {
      final l = _asString(ml["label"]);
      final sc = _asDouble(ml["score"]);
      if (l != null && l.trim().isNotEmpty) {
        return (label: l, score: sc, source: _asString(data["source"]));
      }
    }

    return (label: "bilinmiyor", score: 0.0, source: _asString(data["source"]));
  }

  Color _labelColor(String label) {
    switch (label.toLowerCase()) {
      case "pozitif":
      case "positive":
        return const Color(0xFF4CAF50);
      case "negatif":
      case "negative":
        return const Color(0xFFE53935);
      case "nötr":
      case "notr":
      case "neutral":
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case "pozitif":
      case "positive":
        return Icons.sentiment_very_satisfied;
      case "negatif":
      case "negative":
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _header(cs),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _bubble(_messages[i], cs),
              ),
            ),
            _input(cs),
          ],
        ),
      ),
    );
  }

  Widget _header(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, color: cs.primary, size: 26),
              const SizedBox(width: 8),
              Text(
                "Duygu Analizi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Telkin + Hibrit Model (HF + ML)",
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _input(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: "Mesajını yaz...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _loading ? null : _send,
            backgroundColor: cs.primary,
            child:
                _loading
                    ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                    : Icon(Icons.send_rounded, color: cs.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _bubble(_Message msg, ColorScheme cs) {
    if (msg.isUser) return _userBubble(msg.text ?? "", cs);
    if (msg.error != null) return _errorBubble(msg.error!, cs);
    if (msg.data != null) return _botBubble(msg.data!, cs);
    return _welcomeBubble(msg.text ?? "", cs);
  }

  Widget _userBubble(String text, ColorScheme cs) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(text, style: TextStyle(color: cs.onPrimary, fontSize: 15)),
      ),
    );
  }

  Widget _welcomeBubble(String text, ColorScheme cs) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: cs.onSurface, fontSize: 15, height: 1.5),
        ),
      ),
    );
  }

  Widget _errorBubble(String error, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: cs.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _botBubble(Map<String, dynamic> data, ColorScheme cs) {
    // TELKIN: sadece backend "response" alanından
    final botText = _asString(data["response"]);
    final technique = _asString(data["technique"]);
    final isCrisis = _asBool(data["is_crisis"]);

    final pick = _pickSentiment(data);
    final color = _labelColor(pick.label);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telkin kartı (backend'den gelmezse gösterme)
          if (botText != null && botText.trim().isNotEmpty)
            _telkinCard(botText, technique, isCrisis, cs)
          else
            _telkinMissing(cs),

          const SizedBox(height: 10),

          _sentimentCard(pick.label, pick.score, pick.source, color, cs),
        ],
      ),
    );
  }

  Widget _telkinMissing(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: cs.onSurfaceVariant, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Backend telkin yanıtı (response) göndermedi.",
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _telkinCard(
    String text,
    String? technique,
    bool crisis,
    ColorScheme cs,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                "Destek Yanıtı",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              if (technique != null && technique.trim().isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    technique,
                    style: TextStyle(fontSize: 10, color: cs.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(fontSize: 15, height: 1.6, color: cs.onSurface),
          ),
          if (crisis) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: cs.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Kendine zarar verme düşüncelerin varsa lütfen profesyonel destek al.",
                      style: TextStyle(color: cs.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sentimentCard(
    String label,
    double score,
    String? source,
    Color color,
    ColorScheme cs,
  ) {
    final pct = (score.clamp(0.0, 1.0) * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // başlık
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_labelIcon(label), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Final Sonuç",
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  "$pct%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // progress
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 10),
          // meta
          Row(
            children: [
              Text("Label", style: TextStyle(color: cs.onSurfaceVariant)),
              const Spacer(),
              Text(
                label.toLowerCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("Score", style: TextStyle(color: cs.onSurfaceVariant)),
              const Spacer(),
              Text(
                "$pct%",
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("Source", style: TextStyle(color: cs.onSurfaceVariant)),
              const Spacer(),
              Text(
                source ?? "-",
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
