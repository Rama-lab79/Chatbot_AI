import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/daily_checkin.dart';
import 'auth_service.dart';

class CheckinService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> submitCheckin(
      DailyCheckin checkin) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/checkin'),
      headers: headers,
      body: jsonEncode(checkin.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        'success': true,
        'checkin': DailyCheckin.fromJson(data['checkin']),
      };
    } else {
      return {'success': false, 'error': data['error'] ?? 'Check-in failed'};
    }
  }

  static Future<DailyCheckin?> getTodayCheckin() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/checkin/today'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DailyCheckin.fromJson(data['checkin']);
    }
    return null;
  }

  static Future<DailyCheckin?> getLastCheckin() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/checkin/last'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DailyCheckin.fromJson(data['checkin']);
    }
    return null;
  }
}
