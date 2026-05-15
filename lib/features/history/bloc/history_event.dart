part of 'history_bloc.dart';

abstract class HistoryEvent {}

// Load all sessions
class HistoryLoadeds extends HistoryEvent {}

// Add new session to history
class HistorySessionAdded extends HistoryEvent {
  final ChatSessionModel session;
  HistorySessionAdded(this.session);
}

// Update session title
class HistorySessionUpdated extends HistoryEvent {
  final String sessionId;
  final String title;
  final String lastMessage;
  HistorySessionUpdated({
    required this.sessionId,
    required this.title,
    required this.lastMessage,
  });
}

// Pin/unpin session
class HistorySessionPinToggled extends HistoryEvent {
  final String sessionId;
  HistorySessionPinToggled(this.sessionId);
}

// Delete session
class HistorySessionDeleted extends HistoryEvent {
  final String sessionId;
  HistorySessionDeleted(this.sessionId);
}

// Clear all history
class HistoryCleared extends HistoryEvent {}

// Add this new event
class HistoryActiveSessionSet extends HistoryEvent {
  final String sessionId;
  HistoryActiveSessionSet(this.sessionId);
}