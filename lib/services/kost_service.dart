import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kost_model.dart';

class KostService {
  static final KostService _instance = KostService._internal();
  factory KostService() => _instance;
  KostService._internal();

  final String _baseUrl = 'https://chess-gore-patience.ngrok-free.dev/api';
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {..._headers, 'Authorization': 'Bearer $token'};
  }

  Future<List<Kost>> getProperties({String? type, String? search}) async {
    try {
      final headers = await _authHeaders();
      final params = <String, String>{};
      if (type != null && type != 'Semua') params['type'] = type;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final uri = Uri.parse(
        '$_baseUrl/properties',
      ).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Kost.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPropertyDetail(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/properties/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getContracts() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/contracts'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> toggleWishlist(int propertyId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/wishlists/toggle'),
        headers: headers,
        body: jsonEncode({'property_id': propertyId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'added';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkWishlist(int propertyId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/wishlists/check/$propertyId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getWishlists() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/wishlists'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> submitRentalRequest({
    required int roomTypeId,
    required String startDate,
    required int durationValue,
    required String durationType,
    String? note,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/rental-requests'),
        headers: headers,
        body: jsonEncode({
          'room_type_id': roomTypeId,
          'start_date': startDate,
          'duration_value': durationValue,
          'duration_type': durationType,
          'note': note ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengajukan sewa',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<Map<String, dynamic>> submitReview({
    required int contractId,
    required int rating,
    required String comment,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/reviews'),
        headers: headers,
        body: jsonEncode({
          'contract_id': contractId,
          'rating': rating,
          'comment': comment,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Ulasan berhasil dikirim',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengirim ulasan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }
}
