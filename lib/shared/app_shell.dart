import 'package:docmind_flutter/features/chat/screens/chat_screen.dart';
import 'package:docmind_flutter/features/document/widgets/document_upload_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/chat/bloc/chat_bloc.dart';
import '../../features/document/bloc/document_bloc.dart';
import '../../features/history/bloc/history_bloc.dart';
import '../../features/profile/screens/profile_screen.dart';
import 'sidebar/app_sidebar.dart';
import 'bottom_nav/app_bottom_nav.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isWideScreen =>
      MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;

  // ✅ Central new chat handler — always updates both blocs
  void _startNewChat() {
    final chatState = context.read<ChatBloc>().state;

    // ✅ Already on empty chat → just animate
    if (chatState is ChatLoaded && chatState.messages.isEmpty) {
      context.read<ChatBloc>().add(ChatAlreadyNew());
      return;
    }

    // Has messages → start fresh
    context.read<DocumentBloc>().add(DocumentsCleared());
    context.read<ChatBloc>().add(ChatCleared());

    if (!_isWideScreen) {
      _scaffoldKey.currentState?.closeDrawer();
    }

    setState(() => _currentNavIndex = 0);
  }

  // ✅ Central delete handler — always updates both blocs
  void _deleteChat(String sessionId) {
    final chatState = context.read<ChatBloc>().state;
    final isCurrentChat =
        chatState is ChatLoaded && chatState.sessionId == sessionId;

    // 1. Remove from history sidebar
    context.read<HistoryBloc>().add(HistorySessionDeleted(sessionId));

    // 2. If deleted chat is current → start fresh
    if (isCurrentChat) {
      context.read<DocumentBloc>().add(DocumentsCleared());
      context.read<ChatBloc>().add(ChatCleared());
      debugPrint('🗑️ Current chat deleted → new session');
    }

    // 3. Close drawer on mobile
    if (!_isWideScreen) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  // ✅ Central select handler
  void _selectChat(String sessionId) {
    final chatState = context.read<ChatBloc>().state;
    if (chatState is ChatLoaded && chatState.sessionId == sessionId) {
      if (!_isWideScreen) _scaffoldKey.currentState?.closeDrawer();
      return;
    }

    context.read<ChatBloc>().add(ChatSessionSelected(sessionId));
    context.read<DocumentBloc>().add(DocumentsCleared());

    // ✅ Use event instead of emit
    context.read<HistoryBloc>().add(HistoryActiveSessionSet(sessionId));

    if (!_isWideScreen) _scaffoldKey.currentState?.closeDrawer();
  }

  void _onLogout() {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        context.go('/chat');
        break;
      case 1:
        _scaffoldKey.currentState?.openDrawer();
        break;
      case 2:
        _startNewChat();
        context.go('/chat');
        break;
      case 3:
        // ✅ Open document upload sheet
        _openDocumentUpload();
        break;
      case 4:
        _showProfileSheet();
        break;
    }
  }

  void _openDocumentUpload() {
    // Get current session ID from ChatBloc
    final chatState = context.read<ChatBloc>().state;
    final sessionId = chatState is ChatLoaded ? chatState.sessionId : '';

    if (sessionId.isEmpty) return;

    // Sync session to DocumentBloc
    context.read<DocumentBloc>().add(DocumentSessionUpdated(sessionId));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      DocumentUploadSheet.show(
        context,
        onDocumentsReady: (List<String> docIds) {
          if (!mounted) return;
          context.read<ChatBloc>().add(ChatDocumentIdsUpdated(docIds));
          // ✅ Switch to chat tab after upload
          setState(() => _currentNavIndex = 0);
          context.go('/chat');
        },
      );
    });
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [BlocProvider.value(value: context.read<AuthBloc>())],
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const ProfileScreen(),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<AuthBloc>()),
        BlocProvider.value(value: context.read<HistoryBloc>()),
        BlocProvider.value(value: context.read<ChatBloc>()),
        BlocProvider.value(value: context.read<DocumentBloc>()),
      ],
      child: AppSidebar(
        onNewChat: _startNewChat,
        onChatSelected: _selectChat,
        onChatDeleted: _deleteChat, // ✅ central delete
        onLogout: _onLogout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgDark,
      drawer: _isWideScreen
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              width: 280,
              child: SafeArea(child: _buildSidebar()),
            ),
      body: _isWideScreen
          ? Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: ChatScreen(
                    onMenuPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
              ],
            )
          : ChatScreen(
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
      bottomNavigationBar: _isWideScreen
          ? null
          : AppBottomNav(
              currentIndex: _currentNavIndex,
              onTap: _onBottomNavTap,
            ),
    );
  }
}
