import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';
import 'auth_service.dart';

enum ChatMode { listening, solution }

class ChatService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> sendMessage(
    String message,
    ChatMode mode,
  ) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat'),
      headers: headers,
      body: jsonEncode({
        'message': message,
        'mode': mode == ChatMode.listening ? 'listening' : 'solution',
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'userMessage': ChatMessage.fromJson(data['userMessage']),
        'aiResponse': ChatMessage.fromJson(data['aiResponse']),
      };
    } else {
      return {
        'success': false,
        'error': data['error'] ?? 'Failed to send message'
      };
    }
  }

  static Future<List<ChatMessage>> getTodayChats() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/today'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> chats = data['chats'];
      return chats.map((c) => ChatMessage.fromJson(c)).toList();
    }
    return [];
  }

  static Future<bool> deleteTodayChats() async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/chat/today'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  static Future<bool> generateSummary() async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/summary'),
      headers: headers,
    );

    return response.statusCode == 200;
  }
}
