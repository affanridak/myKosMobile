import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/api_config.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  AuthResult({required this.success, required this.message, this.token});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String get _baseUrl => ApiConfig.baseUrl;

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true', // Melewati halaman warning ngrok
  };

  /// Getter publik agar service lain bisa menggunakan base URL yang sama.
  String get baseUrl => _baseUrl;

  Future<Map<String, String>> _getHeadersWithDeviceName() async {
    final headers = Map<String, String>.from(_headers);
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'flutter-app';

      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceName = 'Web Browser (${webInfo.browserName.name})';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName =
            '${iosInfo.name} (${iosInfo.systemName} ${iosInfo.systemVersion})';
      } else if (Platform.isWindows) {
        deviceName = 'Windows PC';
      }

      // Pastikan nama perangkat tidak terlalu panjang dan rapi
      headers['User-Agent'] = deviceName.toUpperCase();
    } catch (e) {
      debugPrint('Device Info Error: $e');
      headers['User-Agent'] = 'Unknown Device';
    }
    return headers;
  }

  String get _origin {
    final baseUri = Uri.parse(_baseUrl);
    return '${baseUri.scheme}://${baseUri.authority}';
  }

  String _normalizeAvatarUrl(String? avatar) {
    final value = (avatar ?? '').trim();
    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/storage/')) {
      return '$_origin$value';
    }
    if (value.startsWith('storage/')) {
      return '$_origin/$value';
    }

    final cleanPath = value.replaceFirst(RegExp(r'^/+'), '');
    return '$_origin/storage/$cleanPath';
  }

  String? _token;
  String? get token => _token;
  int? _userId;
  int? get userId => _userId;

  Future<void> saveUser(
    String token,
    String name,
    String email,
    String role, {
    String? phone,
    String? avatar,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setString('phone', phone ?? '');
    if (userId != null) await prefs.setInt('user_id', userId);

    final emailKey = email.toLowerCase();
    final avatarKey = 'avatar:$emailKey';
    await prefs.setString(avatarKey, _normalizeAvatarUrl(avatar));
    // convenience: global avatar reflects current user
    await prefs.setString('avatar', _normalizeAvatarUrl(avatar));
    await prefs.setInt('login_at', DateTime.now().millisecondsSinceEpoch);
    _token = token;
  }

  Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final emailKey = email.toLowerCase();
    final avatarKey = email.isNotEmpty ? 'avatar:$emailKey' : 'avatar';
    final storedAvatar =
        prefs.getString(avatarKey) ?? prefs.getString('avatar');
    return {
      'token': prefs.getString('token'),
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
      'role': prefs.getString('role'),
      'phone': prefs.getString('phone'),
      'avatar': _normalizeAvatarUrl(storedAvatar),
    };
  }

  Future<AuthResult> updateProfile({
    required String name,
    String? phone,
    dynamic avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return AuthResult(success: false, message: 'Tidak terautentikasi');
    }

    final uri = Uri.parse('$_baseUrl/profile');
    String lastBody = '';
    try {
      final fieldNames = ['avatar', 'photo', 'file'];
      for (final field in fieldNames) {
        // Try POST with _method=PUT first
        for (final usePostOverride in [true, false]) {
          final method = usePostOverride ? 'POST' : 'PUT';
          final request = http.MultipartRequest(method, uri);
          if (usePostOverride) {
            request.fields['_method'] = 'PUT';
          }
          request.fields['name'] = name;
          if (phone != null) {
            request.fields['phone'] = phone;
          }
          if (avatar != null) {
            try {
              http.MultipartFile file;
              if (avatar is File) {
                file = await http.MultipartFile.fromPath(field, avatar.path);
              } else if (avatar is Uint8List) {
                file = http.MultipartFile.fromBytes(
                  field,
                  avatar,
                  filename: 'avatar.jpg',
                );
              } else {
                // unsupported avatar type, skip trying to attach
                continue;
              }
              request.files.add(file);
            } catch (e) {
              // couldn't create multipart file with this field name, try next
              continue;
            }
          }
          request.headers.addAll({
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });

          final streamed = await request.send();
          final response = await http.Response.fromStream(streamed);
          lastBody = response.body;

          // Try to decode JSON body if possible to extract server messages
          dynamic data;
          try {
            data = jsonDecode(response.body);
          } catch (_) {
            data = null;
          }

          // debug: update profile attempt logged during development

          if (response.statusCode == 200) {
            final user = (data is Map) ? (data['user'] ?? data) : data ?? {};
            final savedName = (user is Map && user['name'] != null)
                ? user['name']
                : name;
            final savedPhone = (user is Map && user['phone'] != null)
                ? user['phone']
                : (phone ?? '');
            String savedAvatar = '';
            if (user is Map && user['avatar'] != null) {
              savedAvatar = user['avatar'];
            }
            if (user is Map && user['photo'] != null) {
              savedAvatar = user['photo'];
            }
            if (user is Map && user['profile_photo_url'] != null) {
              savedAvatar = user['profile_photo_url'];
            }

            await prefs.setString('name', savedName);
            await prefs.setString('phone', savedPhone);

            // Only overwrite stored avatar if server returned one.
            if (savedAvatar.isNotEmpty) {
              final email = prefs.getString('email') ?? '';
              final key = email.isNotEmpty
                  ? 'avatar:${email.toLowerCase()}'
                  : 'avatar';
              await prefs.setString(key, _normalizeAvatarUrl(savedAvatar));
              await prefs.setString('avatar', _normalizeAvatarUrl(savedAvatar));
            } else {
              // Try to refresh user data from API (some backends don't return
              // avatar in the update response). This will update prefs if
              // the avatar exists.
              try {
                final resp = await http.get(
                  Uri.parse('$_baseUrl/user'),
                  headers: {
                    'Accept': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                );
                if (resp.statusCode == 200) {
                  final fresh = jsonDecode(resp.body);
                  String freshAvatar = '';
                  if (fresh is Map && fresh['avatar'] != null) {
                    freshAvatar = fresh['avatar'];
                  }
                  if (fresh is Map && fresh['photo'] != null) {
                    freshAvatar = fresh['photo'];
                  }
                  if (fresh is Map && fresh['profile_photo_url'] != null) {
                    freshAvatar = fresh['profile_photo_url'];
                  }
                  if (freshAvatar.isNotEmpty) {
                    final email = prefs.getString('email') ?? '';
                    final key = email.isNotEmpty
                        ? 'avatar:${email.toLowerCase()}'
                        : 'avatar';
                    await prefs.setString(
                      key,
                      _normalizeAvatarUrl(freshAvatar),
                    );
                    await prefs.setString(
                      'avatar',
                      _normalizeAvatarUrl(freshAvatar),
                    );
                  }
                }
              } catch (e) {
                // ignore errors from refresh
              }
            }

            return AuthResult(
              success: true,
              message: (data is Map && data['message'] != null)
                  ? data['message']
                  : 'Profil berhasil diperbarui',
            );
          } else {
            // non-200 response: try to extract meaningful message
            String serverMessage = '';
            if (data is Map) {
              if (data['message'] != null) {
                serverMessage = data['message'].toString();
              } else if (data['errors'] != null) {
                final errs = data['errors'];
                if (errs is Map && errs.values.isNotEmpty) {
                  final first = errs.values.first;
                  if (first is List && first.isNotEmpty) {
                    serverMessage = first.first.toString();
                  } else {
                    serverMessage = first.toString();
                  }
                } else {
                  serverMessage = errs.toString();
                }
              } else {
                serverMessage = data.toString();
              }
            } else {
              serverMessage = response.body;
            }

            // debug: updateProfile failed during development

            // Save a concise lastBody to report after all attempts
            final shortMessage = serverMessage.length > 300
                ? '${serverMessage.substring(0, 300)}...'
                : serverMessage;
            lastBody = 'HTTP ${response.statusCode}: $shortMessage';
            // continue trying other field/method combos
          }
        }
      }
      return AuthResult(
        success: false,
        message: 'Gagal memperbarui profil: $lastBody',
      );
    } catch (e) {
      // debug: exception during updateProfile
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan jaringan: $e',
      );
    }
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final loginAt = prefs.getInt('login_at');

    if (token == null || loginAt == null) {
      return false;
    }

    final loginTime = DateTime.fromMillisecondsSinceEpoch(loginAt);
    final diff = DateTime.now().difference(loginTime).inDays;

    if (diff > 30) {
      await clearUser();
      return false;
    }

    _token = token;
    return true;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep cached profile fields so the avatar and basic info survive logout.
    await prefs.remove('token');
    await prefs.remove('login_at');
    _token = null;
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final dynamicHeaders = await _getHeadersWithDeviceName();
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: dynamicHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveUser(
          data['token'],
          data['user']['name'],
          data['user']['email'],
          data['user']['role'] ?? 'tenant',
          phone: data['user']['phone'],
          avatar: data['user']['avatar']?.toString(),
          userId: data['user']['id'] is int ? data['user']['id'] : null,
        );
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Login berhasil',
          token: data['token'],
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Login gagal',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final dynamicHeaders = await _getHeadersWithDeviceName();
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: dynamicHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Pendaftaran berhasil',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Pendaftaran gagal',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  Future<AuthResult> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'OTP terkirim',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Gagal kirim OTP',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  Future<AuthResult> verifyOtp(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: _headers,
        body: jsonEncode({'email': email, 'otp': code}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'OTP terverifikasi',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'OTP tidak valid',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  Future<AuthResult> changePassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Password berhasil diubah',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Gagal ubah password',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  /// Change password for authenticated user (requires current password)
  Future<AuthResult> changePasswordAuthenticated(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return AuthResult(success: false, message: 'Tidak terautentikasi');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/profile/change-password'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Password berhasil diubah',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Gagal ubah password',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  Future<void> fetchAndSaveUserFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('name', data['name'] ?? '');
        await prefs.setString('email', data['email'] ?? '');
        await prefs.setString('role', data['role'] ?? 'tenant');
        await prefs.setString('phone', data['phone'] ?? '');
        if (data['id'] != null) {
          await prefs.setInt(
            'user_id',
            data['id'] is int
                ? data['id']
                : int.tryParse(data['id'].toString()) ?? 0,
          );
        }
        final email = data['email'] ?? prefs.getString('email') ?? '';
        final key = email.isNotEmpty
            ? 'avatar:${email.toLowerCase()}'
            : 'avatar';
        await prefs.setString(
          key,
          _normalizeAvatarUrl(data['avatar']?.toString()),
        );
        await prefs.setString(
          'avatar',
          _normalizeAvatarUrl(data['avatar']?.toString()),
        );
      }
    } catch (e) {
      //
    }
  }

  Future<List<Map<String, dynamic>>> getActiveDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/user/devices'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> revokeDevice(int tokenId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/user/devices/$tokenId'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {..._headers, 'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      //
    }
    await clearUser();
  }
}
