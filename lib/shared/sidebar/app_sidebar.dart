import 'package:docmind_flutter/shared/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/history/bloc/history_bloc.dart';
import 'sidebar_header.dart';
import 'sidebar_chat_item.dart';

class AppSidebar extends StatelessWidget {
  final VoidCallback onNewChat;
  final Function(String sessionId) onChatSelected;
  final Function(String sessionId) onChatDeleted;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.onNewChat,
    required this.onChatSelected,
    required this.onChatDeleted,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SidebarHeader(onNewChat: onNewChat),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryLoading) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: const [
                        SidebarItemSkeleton(),
                        SidebarItemSkeleton(),
                        SidebarItemSkeleton(),
                        SidebarItemSkeleton(),
                      ],
                    );
                  }
        
                  if (state is! HistoryLoaded) {
                    return const SidebarItemSkeleton();
                  }
        
                  if (state.sessions.isEmpty) {
                    return _EmptySidebar(onNewChat: onNewChat);
                  }
        
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (state.pinnedSessions.isNotEmpty) ...[
                        _SectionLabel(label: 'PINNED'),
                        ...state.pinnedSessions.map(
                          (session) => SidebarChatItem(
                            title: session.title,
                            subtitle: session.lastMessage,
                            isActive: state.activeSessionId == session.id,
                            isPinned: session.isPinned,
                            onTap: () => onChatSelected(session.id),
                            onPin: () => context.read<HistoryBloc>().add(
                              HistorySessionPinToggled(session.id),
                            ),
                            onDelete: () => onChatDeleted(session.id), 
                          ).animate().fadeIn(duration: 200.ms),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (state.recentSessions.isNotEmpty) ...[
                        _SectionLabel(label: 'RECENT'),
                        ...state.recentSessions.map(
                          (session) => SidebarChatItem(
                            title: session.title,
                            subtitle: session.lastMessage,
                            isActive: state.activeSessionId == session.id,
                            isPinned: session.isPinned,
                            onTap: () => onChatSelected(session.id),
                            onPin: () => context.read<HistoryBloc>().add(
                              HistorySessionPinToggled(session.id),
                            ),
                            onDelete: () => onChatDeleted(session.id), 
                          ).animate().fadeIn(duration: 200.ms),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            _SidebarFooter(onLogout: onLogout),
          ],
        ),
      ),
    );
  }
}

class _EmptySidebar extends StatelessWidget {
  final VoidCallback onNewChat;
  const _EmptySidebar({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.textHint,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No chats yet',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text('Start a new chat to begin', style: AppTypography.bodySmall),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onNewChat,
            icon: const Icon(
              Icons.add_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              'New Chat',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(label, style: AppTypography.labelSmall),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final VoidCallback onLogout;
  const _SidebarFooter({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.isNotEmpty ? email : 'My Account',
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('Free Plan', style: AppTypography.labelSmall),
              ],
            ),
          ),
          Tooltip(
            message: 'Logout',
            child: GestureDetector(
              onTap: onLogout,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
