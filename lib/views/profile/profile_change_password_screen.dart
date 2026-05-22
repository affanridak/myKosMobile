import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_inputs.dart';
import '../../controllers/profile_change_password_controller.dart';

class ProfileChangePasswordScreen extends StatelessWidget {
  const ProfileChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileChangePasswordController controller = Get.put(
      ProfileChangePasswordController(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Ubah Password',
          style: const TextStyle(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buat Password Baru',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan password baru Anda unik dan tidak mudah ditebak untuk menjaga keamanan akun Anda.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            Obx(
              () => _buildPasswordField(
                hint: 'Password Lama',
                isObscure: !controller.showOldPassword.value,
                onToggleVisibility: () => controller.toggleOldPassword(),
                textController: controller.oldPasswordController,
              ),
            ),
            Obx(
              () => _buildPasswordField(
                hint: 'Password Baru',
                isObscure: !controller.showNewPassword.value,
                onToggleVisibility: () => controller.toggleNewPassword(),
                textController: controller.newPasswordController,
              ),
            ),
            Obx(
              () => _buildPasswordField(
                hint: 'Konfirmasi Password Baru',
                isObscure: !controller.showConfirmPassword.value,
                onToggleVisibility: () => controller.toggleConfirmPassword(),
                textController: controller.confirmPasswordController,
              ),
            ),

            const SizedBox(height: 24),
            Obx(
              () => PrimaryButton(
                text: 'Simpan Perubahan',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  controller.changePassword();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
    TextEditingController? textController,
  }) {
    return CustomTextField(
      hint: hint,
      icon: Icons.lock_outline,
      isPassword: isObscure,
      showVisibilityToggle: true,
      onToggleVisibility: onToggleVisibility,
      controller: textController,
      onChanged: (_) {}, // Ini bisa dihubungkan ke Controller nanti
    );
  }
}
