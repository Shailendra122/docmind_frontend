part of 'document_bloc.dart';

abstract class DocumentEvent {}

// User taps upload button
class DocumentPickRequested extends DocumentEvent {}

// File was picked from device
class DocumentFilesPicked extends DocumentEvent {
  final List<PlatformFile> files;
  DocumentFilesPicked(this.files);
}

// Remove a document
class DocumentRemoved extends DocumentEvent {
  final String documentId;
  DocumentRemoved(this.documentId);
}

// Clear all documents
class DocumentsCleared extends DocumentEvent {}

class DocumentSessionUpdated extends DocumentEvent {
  final String sessionId;
  DocumentSessionUpdated(this.sessionId);
}