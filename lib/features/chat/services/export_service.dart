
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../models/message_model.dart';

class ExportService {
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<Uint8List?> exportChatAsPdf({
    required String title,
    required List<MessageModel> messages,
    String? documentName,
  }) async {
    try {
      final messagesPayload = messages
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
                'created_at': m.createdAt.toIso8601String(),
              })
          .toList();

      final response = await _dio.post(
        ApiConstants.exportPdf,
        data: {
          'title': title,
          'messages': messagesPayload,
          'document_name': documentName,
        },
        options: Options(
          responseType: ResponseType.bytes,  
          headers: {'Accept': 'application/pdf'},
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data as List<int>);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Export error: $e');
      rethrow;
    }
  }
}