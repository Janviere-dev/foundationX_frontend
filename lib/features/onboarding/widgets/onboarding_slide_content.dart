import 'package:flutter/material.dart';

import 'package:foundationx_frontend/features/onboarding/widgets/onboarding_slide_data.dart';

/// Icon avatar + title + description for one onboarding slide. Left-aligned
/// to sit on top of the full-screen gradient painted by [OnboardingScreen].
class OnboardingSlideContent extends StatelessWidget {
  final OnboardingSlideData slide;

  const OnboardingSlideContent({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(slide.icon, color: Colors.white, size: 34),
          ),

          const SizedBox(height: 40),

          Text(
            slide.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            slide.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
