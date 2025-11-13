import 'dart:math';
import 'package:flutter/material.dart';

class TextAnalysisPage extends StatefulWidget {
  const TextAnalysisPage({super.key});

  @override
  State<TextAnalysisPage> createState() => _TextAnalysisPageState();
}

class _TextAnalysisPageState extends State<TextAnalysisPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _emotion;
  double? _score;

  Future<void> _fakeAnalyze() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen bir metin yaz.")));
      return;
    }

    setState(() {
      _isLoading = true;
      _emotion = null;
      _score = null;
    });

    // Şimdilik backend yok, bu yüzden sahte analiz yapıyoruz
    await Future.delayed(const Duration(milliseconds: 1200));

    final emotions = ["POZİTİF", "NEGATİF", "NÖTR"];
    final random = Random();
    final label = emotions[random.nextInt(emotions.length)];
    final score = (0.70 + random.nextDouble() * 0.30); // 0.70–1.00 arası

    setState(() {
      _isLoading = false;
      _emotion = label;
      _score = score;
    });
  }

  Color _emotionColor() {
    switch (_emotion) {
      case "POZİTİF":
        return const Color(0xFF4CAF50);
      case "NEGATİF":
        return const Color(0xFFF44336);
      case "NÖTR":
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF7B5CFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Metin Analizi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Duygularını, düşüncelerini yaz. Şimdilik sahte analiz ama mantık aynı 😊",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _textController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText:
                              "Örnek: Bugün biraz kaygılıyım ama toparlayacağım...",
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _fakeAnalyze,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text("Analiz Et (Mock)"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_emotion != null && _score != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _emotionColor().withOpacity(0.09),
                            border: Border.all(
                              color: _emotionColor().withOpacity(0.6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Analiz Sonucu",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Duygu: $_emotion",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _emotionColor(),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Güven: ${(_score! * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else
                        const Text(
                          "Analiz sonucu burada görünecek.",
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
