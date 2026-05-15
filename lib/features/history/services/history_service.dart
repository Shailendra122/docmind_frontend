import 'package:flutter/material.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/utils/supabase_client.dart';
import '../../chat/models/chat_session_model.dart';

class HistoryService {
  // ─── Load all sessions for current user ──────────────
  Future<List<ChatSessionModel>> loadSessions() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase
          .from(SupabaseConstants.tableChatSessions)
          .select()
          .eq(SupabaseConstants.colUserId, userId)
          .order(SupabaseConstants.colUpdatedAt, ascending: false);

      return (response as List)
          .map((json) => ChatSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Load sessions error: $e');
      return [];
    }
  }

  // ─── Create new session ───────────────────────────────
  Future<void> createSession(ChatSessionModel session) async {
  try {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // ✅ Use upsert — creates or updates
    await supabase
        .from(SupabaseConstants.tableChatSessions)
        .upsert({
          'id': session.id,
          SupabaseConstants.colUserId: userId,
          SupabaseConstants.colTitle: session.title,
          SupabaseConstants.colIsPinned: session.isPinned,
          SupabaseConstants.colCreatedAt:
              session.updatedAt.toIso8601String(),
          SupabaseConstants.colUpdatedAt:
              session.updatedAt.toIso8601String(),
        });

    debugPrint('✅ Session upserted: ${session.id}');
  } catch (e) {
    debugPrint('❌ Create session error: $e');
  }
}

  // ─── Update session title + last message ─────────────
  Future<void> updateSession({
    required String sessionId,
    required String title,
  }) async {
    try {
      await supabase
          .from(SupabaseConstants.tableChatSessions)
          .update({
            SupabaseConstants.colTitle: title,
            SupabaseConstants.colUpdatedAt:
                DateTime.now().toIso8601String(),
          })
          .eq(SupabaseConstants.colId, sessionId);
    } catch (e) {
      debugPrint('❌ Update session error: $e');
    }
  }

  // ─── Pin / Unpin session ──────────────────────────────
  Future<void> togglePin({
    required String sessionId,
    required bool isPinned,
  }) async {
    try {
      await supabase
          .from(SupabaseConstants.tableChatSessions)
          .update({
            SupabaseConstants.colIsPinned: isPinned,
          })
          .eq(SupabaseConstants.colId, sessionId);

      debugPrint('📌 Pin toggled: $sessionId → $isPinned');
    } catch (e) {
      debugPrint('❌ Toggle pin error: $e');
    }
  }

  // ─── Delete session ───────────────────────────────────
  Future<void> deleteSession(String sessionId) async {
    try {
      await supabase
          .from(SupabaseConstants.tableChatSessions)
          .delete()
          .eq(SupabaseConstants.colId, sessionId);

      debugPrint('🗑️ Session deleted: $sessionId');
    } catch (e) {
      debugPrint('❌ Delete session error: $e');
    }
  }
}