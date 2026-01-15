import 'package:flutter/material.dart';
import '../services/auth_api.dart';
import 'login_page.dart';

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
  bool _notificationsEnabled = true;
  late bool _darkMode;
  String _language = "tr";

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await AuthApi.getMe();
    setState(() => user = data);
  }

  Future<void> _logout() async {
    await AuthApi.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: scheme.surface,
        body:
            user == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Profil",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Uygulama tercihlerini buradan yönetebilirsin.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      // 👤 Kullanıcı Kartı
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: scheme.primary.withOpacity(
                                  0.15,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 32,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user!["username"],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user!["email"],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "MoodMind Kullanıcısı ",
                                      style: TextStyle(fontSize: 13),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ⚙️ Ayarlar
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text("Bildirimler"),
                              subtitle: const Text(
                                "Günlük hatırlatmalar ve öneriler",
                              ),
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
                                widget.onThemeChanged(val); // 🌙 Tema değişir
                              },
                            ),
                            const Divider(height: 0),
                            ListTile(
                              title: const Text("Dil"),
                              subtitle: Text(
                                _language == "tr" ? "Türkçe" : "English",
                              ),
                              trailing: DropdownButton<String>(
                                value: _language,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: "tr",
                                    child: Text("TR"),
                                  ),
                                  DropdownMenuItem(
                                    value: "en",
                                    child: Text("EN"),
                                  ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🔒 Gizlilik & Logout
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
                                "Duygu analizleri anonim tutulur.",
                              ),
                            ),
                            const Divider(height: 0),
                            ListTile(
                              leading: const Icon(Icons.description_outlined),
                              title: const Text("Aydınlatma Metni"),
                            ),
                            const Divider(height: 0),
                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text(
                                "Çıkış Yap",
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: _logout, // 🔥 GERÇEK LOGOUT
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
