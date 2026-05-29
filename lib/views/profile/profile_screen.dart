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
import '../report/report_screen.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Akun Saya', style: theme.textTheme.titleLarge),
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
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            if (_phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(_phone, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
            const SizedBox(height: 32),
            _buildMenuTile(
              context,
              'Edit Profil',
              Icons.person_outline,
              () async {
                await Get.to(
                  () => const EditProfileScreen(),
                  transition: Transition.fadeIn,
                );
                _loadUser();
              },
            ),
            _buildMenuTile(
              context,
              'Riwayat Transaksi',
              Icons.history,
              () => Get.to(
                () => const TransactionHistoryScreen(),
                transition: Transition.fadeIn,
              ),
            ),
            _buildMenuTile(
              context,
              'Laporan Masalah',
              Icons.report_problem_outlined,
              () => Get.to(
                () => const ReportScreen(),
                transition: Transition.fadeIn,
              ),
            ),
            _buildMenuTile(
              context,
              'Pengaturan',
              Icons.settings_outlined,
              () =>
                  Get.to(() => SettingsScreen(), transition: Transition.fadeIn),
            ),
            _buildMenuTile(
              context,
              'Pusat Bantuan',
              Icons.help_outline,
              () => Get.to(
                () => const HelpCenterScreen(),
                transition: Transition.fadeIn,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.04 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(
                      (0.02 * 255).round(),
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Material(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor:
                            theme.dialogTheme.backgroundColor ??
                            theme.cardColor,
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
                                  color: theme.colorScheme.error.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.logout,
                                  color: theme.colorScheme.error,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Keluar Akun',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Apakah Anda yakin ingin keluar dari akun ini?',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        'Batal',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                      child: Text(
                                        'Keluar',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: theme.colorScheme.onError,
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
                      color: theme.colorScheme.error.withAlpha(
                        (0.1 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.logout, color: theme.colorScheme.error),
                  ),
                  title: Text(
                    'Keluar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? trailingText,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha((0.02 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: trailingText != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(trailingText, style: theme.textTheme.bodySmall),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ],
                )
              : Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
        ),
      ),
    );
  }
}
