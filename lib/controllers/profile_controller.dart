import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  // can be File (mobile/desktop) or Uint8List (web)
  final pickedImage = Rxn<dynamic>();
  final avatarUrl = ''.obs;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await AuthService().getUser();
    nameController.text = user['name'] ?? '';
    emailController.text = user['email'] ?? '';
    phoneController.text = user['phone'] ?? '';
    avatarUrl.value = user['avatar'] ?? '';

    // Prefer a local preview if one exists so the updated image stays visible
    // even when the remote avatar URL is not reachable from the device.
    final email = (user['email'] ?? '').toString().toLowerCase();
    final localKey = email.isNotEmpty ? 'avatar_local:$email' : 'avatar_local';
    if (prefs.getString(localKey) != null) {
      try {
        final String b64 = prefs.getString(localKey)!;
        final bytes = base64Decode(b64);
        pickedImage.value = bytes;
      } catch (e) {
        // ignore decode errors
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        pickedImage.value = bytes;
        try {
          final email = prefs.getString('email') ?? '';
          final localKey = email.isNotEmpty
              ? 'avatar_local:${email.toLowerCase()}'
              : 'avatar_local';
          await prefs.setString(localKey, base64Encode(bytes));
        } catch (e) {
          // Ignore prefs write errors on web.
        }
      } else {
        final file = File(image.path);
        pickedImage.value = file;
        try {
          final bytes = await file.readAsBytes();
          final email = prefs.getString('email') ?? '';
          final localKey = email.isNotEmpty
              ? 'avatar_local:${email.toLowerCase()}'
              : 'avatar_local';
          await prefs.setString(localKey, base64Encode(bytes));
        } catch (e) {
          // Ignore prefs write errors on mobile.
        }
      }
    }
  }

  Future<AuthResult> updateProfile({
    required String name,
    String? phone,
  }) async {
    isLoading.value = true;
    try {
      final res = await AuthService().updateProfile(
        name: name,
        phone: phone,
        avatar: pickedImage.value,
      );
      isLoading.value = false;
      if (res.success) {
        // refresh local data
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('name', name);
        if (phone != null) prefs.setString('phone', phone);
        // update avatar from normalized prefs data
        final user = await AuthService().getUser();
        avatarUrl.value = user['avatar'] ?? '';
      }
      return res;
    } catch (e) {
      isLoading.value = false;
      return AuthResult(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
