import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgElevated,
      highlightColor: AppColors.bgCard,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// Chat message skeleton
class ChatMessageSkeleton extends StatelessWidget {
  final bool isUser;
  const ChatMessageSkeleton({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            SkeletonLoader(width: 32, height: 32, borderRadius: 10),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              SkeletonLoader(
                width: isUser ? 200 : 280,
                height: 14,
                borderRadius: 6,
              ),
              const SizedBox(height: 6),
              SkeletonLoader(
                width: isUser ? 150 : 240,
                height: 14,
                borderRadius: 6,
              ),
              const SizedBox(height: 6),
              SkeletonLoader(
                width: isUser ? 100 : 180,
                height: 14,
                borderRadius: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sidebar chat item skeleton
class SidebarItemSkeleton extends StatelessWidget {
  const SidebarItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          SkeletonLoader(width: 32, height: 32, borderRadius: 8),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 6),
                SkeletonLoader(
                  width: 120,
                  height: 10,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}