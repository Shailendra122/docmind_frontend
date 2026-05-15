part of 'history_bloc.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<ChatSessionModel> sessions;
  final String? activeSessionId;

  HistoryLoaded({
    required this.sessions,
    this.activeSessionId,
  });

  List<ChatSessionModel> get pinnedSessions =>
      sessions.where((s) => s.isPinned).toList();

  List<ChatSessionModel> get recentSessions =>
      sessions.where((s) => !s.isPinned).toList();

  HistoryLoaded copyWith({
    List<ChatSessionModel>? sessions,
    String? activeSessionId,
  }) {
    return HistoryLoaded(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
    );
  }
}