import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/theme/app_colors.dart';

/// Gradient hero card at the top of Profile - avatar, name, grade/school,
/// and the level/XP/streak/badge count row. Same gradient as Home's
/// header for a consistent look across the two.
class ProfileHeader extends StatelessWidget {
  final String name;
  final String gradeAndSchool;
  final int level;
  final int xp;
  final int streak;
  final int badgeCount;
  final VoidCallback onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.gradeAndSchool,
    required this.level,
    required this.xp,
    required this.streak,
    required this.badgeCount,
    required this.onAvatarTap,
  });

  String get _initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  _initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: onAvatarTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 4),

          Text(
            gradeAndSchool,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeaderStat(label: 'Level', value: '$level'),
              _HeaderDivider(),
              _HeaderStat(label: 'XP', value: '$xp'),
              _HeaderDivider(),
              _HeaderStat(label: 'Streak', value: '${streak}d'),
              _HeaderDivider(),
              _HeaderStat(label: 'Badges', value: '$badgeCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.2));
  }
}
