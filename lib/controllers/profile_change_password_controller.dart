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
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPwd.length < 6) {
      Get.snackbar(
        'Error',
        'Password baru minimal 6 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPwd != confirmPwd) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
        Get.snackbar(
          'Sukses',
          res.message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          res.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan jaringan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
