import 'package:docmind_flutter/core/utils/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/message_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _uuid = const Uuid();
  final _chatService = ChatService();
  final _messageService = MessageService();

  List<String> _documentIds = [];
  final Map<String, List<MessageModel>> _messageCache = {};

  ChatBloc() : super(ChatInitial()) {
    on<ChatNewSessionStarted>(_onNewSession);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatStreamTokenReceived>(_onTokenReceived);
    on<ChatStreamCompleted>(_onStreamCompleted);
    on<ChatDocumentIdsUpdated>(_onDocumentIdsUpdated);
    on<ChatCleared>(_onCleared);
    on<ChatMessagesCleared>(_onMessagesCleared);
    on<ChatDeletedFromSidebar>(_onDeletedFromSidebar);
    on<ChatSessionSelected>(_onSessionSelected);
    on<ChatAlreadyNew>(_onAlreadyNew);
  }

  //  Triggers pulse animation via justReset flag
  void _onAlreadyNew(ChatAlreadyNew event, Emitter<ChatState> emit) {
    final current = state;
    if (current is! ChatLoaded) return;

    // Emit same state with justReset = true
    // This triggers the animation in UI
    emit(
      ChatLoaded(
        messages: current.messages,
        sessionId: current.sessionId,
        isStreaming: current.isStreaming,
        streamingText: current.streamingText,
        justReset: true,
      ),
    );
  }

  void _onNewSession(ChatNewSessionStarted event, Emitter<ChatState> emit) {
    _documentIds = [];
    final newId = _uuid.v4();
    emit(ChatLoaded(messages: [], sessionId: newId));
    debugPrint('🆕 New session: $newId');
  }

  void _onDocumentIdsUpdated(
    ChatDocumentIdsUpdated event,
    Emitter<ChatState> emit,
  ) {
    _documentIds = event.documentIds;
  }

  void _onCleared(ChatCleared event, Emitter<ChatState> emit) {
    _documentIds = [];
    emit(ChatLoaded(messages: [], sessionId: _uuid.v4()));
  }

  void _onMessagesCleared(ChatMessagesCleared event, Emitter<ChatState> emit) {
    final current = state;
    if (current is! ChatLoaded) return;
    _messageCache[current.sessionId] = [];
    emit(ChatLoaded(messages: [], sessionId: current.sessionId));
  }

  void _onDeletedFromSidebar(
    ChatDeletedFromSidebar event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;
    _messageCache.remove(event.deletedSessionId);
    if (current.sessionId == event.deletedSessionId) {
      _documentIds = [];
      emit(ChatLoaded(messages: [], sessionId: _uuid.v4()));
    }
  }

  // ✅ Load from cache first, then Supabase
  Future<void> _onSessionSelected(
    ChatSessionSelected event,
    Emitter<ChatState> emit,
  ) async {
    // Check memory cache first
    if (_messageCache.containsKey(event.sessionId)) {
      final cached = _messageCache[event.sessionId]!;
      emit(ChatLoaded(messages: cached, sessionId: event.sessionId));
      debugPrint('📂 Loaded ${cached.length} messages from cache');
      return;
    }

    // Load from Supabase
    emit(
      ChatLoaded(
        messages: [],
        sessionId: event.sessionId,
        isStreaming: true, 
        streamingText: '',
      ),
    );

    try {
      final messages = await _messageService.loadMessages(event.sessionId);

      // Cache for future use
      _messageCache[event.sessionId] = messages;

      emit(ChatLoaded(messages: messages, sessionId: event.sessionId));

      debugPrint('📂 Loaded ${messages.length} messages from Supabase');
    } catch (e) {
      debugPrint('❌ Load messages error: $e');
      emit(ChatLoaded(messages: [], sessionId: event.sessionId));
    }
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return;

    final userMessage = MessageModel(
      id: _uuid.v4(),
      content: event.message,
      isUser: true,
      createdAt: DateTime.now(),
    );

    final historyForRequest = List<MessageModel>.from(current.messages);
    final updatedMessages = [...current.messages, userMessage];
    _messageCache[current.sessionId] = List.from(updatedMessages);

    emit(
      current.copyWith(
        messages: updatedMessages,
        isStreaming: true,
        streamingText: '',
      ),
    );

    // ✅ Ensure session exists in Supabase before saving message
    await _ensureSessionExists(current.sessionId, event.message);

    // ✅ Now save message
    await _messageService.saveMessage(
      sessionId: current.sessionId,
      message: userMessage,
    );

    try {
      final stream = _chatService.streamChatResponse(
        sessionId: current.sessionId,
        message: event.message,
        documentIds: _documentIds,
        chatHistory: historyForRequest,
      );

      bool receivedAnyToken = false;

      await for (final token in stream.timeout(const Duration(seconds: 45))) {
        receivedAnyToken = true;
        add(ChatStreamTokenReceived(token));
      }

      // ✅ Prevent hanging state
      if (receivedAnyToken) {
        add(ChatStreamCompleted());
      } else {
        throw Exception('No response received from AI.');
      }
    } catch (e) {
      debugPrint('❌ Chat stream error: $e');

      final latest = state;

      if (latest is ChatLoaded) {
        final errorMessage = MessageModel(
          id: _uuid.v4(),
          content: '⚠️ AI response failed. Please try again.',
          isUser: false,
          createdAt: DateTime.now(),
        );

        final msgs = [...latest.messages, errorMessage];

        _messageCache[latest.sessionId] = msgs;

        emit(
          latest.copyWith(
            messages: msgs,
            isStreaming: false,
            streamingText: '',
          ),
        );
      }
    }
  }

  //  Create session in Supabase if not exists
  Future<void> _ensureSessionExists(
    String sessionId,
    String firstMessage,
  ) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Check if session exists
      final existing = await supabase
          .from('chat_sessions')
          .select('id')
          .eq('id', sessionId)
          .maybeSingle();

      if (existing == null) {
        // Create session
        final title = firstMessage.length > 40
            ? '${firstMessage.substring(0, 40)}...'
            : firstMessage;

        await supabase.from('chat_sessions').insert({
          'id': sessionId,
          'user_id': userId,
          'title': title,
          'is_pinned': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        debugPrint('✅ Session auto-created: $sessionId');
      }
    } catch (e) {
      debugPrint('❌ Ensure session error: $e');
    }
  }

  void _onTokenReceived(
    ChatStreamTokenReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;
    emit(current.copyWith(streamingText: current.streamingText + event.token));
  }

  Future<void> _onStreamCompleted(
    ChatStreamCompleted event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return;
    if (current.streamingText.isEmpty) return;

    final aiMessage = MessageModel(
      id: _uuid.v4(),
      content: current.streamingText,
      isUser: false,
      createdAt: DateTime.now(),
    );

    final updatedMessages = [...current.messages, aiMessage];
    _messageCache[current.sessionId] = List.from(updatedMessages);

    emit(
      current.copyWith(
        messages: updatedMessages,
        isStreaming: false,
        streamingText: '',
      ),
    );

    // ✅ Save AI message
    await _messageService.saveMessage(
      sessionId: current.sessionId,
      message: aiMessage,
    );
  }
}
