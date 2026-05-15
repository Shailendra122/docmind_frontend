class SupabaseConstants {
  SupabaseConstants._();

  // ─── Table Names ───────────────────────────────────────
  static const tableChatSessions = 'chat_sessions';
  static const tableMessages = 'messages';
  static const tableDocuments = 'documents';

  // ─── chat_sessions columns ─────────────────────────────
  static const colId = 'id';
  static const colUserId = 'user_id';
  static const colTitle = 'title';
  static const colIsPinned = 'is_pinned';
  static const colCreatedAt = 'created_at';
  static const colUpdatedAt = 'updated_at';

  // ─── messages columns ──────────────────────────────────
  static const colSessionId = 'session_id';
  static const colRole = 'role';
  static const colContent = 'content';

  // ─── documents columns ─────────────────────────────────
  static const colFileName = 'file_name';
  static const colFileUrl = 'file_url';
  static const colFileType = 'file_type';
  static const colFileSizeBytes = 'file_size_bytes';
  static const colTokenCount = 'token_count';
  static const colStatus = 'status';

  // ─── Storage ───────────────────────────────────────────
  static const storageBucket = 'documents';

  // ─── Message Roles ─────────────────────────────────────
  static const roleUser = 'user';
  static const roleAssistant = 'assistant';

  // ─── Document Status ───────────────────────────────────
  static const statusProcessing = 'processing';
  static const statusReady = 'ready';
  static const statusFailed = 'failed';
}