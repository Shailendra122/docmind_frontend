import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // ─── Dynamic Base URL ──────────────────────────────────
  static String get baseUrl {
    // 🌐 Flutter Web
    if (kIsWeb) {
      return dotenv.env['WEB_BACKEND_URL'] ??
          'http://127.0.0.1:8000';
    }

    // 🤖 Android Emulator
    if (Platform.isAndroid) {
      return dotenv.env['ANDROID_BACKEND_URL'] ??
          'http://10.0.2.2:8000';
    }

    // 🍎 iOS Simulator / Desktop
    return dotenv.env['BACKEND_URL'] ??
        'http://127.0.0.1:8000';
  }

  // ─── Health ────────────────────────────────────────────
  static String get health => '$baseUrl/health';

  // ─── Documents ─────────────────────────────────────────
  static String get uploadDocument =>
      '$baseUrl/documents/upload';

  static String get processDocument =>
      '$baseUrl/documents/process';

  static String get tokenCount =>
      '$baseUrl/documents/token-count';

  // ─── Chat ──────────────────────────────────────────────
  static String get chatStream =>
      '$baseUrl/chat/stream';

  static String get chatSummary =>
      '$baseUrl/chat/summary';

  static String get chatTitle =>
      '$baseUrl/chat/title';

  // ─── Export ────────────────────────────────────────────
  static String get exportPdf =>
      '$baseUrl/export/pdf';
}