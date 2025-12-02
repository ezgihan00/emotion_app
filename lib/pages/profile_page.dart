import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;
  final void Function(bool) onThemeChanged;

  const ProfilePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool _notificationsEnabled;
  late bool _darkMode;
  String _language = "tr";

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = true;
    _darkMode = widget.isDarkMode; // başlangıçta üstten gelen değer
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profil",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Uygulama tercihlerini buradan yönetebilirsin.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: scheme.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kullanıcı Adı",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "user@example.com",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "MoodMind Beta Kullanıcısı",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Genel Ayarlar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("Bildirimler"),
                      subtitle: const Text("Günlük hatırlatmalar ve öneriler"),
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                      },
                    ),
                    const Divider(height: 0),
                    SwitchListTile(
                      title: const Text("Koyu Tema"),
                      subtitle: const Text("Göz yormayan koyu görünüm"),
                      value: _darkMode,
                      onChanged: (val) {
                        setState(() => _darkMode = val);
                        widget.onThemeChanged(val); // 🔥 asıl değişim burada
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      title: const Text("Dil"),
                      subtitle: Text(
                        _language == "tr" ? "Türkçe" : "İngilizce",
                      ),
                      trailing: DropdownButton<String>(
                        value: _language,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: "tr", child: Text("TR")),
                          DropdownMenuItem(value: "en", child: Text("EN")),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _language = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Gizlilik",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text("Veri Kullanımı"),
                      subtitle: const Text(
                        "Duygu analizleri araştırma için anonim tutulur.",
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text("Aydınlatma Metni"),
                      onTap: () {},
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text(
                        "Çıkış Yap",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
