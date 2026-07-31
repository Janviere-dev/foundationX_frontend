import 'package:flutter/material.dart';

/// Row of dots showing progress through the onboarding carousel. Always
/// rendered in white since it sits on top of a colored gradient background.
class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: currentIndex == index ? 1 : 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
