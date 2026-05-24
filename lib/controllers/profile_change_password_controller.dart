import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ProfileChangePasswordController extends GetxController {
  var showOldPassword = false.obs;
  var showNewPassword = false.obs;
  var showConfirmPassword = false.obs;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;

  void toggleOldPassword() => showOldPassword.value = !showOldPassword.value;
  void toggleNewPassword() => showNewPassword.value = !showNewPassword.value;
  void toggleConfirmPassword() =>
      showConfirmPassword.value = !showConfirmPassword.value;

  Future<void> changePassword() async {
    final oldPwd = oldPasswordController.text.trim();
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      final theme = Theme.of(Get.context!);
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: theme.colorScheme.error,
        colorText: theme.colorScheme.onError,
      );
      return;
    }

    if (newPwd.length < 6) {
      final theme = Theme.of(Get.context!);
      Get.snackbar(
        'Error',
        'Password baru minimal 6 karakter',
        backgroundColor: theme.colorScheme.error,
        colorText: theme.colorScheme.onError,
      );
      return;
    }

    if (newPwd != confirmPwd) {
      final theme = Theme.of(Get.context!);
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak cocok',
        backgroundColor: theme.colorScheme.error,
        colorText: theme.colorScheme.onError,
      );
      return;
    }

    try {
      isLoading.value = true;

      final res = await AuthService().changePasswordAuthenticated(
        oldPwd,
        newPwd,
      );
      if (res.success) {
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        Get.back();
        final theme = Theme.of(Get.context!);
        Get.snackbar(
          'Sukses',
          res.message,
          backgroundColor: theme.colorScheme.secondary,
          colorText: theme.colorScheme.onSecondary,
        );
      } else {
        final theme = Theme.of(Get.context!);
        Get.snackbar(
          'Error',
          res.message,
          backgroundColor: theme.colorScheme.error,
          colorText: theme.colorScheme.onError,
        );
      }
    } catch (e) {
      final theme = Theme.of(Get.context!);
      Get.snackbar(
        'Error',
        'Terjadi kesalahan jaringan',
        backgroundColor: theme.colorScheme.error,
        colorText: theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
