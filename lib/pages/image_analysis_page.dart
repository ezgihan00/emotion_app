import 'package:flutter/material.dart';

class ImageAnalysisPage extends StatefulWidget {
  const ImageAnalysisPage({super.key});

  @override
  State<ImageAnalysisPage> createState() => _ImageAnalysisPageState();
}

class _ImageAnalysisPageState extends State<ImageAnalysisPage> {
  bool _isAnalyzing = false;
  String? _resultText;

  Future<void> _mockOpenCamera() async {
    setState(() {
      _isAnalyzing = true;
      _resultText = null;
    });

    // Şimdilik sadece "kamera açıldı + analiz yapıldı" rolü yapıyoruz
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAnalyzing = false;
      _resultText =
          "Şimdilik demo: Yüz ifadesi 'Mutlu' gibi görünüyor 😊\nGerçekte burada kamera görüntüsünden model çalışacak.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Görüntü Analizi",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Yüz ifadesiyle duygu analizi için kamera/videoyu burada kullanacağız.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black12,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.videocam_outlined,
                              size: 72,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _mockOpenCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            _isAnalyzing
                                ? "Analiz ediliyor..."
                                : "Kamerayı Aç (Demo)",
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_resultText != null)
                        Text(
                          _resultText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        )
                      else
                        const Text(
                          "Kamerayı açtığında burada yüz ifadesi analizi sonucu görünecek.",
                          textAlign: TextAlign.center,
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
