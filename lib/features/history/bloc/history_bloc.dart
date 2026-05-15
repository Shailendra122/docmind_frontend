import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../chat/models/chat_session_model.dart';
import '../services/history_service.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends HydratedBloc<HistoryEvent, HistoryState> {
  final _service = HistoryService();

  HistoryBloc() : super(HistoryLoaded(sessions: [])) {
    on<HistoryLoadeds>(_onLoaded);
    on<HistorySessionAdded>(_onSessionAdded);
    on<HistorySessionUpdated>(_onSessionUpdated);
    on<HistorySessionPinToggled>(_onPinToggled);
    on<HistorySessionDeleted>(_onSessionDeleted);
    on<HistoryCleared>(_onCleared);
    on<HistoryActiveSessionSet>(_onActiveSessionSet);
  }

  // ✅ HydratedBloc serialization
  @override
  HistoryState? fromJson(Map<String, dynamic> json) {
    try {
      final sessions = (json['sessions'] as List)
          .map(
            (s) =>
                ChatSessionModel.fromJson(Map<String, dynamic>.from(s as Map)),
          )
          .toList();
      return HistoryLoaded(sessions: sessions);
    } catch (_) {
      return HistoryLoaded(sessions: []);
    }
  }

  @override
  Map<String, dynamic>? toJson(HistoryState state) {
    if (state is HistoryLoaded) {
      return {
        'sessions': state.sessions
            .map(
              (s) => {
                'id': s.id,
                'title': s.title,
                'lastMessage': s.lastMessage,
                'updatedAt': s.updatedAt.toIso8601String(),
                'isPinned': s.isPinned,
                'updated_at': s.updatedAt.toIso8601String(),
                'is_pinned': s.isPinned,
              },
            )
            .toList(),
      };
    }
    return null;
  }

  // All handlers same as before...
  Future<void> _onLoaded(
    HistoryLoadeds event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final sessions = await _service.loadSessions();
      debugPrint('📂 Loaded ${sessions.length} sessions from Supabase');
      emit(HistoryLoaded(sessions: sessions));
    } catch (e) {
      debugPrint('❌ Load error: $e');
    }
  }

  Future<void> _onSessionAdded(
    HistorySessionAdded event,
    Emitter<HistoryState> emit,
  ) async {
    final current = state as HistoryLoaded;
    final exists = current.sessions.any((s) => s.id == event.session.id);
    if (exists) return;

    // ✅ Update UI first
    emit(
      current.copyWith(
        sessions: [event.session, ...current.sessions],
        activeSessionId: event.session.id,
      ),
    );

    // ✅ Create in Supabase and WAIT
    await _service.createSession(event.session);
    debugPrint('✅ Session ready in Supabase: ${event.session.id}');
  }

  Future<void> _onSessionUpdated(
    HistorySessionUpdated event,
    Emitter<HistoryState> emit,
  ) async {
    final current = state as HistoryLoaded;
    final updated = current.sessions.map((s) {
      if (s.id == event.sessionId) {
        return s.copyWith(
          title: event.title,
          lastMessage: event.lastMessage,
          updatedAt: DateTime.now(),
        );
      }
      return s;
    }).toList();

    emit(current.copyWith(sessions: updated));
    await _service.updateSession(
      sessionId: event.sessionId,
      title: event.title,
    );
  }

  Future<void> _onPinToggled(
    HistorySessionPinToggled event,
    Emitter<HistoryState> emit,
  ) async {
    final current = state as HistoryLoaded;
    bool newPinState = false;
    final updated = current.sessions.map((s) {
      if (s.id == event.sessionId) {
        newPinState = !s.isPinned;
        return s.copyWith(isPinned: !s.isPinned);
      }
      return s;
    }).toList();

    emit(current.copyWith(sessions: updated));
    await _service.togglePin(sessionId: event.sessionId, isPinned: newPinState);
  }

  Future<void> _onSessionDeleted(
    HistorySessionDeleted event,
    Emitter<HistoryState> emit,
  ) async {
    final current = state as HistoryLoaded;
    final updated = current.sessions
        .where((s) => s.id != event.sessionId)
        .toList();

    final newActiveId = current.activeSessionId == event.sessionId
        ? null
        : current.activeSessionId;

    emit(current.copyWith(sessions: updated, activeSessionId: newActiveId));

    await _service.deleteSession(event.sessionId);
  }

  void _onCleared(HistoryCleared event, Emitter<HistoryState> emit) {
    emit(HistoryLoaded(sessions: []));
  }

  void _onActiveSessionSet(
    HistoryActiveSessionSet event,
    Emitter<HistoryState> emit,
  ) {
    final current = state;
    if (current is! HistoryLoaded) return;
    emit(current.copyWith(activeSessionId: event.sessionId));
  }
}
