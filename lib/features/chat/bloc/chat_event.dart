part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatSessionLoaded extends ChatEvent {
  final String sessionId;
  ChatSessionLoaded(this.sessionId);
}

class ChatMessageSent extends ChatEvent {
  final String message;
  ChatMessageSent(this.message);
}

class ChatStreamTokenReceived extends ChatEvent {
  final String token;
  ChatStreamTokenReceived(this.token);
}

class ChatStreamCompleted extends ChatEvent {}

class ChatNewSessionStarted extends ChatEvent {}

class ChatDocumentIdsUpdated extends ChatEvent {
  final List<String> documentIds;
  ChatDocumentIdsUpdated(this.documentIds);
}

// ✅ Clears messages + docs — full fresh start
class ChatCleared extends ChatEvent {}

// ✅ Clears messages only — keeps docs
class ChatMessagesCleared extends ChatEvent {}

// Add this new event
class ChatDeletedFromSidebar extends ChatEvent {
  final String deletedSessionId;
  ChatDeletedFromSidebar(this.deletedSessionId);
}

// ✅ Fired when user clicks chat in sidebar
class ChatSessionSelected extends ChatEvent {
  final String sessionId;
  ChatSessionSelected(this.sessionId);
}

// ✅ Fired when user taps new chat but already on new chat
class ChatAlreadyNew extends ChatEvent {}