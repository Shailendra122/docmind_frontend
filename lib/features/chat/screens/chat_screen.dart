import 'dart:async';

import 'package:docmind_flutter/core/utils/pdf_download_helper.dart';
import 'package:docmind_flutter/features/chat/models/chat_session_model.dart';
import 'package:docmind_flutter/features/chat/models/message_model.dart';
import 'package:docmind_flutter/features/chat/services/export_service.dart';
import 'package:docmind_flutter/features/document/bloc/document_bloc.dart';
import 'package:docmind_flutter/features/document/models/document_model.dart';
import 'package:docmind_flutter/features/document/widgets/document_upload_sheet.dart';
import 'package:docmind_flutter/features/history/bloc/history_bloc.dart';
import 'package:docmind_flutter/shared/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_toast.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_welcome.dart';
import '../widgets/typing_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/document_chips_bar.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  const ChatScreen({super.key, this.onMenuPressed});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  final _welcomeKey = GlobalKey<ChatWelcomeState>();
  StreamSubscription? _chatSubscription;
  final _exportService = ExportService();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatNewSessionStarted());

    // Store subscription so we can cancel it
    _chatSubscription = context.read<ChatBloc>().stream.listen((state) {
      // Check mounted before using context
      if (!mounted) return;

      if (state is ChatLoaded && state.sessionId.isNotEmpty) {
        context.read<DocumentBloc>().add(
          DocumentSessionUpdated(state.sessionId),
        );
      }
    });

    // Sync current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentState = context.read<ChatBloc>().state;
      if (currentState is ChatLoaded) {
        context.read<DocumentBloc>().add(
          DocumentSessionUpdated(currentState.sessionId),
        );
      }
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _exportChat(BuildContext context) async {
    final chatState = context.read<ChatBloc>().state;
    if (chatState is! ChatLoaded) return;
    if (chatState.messages.isEmpty) return;

    final docState = context.read<DocumentBloc>().state;
    String? documentName;
    if (docState is DocumentLoaded && docState.hasDocument) {
      documentName = docState.currentDocument?.fileName;
    }

    setState(() => _isExporting = true);

    try {
      // ✅ Use first USER message as title
      final firstUserMsg = chatState.messages.firstWhere(
        (m) => m.isUser,
        orElse: () => chatState.messages.first,
      );

      final title = firstUserMsg.content.length > 60
          ? '${firstUserMsg.content.substring(0, 60)}...'
          : firstUserMsg.content;

      final bytes = await _exportService.exportChatAsPdf(
        title: title,
        messages: chatState.messages,
        documentName: documentName,
      );

      if (bytes != null && context.mounted) {
        final date = DateTime.now();
        final filename = 'docmind_${date.day}_${date.month}_${date.year}.pdf';

        await downloadPdf(bytes: bytes, filename: filename);

        if (context.mounted) {
          showSuccessToast(context, 'Chat exported successfully!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorToast(
          context,
          'Export failed: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // ✅ Check mounted
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openUploadSheet(BuildContext context, String sessionId) {
    if (sessionId.isEmpty) return;

    context.read<DocumentBloc>().add(DocumentSessionUpdated(sessionId));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      DocumentUploadSheet.show(
        context.mounted ? context : context,
        onDocumentsReady: (List<String> docIds) {
          if (!mounted) return;
          context.read<ChatBloc>().add(ChatDocumentIdsUpdated(docIds));
        },
      );
    });
  }

  void _startNewChat(BuildContext context) {
    final chatState = context.read<ChatBloc>().state;
    if (chatState is ChatLoaded && chatState.messages.isEmpty) {
      context.read<HistoryBloc>().add(
        HistorySessionDeleted(chatState.sessionId),
      );
    }
    context.read<DocumentBloc>().add(DocumentsCleared());
    context.read<ChatBloc>().add(ChatCleared());
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear Chat', style: AppTypography.headingSmall),
        content: Text(
          'What would you like to clear?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBloc>().add(ChatMessagesCleared());
              Navigator.pop(context);
            },
            child: Text(
              'Messages only',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final chatState = context.read<ChatBloc>().state;
              if (chatState is ChatLoaded) {
                context.read<HistoryBloc>().add(
                  HistorySessionDeleted(chatState.sessionId),
                );
              }
              context.read<DocumentBloc>().add(DocumentsCleared());
              context.read<ChatBloc>().add(ChatCleared());
            },
            child: Text(
              'Everything',
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildMessageList(context)),
                _buildDocumentChips(context),
                _buildInputBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      centerTitle: false,
      toolbarHeight: 68,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      leading: isWide
          ? null
          : IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.textSecondary,
              ),
              onPressed: widget.onMenuPressed,
            ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Docmind',
              style: AppTypography.headingSmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),

      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final hasMessages =
                state is ChatLoaded && state.messages.isNotEmpty;
            if (!hasMessages) return const SizedBox.shrink();
            return Tooltip(
              message: 'Clear messages',
              child: IconButton(
                icon: const Icon(
                  Icons.cleaning_services_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => _showClearDialog(context),
              ),
            );
          },
        ),

        // Export button
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final hasMessages =
                state is ChatLoaded && state.messages.isNotEmpty;
            if (!hasMessages) return const SizedBox.shrink();
            return Tooltip(
              message: 'Export as PDF',
              child: _isExporting
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => _exportChat(context),
                    ),
            );
          },
        ),

        // Upload button — icon only on mobile to save space
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final sessionId = state is ChatLoaded ? state.sessionId : '';

            //  Icon only on mobile, text+icon on web
            if (!isWide) {
              return IconButton(
                icon: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                onPressed: sessionId.isEmpty
                    ? null
                    : () => _openUploadSheet(context, sessionId),
                tooltip: 'Upload document',
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: sessionId.isEmpty
                    ? null
                    : () => _openUploadSheet(context, sessionId),
                icon: const Icon(
                  Icons.upload_file_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Upload',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          },
        ),

        // New chat button
        IconButton(
          icon: const Icon(
            Icons.add_circle_outline_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          onPressed: () => _startNewChat(context),
          tooltip: 'New chat',
        ),
      ],
    );
  }

  Widget _buildDocumentChips(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is! DocumentLoaded) return const SizedBox.shrink();
        if (state.documents.isEmpty) return const SizedBox.shrink();

        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, chatState) {
            final sessionId = chatState is ChatLoaded
                ? chatState.sessionId
                : '';
            return DocumentChipsBar(
              documents: state.documents,
              onAddMore: () => _openUploadSheet(context, sessionId),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is ChatLoaded && state.justReset) {
          // ✅ Show brief toast
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text(
                  'Already on a new chat',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                backgroundColor: AppColors.bgElevated,
                behavior: SnackBarBehavior.fixed,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }

        if (state is ChatLoaded) {
          _scrollToBottom();

          if (!state.isStreaming &&
              state.messages.isNotEmpty &&
              !state.messages.last.isUser) {
            final lastMsg = state.messages.last;
            final firstUserMsg = state.messages.firstWhere(
              (m) => m.isUser,
              orElse: () => state.messages.first,
            );

            final title = firstUserMsg.content.length > 40
                ? '${firstUserMsg.content.substring(0, 40)}...'
                : firstUserMsg.content;

            final lastMessage = lastMsg.content.length > 60
                ? '${lastMsg.content.substring(0, 60)}...'
                : lastMsg.content;

            try {
              final historyBloc = context.read<HistoryBloc>();
              final historyState = historyBloc.state;

              if (historyState is HistoryLoaded) {
                final exists = historyState.sessions.any(
                  (s) => s.id == state.sessionId,
                );

                if (!exists) {
                  historyBloc.add(
                    HistorySessionAdded(
                      ChatSessionModel(
                        id: state.sessionId,
                        title: title,
                        lastMessage: lastMessage,
                        updatedAt: DateTime.now(),
                      ),
                    ),
                  );
                } else {
                  historyBloc.add(
                    HistorySessionUpdated(
                      sessionId: state.sessionId,
                      title: title,
                      lastMessage: lastMessage,
                    ),
                  );
                }

                historyBloc.add(HistoryActiveSessionSet(state.sessionId));
              }
            } catch (e) {
              debugPrint('⚠️ History sync: $e');
            }
          }
        }
      },
      builder: (context, state) {
        // Skeleton loading
        if (state is ChatLoaded &&
            state.messages.isEmpty &&
            state.isStreaming) {
          return ListView(
            padding: const EdgeInsets.only(top: 16),
            children: const [
              ChatMessageSkeleton(isUser: false),
              ChatMessageSkeleton(isUser: true),
              ChatMessageSkeleton(isUser: false),
            ],
          );
        }

        if (state is ChatLoaded) {
          if (state.messages.isEmpty && !state.isStreaming) {
            // ✅ Trigger pulse if justReset
            if (state.justReset) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _welcomeKey.currentState?.playAnimation();
              });
            }

            return ChatWelcome(
              key: _welcomeKey,
              onSuggestionTap: (suggestion) {
                context.read<ChatBloc>().add(ChatMessageSent(suggestion));
              },
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
            itemBuilder: (context, index) {
              if (state.isStreaming && index == state.messages.length) {
                if (state.streamingText.isEmpty) {
                  return const TypingIndicator();
                }
                return ChatMessageBubble(
                  message: MessageModel(
                    id: 'streaming',
                    content: state.streamingText,
                    isUser: false,
                    createdAt: DateTime.now(),
                  ),
                  isStreaming: true,
                  streamingText: state.streamingText,
                );
              }
              return ChatMessageBubble(message: state.messages[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, docState) {
        final isUploading =
            docState is DocumentLoaded &&
            docState.documents.any(
              (d) => d.status == DocumentStatus.validating,
            );

        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, chatState) {
            final sessionId = chatState is ChatLoaded
                ? chatState.sessionId
                : '';
            final isStreaming =
                chatState is ChatLoaded && chatState.isStreaming;

            return ChatInputBar(
              isStreaming: isStreaming,
              isUploading: isUploading,
              onUpload: () => _openUploadSheet(context, sessionId),
              onSend: (message) {
                context.read<ChatBloc>().add(ChatMessageSent(message));
              },
            );
          },
        );
      },
    );
  }
}
