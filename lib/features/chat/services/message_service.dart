import 'package:flutter/material.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/utils/supabase_client.dart';
import '../models/message_model.dart';

class MessageService {
  // ─── Save single message ──────────────────────────────
  Future<void> saveMessage({
    required String sessionId,
    required MessageModel message,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      debugPrint('💾 Saving message — session: $sessionId, user: $userId');

      await supabase.from(SupabaseConstants.tableMessages).insert({
        'id': message.id,
        SupabaseConstants.colSessionId: sessionId,
        SupabaseConstants.colRole: message.isUser
            ? SupabaseConstants.roleUser
            : SupabaseConstants.roleAssistant,
        SupabaseConstants.colContent: message.content,
        SupabaseConstants.colCreatedAt: message.createdAt.toIso8601String(),
      });

      debugPrint('✅ Message saved successfully');
    } catch (e) {
      debugPrint('❌ Save message error: $e');
      rethrow;
    }
  }

  // ─── Load messages for a session ─────────────────────
  Future<List<MessageModel>> loadMessages(String sessionId) async {
    try {
      debugPrint('📂 Loading messages for session: $sessionId');

      final response = await supabase
          .from(SupabaseConstants.tableMessages)
          .select()
          .eq(SupabaseConstants.colSessionId, sessionId)
          .order(SupabaseConstants.colCreatedAt, ascending: true);

      final messages = (response as List)
          .map(
            (json) =>
                MessageModel.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();

      debugPrint('✅ Loaded ${messages.length} messages for $sessionId');
      return messages;
    } catch (e) {
      debugPrint('❌ Load messages error: $e');
      return [];
    }
  }

  // ─── Delete all messages for a session ───────────────
  Future<void> deleteMessages(String sessionId) async {
    try {
      await supabase
          .from(SupabaseConstants.tableMessages)
          .delete()
          .eq(SupabaseConstants.colSessionId, sessionId);
    } catch (e) {
      debugPrint('❌ Delete messages error: $e');
    }
  }
}
