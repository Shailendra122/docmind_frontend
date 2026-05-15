class ChatSessionModel {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final bool isPinned;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    this.isPinned = false,
  });

  //  From Supabase JSON
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
  return ChatSessionModel(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'New Chat',
    lastMessage: json['lastMessage'] as String? ?? '',
    updatedAt: DateTime.parse(
      json['updatedAt'] as String? ??
      json['updated_at'] as String? ??
      DateTime.now().toIso8601String(),
    ),
    isPinned: json['isPinned'] as bool? ??
              json['is_pinned'] as bool? ?? false,
  );
}

  ChatSessionModel copyWith({
    String? title,
    String? lastMessage,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return ChatSessionModel(
      id: id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}