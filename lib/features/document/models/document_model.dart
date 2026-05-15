import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class DocumentModel {
  final String id;           // local UUID
  final String? backendId;   // ✅ ID returned by backend after upload
  final String fileName;
  final String fileType;
  final int fileSizeBytes;
  final int tokenCount;
  final DocumentStatus status;
  final String? localPath;
  final Uint8List? bytes;

  DocumentModel({
    required this.id,
    this.backendId,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    this.tokenCount = 0,
    this.status = DocumentStatus.picking,
    this.localPath,
    this.bytes,
  });

  DocumentModel copyWith({
    String? backendId,
    int? tokenCount,
    DocumentStatus? status,
    String? localPath,
    Uint8List? bytes,
  }) {
    return DocumentModel(
      id: id,
      backendId: backendId ?? this.backendId,
      fileName: fileName,
      fileType: fileType,
      fileSizeBytes: fileSizeBytes,
      tokenCount: tokenCount ?? this.tokenCount,
      status: status ?? this.status,
      localPath: localPath ?? this.localPath,
      bytes: bytes ?? this.bytes,
    );
  }

  String get readableSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  int get estimatedTokens {
    if (tokenCount > 0) return tokenCount;
    if (isPdf) return (fileSizeBytes * 0.15 / 4).round().clamp(200, 8000);
    if (isImage) return (fileSizeBytes * 0.05 / 4).round().clamp(100, 2000);
    return (fileSizeBytes / 4).round().clamp(100, 8000);
  }

  String get fileExtension => fileName.split('.').last.toLowerCase();
  bool get isPdf => fileExtension == 'pdf';
  bool get isImage => ['png', 'jpg', 'jpeg'].contains(fileExtension);
  bool get isText => fileExtension == 'txt';
}

enum DocumentStatus {
  picking,
  validating,
  ready,
  overBudget,
  error,
}