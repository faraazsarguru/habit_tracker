import 'package:flutter/material.dart';

const _green = Color(0xFF00E676);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              // Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: _green, width: 2),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 48, color: _green),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'User Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'user@example.com',
                      style: TextStyle(fontSize: 13, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _sectionTitle('Account'),
              const SizedBox(height: 12),
              _settingsItem(Icons.edit_outlined, 'Edit Profile', () {}),
              _settingsItem(
                  Icons.notifications_outlined, 'Notifications', () {}),
              _settingsItem(Icons.lock_outline_rounded, 'Privacy', () {}),
              const SizedBox(height: 20),
              _sectionTitle('App'),
              const SizedBox(height: 12),
              _settingsItem(
                  Icons.help_outline_rounded, 'Help & Support', () {}),
              _settingsItem(
                  Icons.info_outline_rounded, 'About Habitzzz', () {}),
              const SizedBox(height: 20),
              // Logout
              Container(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/auth'),
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

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 0.5),
      );

  Widget _settingsItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
