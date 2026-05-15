import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/document_model.dart';

class DocumentItemCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onRemove;

  const DocumentItemCard({
    super.key,
    required this.document,
    required this.onRemove,
  });

  IconData get _fileIcon {
    if (document.isPdf) return Icons.picture_as_pdf_rounded;
    if (document.isImage) return Icons.image_rounded;
    return Icons.description_rounded;
  }

  Color get _fileColor {
    if (document.isPdf) return AppColors.error;
    if (document.isImage) return AppColors.info;
    return AppColors.success;
  }

  String get _tokenLabel {
    final t = document.estimatedTokens;
    if (t >= 1000) return '~${(t / 1000).toStringAsFixed(1)}k tokens';
    return '~$t tokens';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // File type icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _fileColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_fileIcon, color: _fileColor, size: 22),
          ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: AppTypography.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Chip(
                      label: document.readableSize,
                      color: AppColors.textSecondary,
                    ),

                    _Chip(label: _tokenLabel, color: AppColors.primary),

                    _StatusDot(status: document.status),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.05, end: 0);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final DocumentStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case DocumentStatus.ready:
        color = AppColors.success;
        label = 'Ready';
        break;
      case DocumentStatus.validating:
        color = AppColors.warning;
        label = 'Uploading...'; // ✅ was "Checking..."
        break;
      case DocumentStatus.overBudget:
        color = AppColors.error;
        label = 'Over budget';
        break;
      case DocumentStatus.error:
        color = AppColors.error;
        label = 'Failed'; // ✅ was missing
        break;
      case DocumentStatus.picking:
        color = AppColors.textHint;
        label = 'Pending';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
      ],
    );
  }
}
