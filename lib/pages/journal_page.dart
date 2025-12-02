import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class JournalEntry {
  final DateTime date;
  final String text;
  final XFile? image;

  JournalEntry({required this.date, required this.text, this.image});
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<JournalEntry> _entries = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _openAddEntrySheet() async {
    final TextEditingController textController = TextEditingController();
    XFile? selectedImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(
                    "Yeni Günlük Kaydı",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Bugün neler yaşadın?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final img = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 70,
                          );
                          if (img == null) return;
                          setModalState(() => selectedImage = img);
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text("Fotoğraf ekle"),
                      ),
                      const SizedBox(width: 8),
                      if (selectedImage != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isEmpty) return;
                        setState(() {
                          _entries.add(
                            JournalEntry(
                              date: DateTime.now(),
                              text: text,
                              image: selectedImage,
                            ),
                          );
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: const Text("Kaydı Ekle"),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, "0")}."
        "${date.month.toString().padLeft(2, "0")}."
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return SafeArea(
      child: Scaffold(
        backgroundColor: scaffoldBg,
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddEntrySheet,
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Duygu Günlüğü",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Gün içinde hissettiklerini buraya yazabilir, istersen bir fotoğrafla "
                "beraber kaydedebilirsin.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _entries.isEmpty
                        ? const Center(
                          child: Text(
                            "Henüz bir günlük kaydın yok.\n"
                            "Sağ alttaki + butonuna dokunarak başlayabilirsin.",
                            textAlign: TextAlign.center,
                          ),
                        )
                        : ListView.builder(
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatDate(entry.date),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.text,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    if (entry.image != null) ...[
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(entry.image!.path),
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
