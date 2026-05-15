import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/document_bloc.dart';
import '../widgets/document_item_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DocumentUploadSheet extends StatelessWidget {
  final Function(List<String> docIds) onDocumentsReady;

  const DocumentUploadSheet({
    super.key,
    required this.onDocumentsReady,
  });

  static void show(
    BuildContext context, {
    required Function(List<String> docIds) onDocumentsReady,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<DocumentBloc>(),
        child: DocumentUploadSheet(onDocumentsReady: onDocumentsReady),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: AppColors.border),
              left: BorderSide(color: AppColors.border),
              right: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.upload_file_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Document',
                          style: AppTypography.headingSmall,
                        ),
                        Text(
                          'PDF, image or text • Max 10MB',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.bgElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),

              // Content
              Expanded(
                child: BlocConsumer<DocumentBloc, DocumentState>(
                  listener: (context, state) {
                    if (state is DocumentLoaded &&
                        state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is! DocumentLoaded) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [

                        // ✅ Info banner — single doc only
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.info,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'One document per chat. Uploading a new file replaces the current one.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ✅ Show current document if exists
                        if (state.hasDocument) ...[
                          Text(
                            'Current Document',
                            style: AppTypography.labelLarge,
                          ),
                          const SizedBox(height: 10),
                          DocumentItemCard(
                            document: state.currentDocument!,
                            onRemove: () => context
                                .read<DocumentBloc>()
                                .add(DocumentRemoved(
                                  state.currentDocument!.id,
                                )),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ✅ Upload / Replace zone
                        _UploadZone(
                          hasDocument: state.hasDocument,
                          isUploading: state.isUploading,
                          onTap: () => context
                              .read<DocumentBloc>()
                              .add(DocumentPickRequested()),
                        ).animate().fadeIn(duration: 300.ms),

                        const SizedBox(height: 20),

                        // ✅ Done button
                        if (state.isReady && !state.isUploading)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final doc = state.currentDocument;
                                if (doc?.backendId != null) {
                                  debugPrint('✅ Syncing docId: ${doc!.backendId}');
                                  onDocumentsReady([doc.backendId!]);
                                } else {
                                  onDocumentsReady([]);
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('Done — Start Chatting'),
                            ),
                          ).animate().fadeIn(delay: 100.ms),

                        // Processing indicator
                        if (state.isUploading)
                          Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Processing document...',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Upload Zone ───────────────────────────────────────

class _UploadZone extends StatefulWidget {
  final bool hasDocument;
  final bool isUploading;
  final VoidCallback onTap;

  const _UploadZone({
    required this.hasDocument,
    required this.isUploading,
    required this.onTap,
  });

  @override
  State<_UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<_UploadZone> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isUploading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.hasDocument
                    ? 'Replace with another document'
                    : 'Upload a document',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, PNG, JPG, TXT • Max 10MB',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}