import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAnalysisPage extends StatefulWidget {
  const ImageAnalysisPage({super.key});

  @override
  State<ImageAnalysisPage> createState() => _ImageAnalysisPageState();
}

class _ImageAnalysisPageState extends State<ImageAnalysisPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _resultText;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file == null) return;

    setState(() {
      _selectedImage = file;
      _resultText = null;
    });
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _resultText = null;
    });

    // Şimdilik demo analiz
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _resultText =
          "Demo sonuç: Görüntüde belirgin bir risk unsuru tespit edilmedi.\n"
          "Gerçekte burada yüz ifadesi / ortam analizi gibi modeller çalışacak.";
    });
  }

  @override
  Widget build(BuildContext context) {
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
                "Görüntü Analizi",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Fotoğraf çek ya da galeriden seç; ileride yüz ifadesi ve ortam analizi burada yapılacak.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 4,
                        child: Center(
                          child:
                              _selectedImage == null
                                  ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      "Henüz bir görüntü seçmedin.\n"
                                      "Aşağıdaki butonlardan fotoğraf çekebilir "
                                      "veya galeriden seçebilirsin.",
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera),
                          label: const Text("Fotoğraf çek"),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text("Galeriden seç"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed:
                          (_selectedImage == null || _isAnalyzing)
                              ? null
                              : _analyzeImage,
                      child:
                          _isAnalyzing
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text("Görüntüyü Analiz Et (Demo)"),
                    ),
                    const SizedBox(height: 12),
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
