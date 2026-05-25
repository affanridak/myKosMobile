import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';
import '../views/main_layout.dart';
import '../views/auth/otp_screen.dart';
import '../views/auth/change_password_screen.dart';
import '../views/auth/login_screen.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final loginEmail = TextEditingController();
  final loginPassword = TextEditingController();
  final isLoading = false.obs;
  final recoveryEmail = ''.obs;

  final registerName = TextEditingController();
  final registerEmail = TextEditingController();
  final registerPassword = TextEditingController();
  final registerConfirmPassword = TextEditingController();

  final forgotEmail = TextEditingController();
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();
  final otp4 = TextEditingController();

  final newPassword = TextEditingController();
  final confirmNewPassword = TextEditingController();

  @override
  void onClose() {
    loginEmail.dispose();
    loginPassword.dispose();
    registerName.dispose();
    registerEmail.dispose();
    registerPassword.dispose();
    registerConfirmPassword.dispose();
    forgotEmail.dispose();
    otp1.dispose();
    otp2.dispose();
    otp3.dispose();
    otp4.dispose();
    newPassword.dispose();
    confirmNewPassword.dispose();
    super.onClose();
  }

  bool _isEmailValid(String email) {
    final regex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return regex.hasMatch(email);
  }

  void _showError(String message) {
    final theme = Theme.of(Get.context!);
    Get.snackbar(
      'Oops! Gagal',
      message,
      backgroundColor: theme.colorScheme.error,
      colorText: theme.colorScheme.onError,
      icon: Icon(
        Icons.error_outline,
        color: theme.colorScheme.onError,
        size: 28,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      snackPosition: SnackPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  void _showSuccess(String title, String message) {
    final theme = Theme.of(Get.context!);
    Get.snackbar(
      title,
      message,
      backgroundColor: theme.colorScheme.secondary,
      colorText: theme.colorScheme.onSecondary,
      icon: Icon(
        Icons.check_circle_outline,
        color: theme.colorScheme.onSecondary,
        size: 28,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      snackPosition: SnackPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
    );
  }

  Future<void> login() async {
    final email = loginEmail.text.trim();
    final pass = loginPassword.text;
    if (email.isEmpty || pass.isEmpty) {
      _showError('Email dan password harus diisi');
      return;
    }
    if (!_isEmailValid(email)) {
      _showError('Email tidak valid');
      return;
    }
    if (pass.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    try {
      isLoading.value = true;
      final res = await _authService.login(email, pass);
      isLoading.value = false;
      if (res.success) {
        await _authService.fetchAndSaveUserFromApi();
        loginEmail.clear();
        loginPassword.clear();
        Get.offAll(() => MainLayout());
        _showSuccess('Sukses Masuk', res.message);
      } else {
        _showError(res.message);
      }
    } catch (e) {
      isLoading.value = false;
      _showError('Terjadi kesalahan jaringan');
    }
  }

  Future<void> register() async {
    final name = registerName.text.trim();
    final email = registerEmail.text.trim();
    final pass = registerPassword.text;
    final confirm = registerConfirmPassword.text;
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showError('Semua bidang harus diisi');
      return;
    }
    if (!_isEmailValid(email)) {
      _showError('Email tidak valid');
      return;
    }
    if (pass.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }
    if (pass != confirm) {
      _showError('Password tidak cocok');
      return;
    }

    try {
      isLoading.value = true;
      final res = await _authService.register(name, email, pass);
      isLoading.value = false;
      if (res.success) {
        registerName.clear();
        registerEmail.clear();
        registerPassword.clear();
        registerConfirmPassword.clear();
        Get.back();
        _showSuccess('Berhasil Daftar', res.message);
      } else {
        _showError(res.message);
      }
    } catch (e) {
      isLoading.value = false;
      _showError('Terjadi kesalahan jaringan');
    }
  }

  void sendOtp() {
    final email = forgotEmail.text.trim();
    if (email.isEmpty) {
      _showError('Masukkan email terlebih dahulu');
      return;
    }
    if (!_isEmailValid(email)) {
      _showError('Email tidak valid');
      return;
    }
    () async {
      try {
        isLoading.value = true;
        final res = await _authService.sendOtp(email);
        isLoading.value = false;
        if (res.success) {
          recoveryEmail.value = email;
          Get.to(() => OtpScreen());
          _showSuccess('OTP Terkirim', res.message);
        } else {
          _showError(res.message);
        }
      } catch (e) {
        isLoading.value = false;
        _showError('Terjadi kesalahan jaringan');
      }
    }();
  }

  void verifyOtp() {
    final otp = otp1.text + otp2.text + otp3.text + otp4.text;
    if (otp.length != 4) {
      _showError('Masukkan kode 4 digit dengan benar');
      return;
    }
    () async {
      try {
        isLoading.value = true;
        final res = await _authService.verifyOtp(
          recoveryEmail.value.isEmpty
              ? forgotEmail.text.trim()
              : recoveryEmail.value,
          otp,
        );
        isLoading.value = false;
        if (res.success) {
          Get.to(() => ChangePasswordScreen());
          _showSuccess('Verifikasi Berhasil', res.message);
        } else {
          _showError(res.message);
        }
      } catch (e) {
        isLoading.value = false;
        _showError('Terjadi kesalahan jaringan');
      }
    }();
  }

  void changePassword() {
    final pass = newPassword.text;
    final confirm = confirmNewPassword.text;
    if (pass.isEmpty || confirm.isEmpty) {
      _showError('Semua bidang password harus diisi');
      return;
    }
    if (pass.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }
    if (pass != confirm) {
      _showError('Password baru dan konfirmasi tidak cocok');
      return;
    }
    () async {
      try {
        isLoading.value = true;
        final email = recoveryEmail.value.isEmpty
            ? forgotEmail.text.trim()
            : recoveryEmail.value;
        final res = await _authService.changePassword(email, pass);
        isLoading.value = false;
        if (res.success) {
          newPassword.clear();
          confirmNewPassword.clear();
          Get.offAll(() => LoginScreen());
          _showSuccess('Berhasil Ubah Password', res.message);
        } else {
          _showError(res.message);
        }
      } catch (e) {
        isLoading.value = false;
        _showError('Terjadi kesalahan jaringan');
      }
    }();
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('${_authService.baseUrl}/auth/google/mobile?platform=mobile'),
        headers: {'Accept': 'application/json', 'User-Agent': 'FlutterApp'},
      );
      isLoading.value = false;

      final data = jsonDecode(response.body);
      final googleUrl = data['url'] as String;

      final result = await FlutterWebAuth2.authenticate(
        url: googleUrl,
        callbackUrlScheme: 'mykost',
      );

      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];
      final name = uri.queryParameters['name'] ?? '';
      final email = uri.queryParameters['email'] ?? '';
      final role = uri.queryParameters['role'] ?? 'tenant';

      if (token != null) {
        await _authService.saveUser(token, name, email, role);
        await _authService.fetchAndSaveUserFromApi();
        Get.offAll(() => MainLayout());
        _showSuccess('Berhasil Masuk', 'Selamat datang, $name!');
      } else {
        _showError('Token tidak ditemukan');
      }
    } catch (e) {
      isLoading.value = false;
      _showError('Login Google gagal: $e');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAll(() => LoginScreen());
  }
}
