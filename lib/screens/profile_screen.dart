import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

const _green = Color(0xFF00E676);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _displayName = user.displayName ?? 'User';
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.pushNamed(context, '/edit-profile');
    if (mounted && result == true) {
      _loadProfile();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'user@example.com';
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;

    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF121212);
    final textSecondary = isDark ? Colors.white38 : const Color(0xFF888888);
    final iconColor = isDark ? Colors.white54 : const Color(0xFF666666);
    final dividerColor = isDark ? Colors.white24 : const Color(0xFFCCCCCC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    Text(
                      _displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _sectionTitle('Account', color: textSecondary),
              const SizedBox(height: 12),
              _settingsItem(Icons.edit_outlined, 'Edit Profile', _openEditProfile,
                  iconColor: iconColor, textColor: textPrimary, cardBg: cardBg, dividerColor: dividerColor),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, color: iconColor, size: 20),
                    const SizedBox(width: 14),
                    Text('Dark Mode',
                        style: TextStyle(
                            fontSize: 15,
                            color: textPrimary,
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Switch(
                      value: isDark,
                      onChanged: (_) => themeService.toggleTheme(),
                      activeThumbColor: _green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle('App', color: textSecondary),
              const SizedBox(height: 12),
              _settingsItem(Icons.help_outline_rounded, 'Help & Support', () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: cardBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle_rounded,
                              color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('Habitzzz',
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    content: Text(
                      'For help contact - "9987055635"',
                      style: TextStyle(
                          color: textSecondary, fontSize: 14, height: 1.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK',
                            style: TextStyle(
                                color: _green, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              }, iconColor: iconColor, textColor: textPrimary, cardBg: cardBg, dividerColor: dividerColor),
              _settingsItem(Icons.info_outline_rounded, 'About Habitzzz', () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: cardBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle_rounded,
                              color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('Habitzzz',
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Habitzzz helps you build better habits and track your daily tasks with ease.',
                          style: TextStyle(
                              color: textSecondary, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Text('Made by the Habitzzz team.',
                            style: TextStyle(color: textSecondary, fontSize: 13)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close',
                            style: TextStyle(
                                color: _green, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              }, iconColor: iconColor, textColor: textPrimary, cardBg: cardBg, dividerColor: dividerColor),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/auth');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Log Out',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {required Color color}) => Text(
        title,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5),
      );

  Widget _settingsItem(IconData icon, String label, VoidCallback onTap,
      {required Color iconColor,
      required Color textColor,
      required Color cardBg,
      required Color dividerColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: dividerColor, size: 20),
          ],
        ),
      ),
    );
  }
}
