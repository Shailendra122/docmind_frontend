// Base exception for all Docmind errors
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

// Auth related errors
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

// File/document related errors
class DocumentException extends AppException {
  const DocumentException(super.message, {super.code});
}

// Network/API errors
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

// Token budget errors
class TokenBudgetException extends AppException {
  const TokenBudgetException(super.message, {super.code});
}

// Storage errors
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}