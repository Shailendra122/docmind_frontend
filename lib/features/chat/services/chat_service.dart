import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/message_model.dart';

class ChatService {
  Stream<String> streamChatResponse({
    required String sessionId,
    required String message,
    required List<String> documentIds,
    required List<MessageModel> chatHistory,
  }) async* {
    try {
      final client = http.Client();

      final request = http.Request('POST', Uri.parse(ApiConstants.chatStream));

      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';

      //  Send full history for context
      final historyPayload = chatHistory
          .map(
            (m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            },
          )
          .toList();

      request.body = jsonEncode({
        'session_id': sessionId,
        'message': message,
        'document_ids': documentIds,
        'chat_history': historyPayload,
      });

      debugPrint('🚀 Chat request → session: $sessionId');
      debugPrint('📎 Documents: $documentIds');
      debugPrint('💬 History length: ${historyPayload.length}');

      debugPrint('🌍 URL: ${ApiConstants.chatStream}');

      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 30));

      debugPrint('🔥 STATUS: ${response.statusCode}');

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw Exception('Backend error ${response.statusCode}: $body');
      }

      await for (final chunk
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        
        if (chunk.startsWith('data: ')) {
          final jsonStr = chunk.substring(6).trim();
          if (jsonStr.isEmpty) continue;

          try {
            final data = jsonDecode(jsonStr);
            if (data['done'] == true) break;
            if (data['token'] != null) {
              yield data['token'] as String;
            }
          } catch (_) {
            continue;
          }
        }
      }

      client.close();
    } catch (e) {
      throw Exception('Chat failed: $e');
    }
  }

  Future<String> getChatTitle(String firstMessage) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.chatTitle),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': firstMessage}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['title'] ?? 'New Chat';
      }
      return 'New Chat';
    } catch (_) {
      return 'New Chat';
    }
  }
}
