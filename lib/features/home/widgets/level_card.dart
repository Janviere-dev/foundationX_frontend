import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/constants/app_padding.dart';
import 'package:foundationx_frontend/core/constants/app_radius.dart';
import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/theme/app_colors.dart';

class LevelCard extends StatelessWidget {
  final int level;
  final int xp;
  final int xpForNextLevel;
  final double progress;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.xp,
    required this.xpForNextLevel,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (xpForNextLevel - xp).clamp(0, xpForNextLevel);
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.extraLarge,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.extraLarge,
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Level $level",
                        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$xp XP total",
                        style: textTheme.bodyMedium?.copyWith(
                          color: textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: Text(
                    "$remaining XP to Level ${level + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            ClipRRect(
              borderRadius: AppRadius.pillRadius,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.progressBackground,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
