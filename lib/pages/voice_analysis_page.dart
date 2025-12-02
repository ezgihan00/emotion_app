import 'dart:async';
import 'package:flutter/material.dart';

class VoiceAnalysisPage extends StatefulWidget {
  const VoiceAnalysisPage({super.key});

  @override
  State<VoiceAnalysisPage> createState() => _VoiceAnalysisPageState();
}

enum RecordingState { idle, recording, analyzing }

class _VoiceAnalysisPageState extends State<VoiceAnalysisPage> {
  RecordingState _state = RecordingState.idle;
  int _seconds = 0;
  Timer? _timer;
  String? _resultText;

  void _startRecording() {
    setState(() {
      _state = RecordingState.recording;
      _seconds = 0;
      _resultText = null;
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

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _state = RecordingState.idle;
        _resultText =
            "Demo sonuç: Konuşma sakin ve orta düzeyde pozitif algılandı.\n"
            "Gerçekte burada ses → metin → duygu analizi pipeline'ı çalışacak.";
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _state == RecordingState.recording;
    final isAnalyzing = _state == RecordingState.analyzing;
    final micColor = _micColor(context);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ses Analizi",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Konuşmanı kaydet, sistem ses tonuna göre duygunu tahmin etsin. "
                "Şimdilik sadece demo akışını gösteriyoruz.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isRecording
                                    ? "Kaydediliyor..."
                                    : isAnalyzing
                                    ? "Analiz ediliyor..."
                                    : "Hazır",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: micColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(_seconds),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(12, (index) {
                                  final baseHeight = isRecording ? 40.0 : 20.0;
                                  final extra =
                                      isRecording
                                          ? (index % 4) * 10.0
                                          : (index % 3) * 5.0;
                                  final height = baseHeight + extra;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    width: 6,
                                    height: height,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: micColor.withOpacity(
                                        isRecording ? 0.9 : 0.4,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: micColor,
                            boxShadow: [
                              BoxShadow(
                                color: micColor.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRecording
                          ? "Durdurmak için mikrofona tekrar dokun."
                          : "Konuşmaya başlamak için mikrofona dokun.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (_resultText != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Text(
                          _resultText!,
                          style: const TextStyle(fontSize: 14),
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
