import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final bool isStreaming;
  final bool isUploading; 
  final VoidCallback onUpload;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isStreaming,
    required this.onUpload,
    this.isUploading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isStreaming || widget.isUploading) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input row
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Upload button
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: _IconBtn(
                        icon: Icons.attach_file_rounded,
                        onTap: widget.onUpload,
                        tooltip: 'Upload document',
                      ),
                    ),

                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: 6,
                        minLines: 1,
                        style: AppTypography.bodyMedium,
                        textInputAction: TextInputAction.newline,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: widget.isUploading
                              ? 'Processing document...'
                              : 'Ask anything about your document...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    // Send button
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: widget.isStreaming
                            ? _StopButton(onTap: () {})
                            : _SendButton(isActive: _hasText, onTap: _send),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Hint text
              Text(
                'Docmind can make mistakes. Verify important information.',
                style: AppTypography.labelSmall.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _SendButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.gradientPrimary : null,
          color: isActive ? null : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 18,
          color: isActive ? Colors.white : AppColors.textHint,
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Icon(Icons.stop_rounded, size: 18, color: AppColors.error),
      ),
    );
  }
}
