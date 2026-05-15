import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../../../core/constants/app_constants.dart';

part 'document_event.dart';
part 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final _uuid = const Uuid();
  final _documentService = DocumentService();
  String _sessionId = '';

  DocumentBloc() : super(DocumentLoaded(documents: [], totalTokens: 0)) {
    on<DocumentPickRequested>(_onPickRequested);
    on<DocumentFilesPicked>(_onFilesPicked);
    on<DocumentRemoved>(_onRemoved);
    on<DocumentsCleared>(_onCleared);
    on<DocumentSessionUpdated>(_onSessionUpdated);
  }

  void _onSessionUpdated(
    DocumentSessionUpdated event,
    Emitter<DocumentState> emit,
  ) {
    _sessionId = event.sessionId;
  }

  Future<void> _onPickRequested(
    DocumentPickRequested event,
    Emitter<DocumentState> emit,
  ) async {
    // ✅ Check session ID is set
    if (_sessionId.isEmpty) {
      emit(DocumentLoaded(
        documents: [],
        totalTokens: 0,
        errorMessage: 'Session not ready. Please try again.',
      ));
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedExtensions,
        allowMultiple: false,     
        withData: true,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        add(DocumentFilesPicked(result.files));
      }
    } catch (e) {
      emit(DocumentError('Could not open file picker.'));
    }
  }

  Future<void> _onFilesPicked(
    DocumentFilesPicked event,
    Emitter<DocumentState> emit,
  ) async {
    if (event.files.isEmpty) return;

   
    final file = event.files.first;

    // Validate size
    if (file.size > AppConstants.maxFileSizeBytes) {
      emit(DocumentLoaded(
        documents: [],
        totalTokens: 0,
        errorMessage: '"${file.name}" exceeds 10MB limit.',
      ));
      return;
    }

    // Validate extension
    final ext = file.name.split('.').last.toLowerCase();
    if (!AppConstants.allowedExtensions.contains(ext)) {
      emit(DocumentLoaded(
        documents: [],
        totalTokens: 0,
        errorMessage: '"${file.name}" type not supported.',
      ));
      return;
    }

    final bytes = file.bytes;
    if (bytes == null) {
      emit(DocumentLoaded(
        documents: [],
        totalTokens: 0,
        errorMessage: 'Could not read file.',
      ));
      return;
    }

    // ✅ Replace any existing document
    final doc = DocumentModel(
      id: _uuid.v4(),
      fileName: file.name,
      fileType: ext,
      fileSizeBytes: file.size,
      status: DocumentStatus.validating,
      bytes: bytes,
      localPath: kIsWeb ? null : file.path,
    );

    // Show uploading state immediately
    emit(DocumentLoaded(
      documents: [doc],      //  Replace — not append
      totalTokens: doc.estimatedTokens,
    ));

    debugPrint('📤 Uploading to session: $_sessionId');

    try {
      final uploaded = await _documentService.uploadDocument(
        document: doc,
        sessionId: _sessionId,
        bytes: bytes,
      );

      debugPrint('✅ Upload done — backendId: ${uploaded.backendId}');

      emit(DocumentLoaded(
        documents: [uploaded],
        totalTokens: uploaded.estimatedTokens,
      ));

    } catch (e) {
      emit(DocumentLoaded(
        documents: [doc.copyWith(status: DocumentStatus.error)],
        totalTokens: 0,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onRemoved(
    DocumentRemoved event,
    Emitter<DocumentState> emit,
  ) {
    emit(DocumentLoaded(documents: [], totalTokens: 0));
  }

  void _onCleared(
    DocumentsCleared event,
    Emitter<DocumentState> emit,
  ) {
    emit(DocumentLoaded(documents: [], totalTokens: 0));
  }
}