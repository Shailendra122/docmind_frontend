import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../document/models/document_model.dart';

class DocumentChipsBar extends StatelessWidget {
  final List<DocumentModel> documents;
  final VoidCallback onAddMore;

  const DocumentChipsBar({
    super.key,
    required this.documents,
    required this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            ...documents.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _DocumentChip(doc: doc),
              ),
            ),
            _ReplaceChip(onTap: onAddMore),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}

class _DocumentChip extends StatelessWidget {
  final DocumentModel doc;
  const _DocumentChip({required this.doc});

  IconData get _icon {
    if (doc.isPdf) return Icons.picture_as_pdf_rounded;
    if (doc.isImage) return Icons.image_rounded;
    return Icons.description_rounded;
  }

  Color get _color {
    if (doc.isPdf) return AppColors.error;
    if (doc.isImage) return AppColors.info;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_icon, size: 12, color: _color),
          ),
          const SizedBox(width: 6),

          // File name
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              doc.fileName,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),

          // Token count
          Text(
            doc.readableSize,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // Status dot
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: doc.status == DocumentStatus.ready
                  ? AppColors.success
                  : doc.status == DocumentStatus.validating
                  ? AppColors.warning
                  : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplaceChip extends StatelessWidget {
  final VoidCallback onTap;
  const _ReplaceChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Replace',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
