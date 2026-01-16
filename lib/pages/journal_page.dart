import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class JournalEntry {
  final String id;
  final DateTime date;
  final String text;
  final XFile? image;
  final String? mood; // Opsiyonel mood seçimi

  JournalEntry({
    String? id,
    required this.date,
    required this.text,
    this.image,
    this.mood,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<JournalEntry> _entries = [];
  final ImagePicker _picker = ImagePicker();

  // Mood seçenekleri
  final List<Map<String, dynamic>> _moods = [
    {"emoji": "😊", "label": "Mutlu", "color": Colors.green},
    {"emoji": "😢", "label": "Üzgün", "color": Colors.blue},
    {"emoji": "😰", "label": "Kaygılı", "color": Colors.orange},
    {"emoji": "😠", "label": "Sinirli", "color": Colors.red},
    {"emoji": "😐", "label": "Nötr", "color": Colors.grey},
  ];

  Future<void> _openAddEntrySheet() async {
    final TextEditingController textController = TextEditingController();
    XFile? selectedImage;
    String? selectedMood;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Başlık
                    const Text(
                      "Yeni Günlük Kaydı",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bugün nasıl hissediyorsun?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mood seçimi
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _moods.map((mood) {
                              final isSelected = selectedMood == mood["label"];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      selectedMood =
                                          isSelected ? null : mood["label"];
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? (mood["color"] as Color)
                                                  .withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? mood["color"] as Color
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          mood["emoji"],
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          mood["label"],
                                          style: TextStyle(
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metin alanı
                    TextField(
                      controller: textController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: "Bugün neler yaşadın? Duygularını yaz...",
                        filled: true,
                        fillColor: Theme.of(
                          ctx,
                        ).colorScheme.surfaceVariant.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Fotoğraf ekleme
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final img = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 70,
                            );
                            if (img != null) {
                              setModalState(() => selectedImage = img);
                            }
                          },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text("Fotoğraf ekle"),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final img = await _picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 70,
                            );
                            if (img != null) {
                              setModalState(() => selectedImage = img);
                            }
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text("Çek"),
                        ),
                        if (selectedImage != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ],
                    ),

                    // Seçilen fotoğraf önizleme
                    if (selectedImage != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selectedImage!.path),
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Kaydet butonu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          final text = textController.text.trim();
                          if (text.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text("Lütfen bir şeyler yaz"),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _entries.insert(
                              0,
                              JournalEntry(
                                date: DateTime.now(),
                                text: text,
                                image: selectedImage,
                                mood: selectedMood,
                              ),
                            );
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          "Kaydı Ekle",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _deleteEntry(JournalEntry entry) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Kaydı Sil"),
            content: const Text(
              "Bu günlük kaydını silmek istediğine emin misin?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("İptal"),
              ),
              FilledButton(
                onPressed: () {
                  setState(() => _entries.remove(entry));
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Sil"),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return "Bugün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else if (diff.inDays == 1) {
      return "Dün";
    } else {
      return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
    }
  }

  Color _getMoodColor(String? mood) {
    final found = _moods.firstWhere(
      (m) => m["label"] == mood,
      orElse: () => {"color": Colors.grey},
    );
    return found["color"] as Color;
  }

  String _getMoodEmoji(String? mood) {
    final found = _moods.firstWhere(
      (m) => m["label"] == mood,
      orElse: () => {"emoji": "📝"},
    );
    return found["emoji"] as String;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: scheme.surface,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddEntrySheet,
          icon: const Icon(Icons.add),
          label: const Text("Yeni Kayıt"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.menu_book, color: scheme.primary, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    "Duygu Günlüğü",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Duygularını kaydet, kendini tanı",
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Liste
              Expanded(
                child:
                    _entries.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_stories_outlined,
                                size: 64,
                                color: scheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Henüz bir günlük kaydın yok",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sağ alttaki butona dokunarak başla",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: scheme.onSurfaceVariant.withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            return Dismissible(
                              key: Key(entry.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                _deleteEntry(entry);
                                return false;
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Tarih ve mood
                                      Row(
                                        children: [
                                          if (entry.mood != null) ...[
                                            Text(
                                              _getMoodEmoji(entry.mood),
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(entry.date),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (entry.mood != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getMoodColor(
                                                  entry.mood,
                                                ).withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                entry.mood!,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: _getMoodColor(
                                                    entry.mood,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Metin
                                      Text(
                                        entry.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),

                                      // Fotoğraf
                                      if (entry.image != null) ...[
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
