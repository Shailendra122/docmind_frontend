part of 'document_bloc.dart';

abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<DocumentModel> documents;
  final int totalTokens;
  final bool isOverBudget;
  final String? errorMessage;

  DocumentLoaded({
    required this.documents,
    required this.totalTokens,
    this.isOverBudget = false,
    this.errorMessage,
  });

  // ✅ Only 1 document allowed
  bool get hasDocument => documents.isNotEmpty;

  bool get isUploading => documents.any(
    (d) => d.status == DocumentStatus.validating,
  );

  bool get isReady => documents.any(
    (d) => d.status == DocumentStatus.ready,
  );

  DocumentModel? get currentDocument =>
      documents.isEmpty ? null : documents.first;

  DocumentLoaded copyWith({
    List<DocumentModel>? documents,
    int? totalTokens,
    bool? isOverBudget,
    String? errorMessage,
  }) {
    return DocumentLoaded(
      documents: documents ?? this.documents,
      totalTokens: totalTokens ?? this.totalTokens,
      isOverBudget: isOverBudget ?? this.isOverBudget,
      errorMessage: errorMessage,
    );
  }
}

class DocumentError extends DocumentState {
  final String message;
  DocumentError(this.message);
}