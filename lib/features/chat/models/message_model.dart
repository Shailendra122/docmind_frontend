class MessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime createdAt;
  final bool isStreaming;

  MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.createdAt,
    this.isStreaming = false,
  });

  //  From Supabase JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['role'] == 'user',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  MessageModel copyWith({
    String? content,
    bool? isStreaming,
  }) {
    return MessageModel(
      id: id,
      content: content ?? this.content,
      isUser: isUser,
      createdAt: createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}