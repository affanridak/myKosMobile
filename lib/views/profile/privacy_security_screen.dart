import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'profile_change_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'device_access_screen.dart';
import '../../controllers/privacy_security_controller.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final PrivacySecurityController controller = Get.put(
      PrivacySecurityController(),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privasi & Keamanan',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle(context, 'Keamanan Akun'),
          _buildMenuTile(
            context,
            'Ubah Password',
            Icons.lock_outline,
            () => Get.to(() => const ProfileChangePasswordScreen()),
          ),
          Obx(
            () => _buildSwitchTile(
              context,
              'Autentikasi Biometrik',
              Icons.fingerprint,
              controller.isBiometricEnabled.value,
              (value) => controller.toggleBiometric(value),
            ),
          ),
          Obx(
            () => _buildSwitchTile(
              context,
              'Kunci Aplikasi',
              Icons.lock_clock_outlined,
              controller.isAppLockEnabled.value,
              (value) => controller.toggleAppLock(value),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Privasi Data'),
          _buildMenuTile(
            context,
            'Kebijakan Privasi',
            Icons.privacy_tip_outlined,
            () => Get.to(() => const PrivacyPolicyScreen()),
          ),
          _buildMenuTile(
            context,
            'Kelola Akses Perangkat',
            Icons.devices_other_outlined,
            () => Get.to(() => const DeviceAccessScreen()),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Lainnya'),
          _buildMenuTile(
            context,
            'Hapus Akun',
            Icons.delete_forever_outlined,
            () {
              Get.defaultDialog(
                title: 'Hapus Akun',
                middleText:
                    'Apakah Anda yakin ingin menghapus akun secara permanen? Tindakan ini tidak dapat dibatalkan.',
                textConfirm: 'Hapus',
                textCancel: 'Batal',
                confirmTextColor: theme.colorScheme.onError,
                buttonColor: theme.colorScheme.error,
                cancelTextColor: theme.textTheme.bodyMedium?.color,
              );
            },
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.titleMedium?.color,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = AppColors.primary,
    Color? textColor,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: textColor ?? theme.textTheme.bodyMedium?.color,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
