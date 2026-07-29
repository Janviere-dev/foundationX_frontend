import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foundationx_frontend/core/constants/app_padding.dart';
import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/widgets/fx_avatar.dart';

class GreetingHeader extends StatelessWidget {
  final String firstName;
  final String lastName;
  final int notifications;

  const GreetingHeader({
    super.key,
    required this.firstName,
    required this.lastName,
    this.notifications = 0,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning!";
    if (hour < 17) return "Good afternoon!";
    return "Good evening!";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FXAvatar(
                name: firstName,
                radius: AppSpacing.avatarSmall,
                onTap: () {},
              ),

              const SizedBox(width: AppSpacing.sm),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 2),

                  Text(
                    "$firstName $lastName".trim(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              const Spacer(),

              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/notifications');
                    },
                    icon: const Icon(Icons.notifications_outlined),
                  ),

                  if (notifications > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          notifications > 9
                              ? "9+"
                              : notifications.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            "Personalize your studies starting from today.",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
