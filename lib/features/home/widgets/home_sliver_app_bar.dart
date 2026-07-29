import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/theme/app_colors.dart';
import 'package:foundationx_frontend/core/widgets/fx_avatar.dart';

/// Collapsing gradient header for Home, built on the framework's own
/// SliverAppBar/FlexibleSpaceBar rather than a hand-rolled
/// SliverPersistentHeaderDelegate - that geometry math is easy to get
/// subtly wrong (it crashed on real devices with different safe-area
/// insets than the ones this was first tested against). The notification
/// bell lives in `actions`, so it stays visible and tappable at any scroll
/// position while the greeting/streak/avatar scroll away with the rest of
/// the flexible space.
class HomeSliverAppBar extends StatelessWidget {
  final String firstName;
  final int streak;
  final int notifications;
  final VoidCallback onAvatarTap;

  const HomeSliverAppBar({
    super.key,
    required this.firstName,
    required this.streak,
    required this.notifications,
    required this.onAvatarTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning! 👋";
    if (hour < 17) return "Good afternoon! 👋";
    return "Good evening! 👋";
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 170,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            ),
            if (notifications > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    notifications > 9 ? "9+" : "$notifications",
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            firstName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("🔥", style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(
                            "$streak days",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FXAvatar(
                      name: firstName,
                      radius: 22,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      onTap: onAvatarTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
