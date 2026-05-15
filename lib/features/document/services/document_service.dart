import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../models/document_model.dart';

class DocumentService {
  late final Dio _dio;

  DocumentService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        // ✅ Don't set Content-Type here — Dio sets it automatically for multipart
      ),
    );

    // ✅ Log requests in debug mode
    _dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: true, error: true),
    );
  }

  /// Upload document to backend
  /// Returns updated document with real token count
  Future<DocumentModel> uploadDocument({
    required DocumentModel document,
    required String sessionId,
    required Uint8List bytes,
  }) async {
    // ✅ Log exactly what session we're uploading to
    debugPrint('📤 DocumentService uploading to session: $sessionId');
    debugPrint('📄 File: ${document.fileName}');

    if (sessionId.isEmpty) {
      throw Exception('Session ID is empty — cannot upload');
    }

    try {
      final formData = FormData.fromMap({
        'session_id': sessionId,
        'file': MultipartFile.fromBytes(bytes, filename: document.fileName),
      });

      final response = await _dio.post(
        ApiConstants.uploadDocument,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final backendId = data['id'] as String;
        final tokenCount = data['token_count'] as int;
        debugPrint(
          '✅ Upload success — backendId: $backendId tokens: $tokenCount',
        );
        debugPrint('✅ Stored under session: $sessionId');

        return document.copyWith(
          backendId: backendId,
          tokenCount: tokenCount,
          status: DocumentStatus.ready,
        );
      }

      throw Exception('Upload failed: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ Upload error');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Data: ${e.response?.data}');
      debugPrint('Message: ${e.message}');

      // ✅ Show backend validation details clearly
      if (e.response?.data != null) {
        final data = e.response!.data;

        if (data is Map<String, dynamic>) {
          final detail = data['detail'];

          if (detail != null) {
            throw Exception(detail.toString());
          }
        }

        throw Exception(data.toString());
      }

      throw Exception('Upload failed: ${e.message}');
    }
  }
}
