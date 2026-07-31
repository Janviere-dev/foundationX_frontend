import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/constants/app_padding.dart';
import 'package:foundationx_frontend/core/constants/app_radius.dart';
import 'package:foundationx_frontend/core/constants/app_spacing.dart';

class DailyQuizCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onStart;

  const DailyQuizCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: AppPadding.card,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
        ),
        borderRadius: AppRadius.extraLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Daily Quiz",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          InkWell(
            onTap: onStart,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, color: Colors.deepOrange.shade600, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
