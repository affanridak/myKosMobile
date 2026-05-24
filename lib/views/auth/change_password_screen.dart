import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_inputs.dart';
import '../../controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthController authC = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ubah Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logos/logomykost.png', height: 120),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ubah Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hampir selesai! Silakan buat password baru Anda yang unik dan mudah diingat untuk mengamankan akun.',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: authC.newPassword,
                  obscureText: !_showPassword,
                  style: const TextStyle(),
                  decoration: InputDecoration(
                    hintText: 'Password Baru',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(
                        (0.5 * 255).round(),
                      ),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: theme.iconTheme.color,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: authC.confirmNewPassword,
                  obscureText: !_showConfirmPassword,
                  style: const TextStyle(),
                  decoration: InputDecoration(
                    hintText: 'Konfirmasi Password Baru',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(
                        (0.5 * 255).round(),
                      ),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_reset_outlined,
                      color: theme.iconTheme.color,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => PrimaryButton(
                  text: 'Simpan Password Baru',
                  isLoading: authC.isLoading.value,
                  onPressed: () => authC.changePassword(),
                ),
              ),
            ],
          ),
        ),
      ), // Penutup kurung untuk SafeArea yang sebelumnya hilang
    );
  }
}
