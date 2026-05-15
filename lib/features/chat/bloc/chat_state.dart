part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final String sessionId;
  final bool isStreaming;
  final String streamingText;
  final bool justReset;      

  ChatLoaded({
    required this.messages,
    required this.sessionId,
    this.isStreaming = false,
    this.streamingText = '',
    this.justReset = false,   
  });

  ChatLoaded copyWith({
    List<MessageModel>? messages,
    bool? isStreaming,
    String? streamingText,
    String? sessionId,
    bool? justReset,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      sessionId: sessionId ?? this.sessionId,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
      justReset: justReset ?? false,  
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

