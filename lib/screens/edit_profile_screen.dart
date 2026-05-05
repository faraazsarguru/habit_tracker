import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user logged in';

      final newName = _nameCtrl.text.trim();
      if (newName.isNotEmpty) {
        await AuthService.updateProfile(name: newName);
      }

      await user.reload();

      if (mounted) {
        setState(() {
          _success = 'Profile updated successfully!';
        });
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;
    final user = FirebaseAuth.instance.currentUser;

    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final textPrimary = isDark ? Colors.white : const Color(0xFF121212);
    final textSecondary = isDark ? Colors.white38 : const Color(0xFF888888);
    final inputBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
            style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _sectionTitle('Display Name', textSecondary),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                style: TextStyle(color: textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Email', textSecondary),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  user?.email ?? '',
                  style: TextStyle(color: textSecondary, fontSize: 15),
                ),
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      textAlign: TextAlign.center),
                ),
              if (_success != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                  ),
                  child: Text(_success!,
                      style: const TextStyle(color: Color(0xFF00E676), fontSize: 13),
                      textAlign: TextAlign.center),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: const Color(0xFF0A0A0A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A0A0A)),
                          ),
                        )
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) => Text(
        title,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5),
      );
}
