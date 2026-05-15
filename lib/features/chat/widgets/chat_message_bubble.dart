import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/code_block.dart';
import '../models/message_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isStreaming;
  final String streamingText;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.streamingText = '',
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final displayContent = isStreaming && !isUser
        ? streamingText
        : message.content;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[_AiAvatar(), const SizedBox(width: 10)],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isUser)
                  _UserBubble(content: displayContent)
                else
                  _AiBubble(content: displayContent, isStreaming: isStreaming),
                const SizedBox(height: 4),
                _Timestamp(time: message.createdAt, isUser: isUser),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0);
  }
}

// ─── User Bubble ───────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final String content;
  const _UserBubble({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _copyToClipboard(context, content),
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              (MediaQuery.of(context).size.width < 600 ? 0.78 : 0.72),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          content,
          style: AppTypography.chatMessage.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ─── AI Bubble ─────────────────────────────────────────

class _AiBubble extends StatelessWidget {
  final String content;
  final bool isStreaming;

  const _AiBubble({required this.content, required this.isStreaming});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width *
            (MediaQuery.of(context).size.width < 600 ? 0.88 : 0.82),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message content
          _buildContent(context),

          // Action bar — copy full message
          if (!isStreaming && content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: _MessageActionBar(content: content),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Parse content for code blocks
    final segments = _parseSegments(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((segment) {
        if (segment['type'] == 'code') {
          return CodeBlock(
            code: segment['content']!,
            language: segment['language'] ?? 'plaintext',
          );
        }

        // Regular markdown text
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.aiBubble,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: segment['content']!,
                styleSheet: MarkdownStyleSheet(
                  p: AppTypography.chatMessage,
                  strong: AppTypography.chatMessage.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  em: AppTypography.chatMessage.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  blockquote: AppTypography.chatMessage.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ),
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                  h1: AppTypography.headingMedium,
                  h2: AppTypography.headingSmall,
                  h3: AppTypography.labelLarge.copyWith(fontSize: 15),
                  listBullet: AppTypography.chatMessage,
                  tableHead: AppTypography.labelLarge,
                  tableBody: AppTypography.bodyMedium,
                  tableBorder: TableBorder.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  code: AppTypography.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.primaryLight,
                    backgroundColor: AppColors.bgInput,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // Blinking cursor while streaming
              if (isStreaming)
                Container(
                      width: 2,
                      height: 16,
                      margin: const EdgeInsets.only(top: 4),
                      color: AppColors.primary,
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 500.ms)
                    .then()
                    .fadeOut(duration: 500.ms),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Parse message into text and code segments
  List<Map<String, String>> _parseSegments(String content) {
    final segments = <Map<String, String>>[];
    final codeBlockRegex = RegExp(r'```(\w*)\n?([\s\S]*?)```');
    int lastEnd = 0;

    for (final match in codeBlockRegex.allMatches(content)) {
      // Text before code block
      if (match.start > lastEnd) {
        final text = content.substring(lastEnd, match.start).trim();
        if (text.isNotEmpty) {
          segments.add({'type': 'text', 'content': text});
        }
      }

      // Code block
      final language = match.group(1)?.trim() ?? 'plaintext';
      final code = match.group(2)?.trim() ?? '';
      if (code.isNotEmpty) {
        segments.add({
          'type': 'code',
          'content': code,
          'language': language.isEmpty ? 'plaintext' : language,
        });
      }

      lastEnd = match.end;
    }

    // Remaining text after last code block
    if (lastEnd < content.length) {
      final text = content.substring(lastEnd).trim();
      if (text.isNotEmpty) {
        segments.add({'type': 'text', 'content': text});
      }
    }

    // If no segments found, treat entire content as text
    if (segments.isEmpty) {
      segments.add({'type': 'text', 'content': content});
    }

    return segments;
  }
}

// ─── Message Action Bar ────────────────────────────────

class _MessageActionBar extends StatelessWidget {
  final String content;
  const _MessageActionBar({required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_CopyIconButton(content: content)],
    );
  }
}

// ✅ Icon only — shows checkmark on copy
class _CopyIconButton extends StatefulWidget {
  final String content;
  const _CopyIconButton({required this.content});

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<_CopyIconButton> {
  bool _copied = false;

  Future<void> _copy() async {
    if (_copied) return;
    await Clipboard.setData(ClipboardData(text: widget.content));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _copied
              ? AppColors.success.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _copied
                ? AppColors.success.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            key: ValueKey(_copied),
            size: 14,
            color: _copied ? AppColors.success : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _done = false;

  void _handle() async {
    widget.onTap();
    setState(() => _done = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _done = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _done
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _done
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _done ? Icons.check_rounded : widget.icon,
              size: 13,
              color: _done ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              _done ? 'Copied!' : widget.label,
              style: AppTypography.labelSmall.copyWith(
                color: _done ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ────────────────────────────────────

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
    );
  }
}

class _Timestamp extends StatelessWidget {
  final DateTime time;
  final bool isUser;

  const _Timestamp({required this.time, required this.isUser});

  String _format(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_format(time), style: AppTypography.chatTimestamp);
  }
}

void _copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text(
        '✅ Copied to clipboard',
        style: TextStyle(color: Colors.white, fontSize: 13),
      ),
      backgroundColor: const Color(0xFF2A2A32),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
