class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────
  static const appName = 'Docmind';
  static const appVersion = '1.0.0';

  // ─── Document Limits ───────────────────────────────────
  static const maxDocumentsPerChat = 3;
  static const maxFileSizeBytes = 10 * 1024 * 1024;    // 10 MB per file
  static const maxTotalSizeBytes = 20 * 1024 * 1024;   // 20 MB combined
  static const maxContextTokens = 12000;                // Token budget

  // ─── File Types Allowed ────────────────────────────────
  static const allowedExtensions = ['pdf', 'txt', 'png', 'jpg', 'jpeg'];

  // ─── Chat Limits ───────────────────────────────────────
  static const maxPinnedChats = 10;
  static const chatHistoryPageSize = 20;  // load 20 chats at a time

  // ─── UI ────────────────────────────────────────────────
  static const sidebarWidth = 280.0;
  static const mobileBreakpoint = 600.0;
  static const tabletBreakpoint = 1200.0;

  // ─── Local Storage Keys (Hive) ─────────────────────────
  static const hiveBoxName = 'docmind_cache';
  static const hiveChatKey = 'cached_chats';
  static const hiveUserKey = 'cached_user';

  // ─── Shared Preferences Keys ───────────────────────────
  static const prefOnboarded = 'is_onboarded';
  static const prefThemeMode = 'theme_mode';
}