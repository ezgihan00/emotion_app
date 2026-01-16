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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final data = await AuthApi.getMe();
    if (mounted) {
      setState(() {
        user = data;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    // Onay dialogu
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Çıkış Yap"),
            content: const Text(
              "Hesabından çıkış yapmak istediğine emin misin?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("İptal"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Çıkış Yap"),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      await AuthApi.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false, // Tüm route'ları temizle
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: scheme.surface,
        body:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _loadUser,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        Text(
                          "Uygulama tercihlerini buradan yönetebilirsin.",
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 👤 Kullanıcı Kartı
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?["username"] ?? "Kullanıcı",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user?["email"] ?? "",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          "MoodMind Kullanıcısı",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: scheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // TODO: Profil düzenleme
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Yakında eklenecek!"),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          "Genel Ayarlar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ⚙️ Ayarlar Kartı
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
                                secondary: const Icon(
                                  Icons.notifications_outlined,
                                ),
                                value: _notificationsEnabled,
                                onChanged: (val) {
                                  setState(() => _notificationsEnabled = val);
                                },
                              ),
                              const Divider(height: 0),
                              SwitchListTile(
                                title: const Text("Koyu Tema"),
                                subtitle: const Text(
                                  "Göz yormayan koyu görünüm",
                                ),
                                secondary: Icon(
                                  _darkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode_outlined,
                                ),
                                value: _darkMode,
                                onChanged: (val) {
                                  setState(() => _darkMode = val);
                                  widget.onThemeChanged(val);
                                },
                              ),
                              const Divider(height: 0),
                              ListTile(
                                leading: const Icon(Icons.language_outlined),
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
                                      child: Text("Türkçe"),
                                    ),
                                    DropdownMenuItem(
                                      value: "en",
                                      child: Text("English"),
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
                        Text(
                          "Gizlilik & Hesap",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 🔒 Gizlilik Kartı
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.shield_outlined),
                                title: const Text("Veri Kullanımı"),
                                subtitle: const Text(
                                  "Duygu analizleri anonim tutulur",
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // TODO: Veri kullanımı detay sayfası
                                },
                              ),
                              const Divider(height: 0),
                              ListTile(
                                leading: const Icon(Icons.description_outlined),
                                title: const Text("Aydınlatma Metni"),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // TODO: Aydınlatma metni sayfası
                                },
                              ),
                              const Divider(height: 0),
                              ListTile(
                                leading: Icon(
                                  Icons.logout,
                                  color: scheme.error,
                                ),
                                title: Text(
                                  "Çıkış Yap",
                                  style: TextStyle(color: scheme.error),
                                ),
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 📱 Versiyon bilgisi
                        Center(
                          child: Text(
                            "MoodMind v1.0.0",
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
