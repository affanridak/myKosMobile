import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'transaction_history_screen.dart';
import 'help_center_screen.dart';
import '../favorite/favorite_screen.dart';
import 'settings_screen.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _avatar = '';
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getUser();
    final prefs = await SharedPreferences.getInstance();
    Uint8List? localAvatarBytes;
    final email = (user['email'] ?? '').toString().toLowerCase();
    final localKey = email.isNotEmpty ? 'avatar_local:$email' : 'avatar_local';
    final localAvatar = prefs.getString(localKey);
    if (localAvatar != null && localAvatar.isNotEmpty) {
      try {
        localAvatarBytes = base64Decode(localAvatar);
      } catch (e) {
        localAvatarBytes = null;
      }
    }
    setState(() {
      _name = user['name'] ?? '';
      _email = user['email'] ?? '';
      _phone = user['phone'] ?? '';
      _avatar = user['avatar'] ?? '';
      _avatarBytes = localAvatarBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Akun Saya',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              backgroundImage: _avatarBytes != null
                  ? MemoryImage(_avatarBytes!)
                  : (_avatar.isNotEmpty ? NetworkImage(_avatar) : null),
              child: _avatarBytes == null && _avatar.isEmpty
                  ? Text(
                      _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (_phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _phone,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            _buildMenuTile(Icons.person_outline, 'Edit Profil', () async {
              await Get.to(
                () => const EditProfileScreen(),
                transition: Transition.fadeIn,
              );
              _loadUser();
            }),
            _buildMenuTile(
              Icons.history,
              'Riwayat Transaksi',
              () => Get.to(
                () => const TransactionHistoryScreen(),
                transition: Transition.fadeIn,
              ),
            ),
            _buildMenuTile(
              Icons.favorite_border,
              'Favorit',
              () => Get.to(
                () => const FavoriteScreen(),
                transition: Transition.fadeIn,
              ),
            ),
            _buildMenuTile(
              Icons.settings_outlined,
              'Pengaturan',
              () =>
                  Get.to(() => SettingsScreen(), transition: Transition.fadeIn),
            ),
            _buildMenuTile(
              Icons.help_outline,
              'Pusat Bantuan',
              () => Get.to(
                () => const HelpCenterScreen(),
                transition: Transition.fadeIn,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () {
                Get.dialog(
                  Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha((0.1 * 255).round()),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Keluar Akun',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Apakah Anda yakin ingin keluar dari akun ini?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  onPressed: () => Get.back(),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    await AuthService().logout();
                                    Get.offAll(
                                      () => LoginScreen(),
                                      transition: Transition.fadeIn,
                                    );
                                  },
                                  child: const Text(
                                    'Keluar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
