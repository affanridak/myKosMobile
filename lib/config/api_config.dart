import 'dart:io';
import 'package:flutter/foundation.dart';

/// Konfigurasi API terpusat.
/// Ubah [localIp] sesuai IP PC di jaringan WiFi lokal (hasil ipconfig → IPv4).
/// Semua service mengimport dari sini — cukup ubah di satu tempat.
class ApiConfig {
  ApiConfig._(); // tidak bisa diinstansiasi

  static const String localIp = '192.168.1.15';
  static const String _defaultBaseUrl =
      'http://$localIp/myKosWeb/public/api';

  // Override via: flutter run --dart-define=API_BASE_URL=http://x.x.x.x/myKosWeb/public/api
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  /// Base URL yang sudah disesuaikan dengan platform (emulator / HP fisik).
  static String get baseUrl {
    final configured =
        _envBaseUrl.trim().isEmpty ? _defaultBaseUrl : _envBaseUrl;
    try {
      final parsed = Uri.tryParse(configured);
      if (!kIsWeb && Platform.isAndroid && parsed != null) {
        // Emulator Android: 127.0.0.1 / localhost → 10.0.2.2
        if (parsed.host == '127.0.0.1' || parsed.host == 'localhost') {
          return parsed.replace(host: '10.0.2.2').toString();
        }
      }
    } catch (_) {}
    return configured;
  }
}
