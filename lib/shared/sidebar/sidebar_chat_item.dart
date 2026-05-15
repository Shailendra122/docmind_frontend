import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SidebarChatItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const SidebarChatItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isPinned,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  @override
  State<SidebarChatItem> createState() => _SidebarChatItemState();
}

class _SidebarChatItemState extends State<SidebarChatItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.sidebarActive
                : _isHovered
                ? AppColors.sidebarHover
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isActive
                ? Border.all(color: AppColors.border, width: 1)
                : null,
          ),
          child: Row(
            children: [
              if (widget.isPinned)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 12,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),

              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 15,
                  color: widget.isActive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.labelLarge.copyWith(
                        color: widget.isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: widget.isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTypography.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (_isHovered || widget.isActive)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIcon(
                      icon: widget.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: widget.isPinned
                          ? AppColors.primary
                          : AppColors.textHint,
                      onTap: widget.onPin,
                      tooltip: widget.isPinned ? 'Unpin' : 'Pin',
                    ),
                    const SizedBox(width: 4),
                    _ActionIcon(
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.textHint,
                      onTap: widget.onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionIcon({
    required this.icon,
    required this.color,
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
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
