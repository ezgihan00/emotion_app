import 'dart:async';
import 'package:flutter/material.dart';

class VoiceAnalysisPage extends StatefulWidget {
  const VoiceAnalysisPage({super.key});

  @override
  State<VoiceAnalysisPage> createState() => _VoiceAnalysisPageState();
}

enum RecordingState { idle, recording, analyzing }

class _VoiceAnalysisPageState extends State<VoiceAnalysisPage>
    with SingleTickerProviderStateMixin {
  RecordingState _state = RecordingState.idle;
  int _seconds = 0;
  Timer? _timer;
  String? _resultText;
  String? _resultEmotion;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _state = RecordingState.recording;
      _seconds = 0;
      _resultText = null;
      _resultEmotion = null;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _state = RecordingState.analyzing;
    });

    // Demo: 2 saniye bekle ve rastgele sonuç göster
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // Demo sonuçları
      final results = [
        {"text": "Konuşmanız sakin ve dengeli algılandı.", "emotion": "Nötr"},
        {"text": "Sesinizde mutluluk tonu tespit edildi.", "emotion": "Mutlu"},
        {
          "text": "Konuşmanızda hafif bir endişe sezildi.",
          "emotion": "Kaygılı",
        },
        {"text": "Ses tonunuz yorgun ve durgun algılandı.", "emotion": "Üzgün"},
      ];

      final random = results[DateTime.now().second % results.length];

      setState(() {
        _state = RecordingState.idle;
        _resultText = random["text"];
        _resultEmotion = random["emotion"];
      });
    });
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, "0");
    final s = (totalSeconds % 60).toString().padLeft(2, "0");
    return "$m:$s";
  }

  Color _micColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (_state) {
      case RecordingState.recording:
        return const Color(0xFFF44336);
      case RecordingState.analyzing:
        return Colors.orange;
      case RecordingState.idle:
      default:
        return scheme.primary;
    }
  }

  Color _emotionColor(String? emotion) {
    switch (emotion) {
      case "Mutlu":
        return Colors.green;
      case "Üzgün":
        return Colors.blue;
      case "Kaygılı":
        return Colors.orange;
      case "Sinirli":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _state == RecordingState.recording;
    final isAnalyzing = _state == RecordingState.analyzing;
    final micColor = _micColor(context);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.mic, color: scheme.primary, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    "Ses Analizi",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Konuşmanı kaydet, ses tonundan duygunu analiz edelim",
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),

              // Demo uyarısı
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Bu özellik şu an demo modunda çalışıyor. Gerçek ses analizi yakında eklenecek.",
                        style: TextStyle(fontSize: 12, color: scheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ana içerik
              Expanded(
                child: Column(
                  children: [
                    // Kayıt kartı
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Durum metni
                              Text(
                                isRecording
                                    ? "Kaydediliyor..."
                                    : isAnalyzing
                                    ? "Analiz ediliyor..."
                                    : "Hazır",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: micColor,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Zamanlayıcı
                              Text(
                                _formatTime(_seconds),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Dalga animasyonu
                              SizedBox(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(16, (index) {
                                    return AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        final baseHeight =
                                            isRecording ? 50.0 : 20.0;
                                        final variation =
                                            isRecording
                                                ? (index % 4 + 1) *
                                                    8.0 *
                                                    _pulseController.value
                                                : (index % 3) * 5.0;
                                        final height = baseHeight + variation;

                                        return AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          width: 5,
                                          height: height.clamp(10.0, 60.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: micColor.withOpacity(
                                              isRecording ? 0.9 : 0.3,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mikrofon butonu
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          if (_state == RecordingState.idle) {
                            _startRecording();
                          } else if (_state == RecordingState.recording) {
                            _stopRecording();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: micColor,
                            boxShadow: [
                              BoxShadow(
                                color: micColor.withOpacity(0.4),
                                blurRadius: isRecording ? 24 : 12,
                                spreadRadius: isRecording ? 4 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isRecording
                          ? "Durdurmak için mikrofona dokun"
                          : isAnalyzing
                          ? "Lütfen bekle..."
                          : "Başlamak için mikrofona dokun",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sonuç
                    if (_resultText != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: _emotionColor(_resultEmotion).withOpacity(0.1),
                          border: Border.all(
                            color: _emotionColor(
                              _resultEmotion,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            if (_resultEmotion != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: _emotionColor(_resultEmotion),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _resultEmotion!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            Text(
                              _resultText!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
