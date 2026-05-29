import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class DeviceAccessController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = true.obs;
  var devices = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    isLoading(true);
    try {
      final data = await _authService.getActiveDevices();
      devices.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<void> revokeDevice(int tokenId) async {
    // Optimistic UI update or wait for API
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final success = await _authService.revokeDevice(tokenId);
    Get.back(); // close dialog

    if (success) {
      devices.removeWhere((device) => device['id'] == tokenId);
      Get.snackbar(
        'Sukses',
        'Akses perangkat berhasil dicabut',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mencabut akses perangkat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
