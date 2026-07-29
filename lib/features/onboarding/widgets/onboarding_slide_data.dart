import 'package:flutter/material.dart';

/// Content + gradient for a single onboarding slide. The gradient is what
/// tints the whole screen behind [OnboardingScreen] while this slide is in
/// view - see [OnboardingSlideContent] for how the rest is laid out on top.
class OnboardingSlideData {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String description;

  const OnboardingSlideData({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.description,
  });
}

/// Text color used for the primary button on every slide. Kept constant
/// (rather than following each slide's gradient) so the button reads as a
/// single consistent brand accent as the user swipes through.
const Color kOnboardingAccentColor = Color(0xFF241A5E);

const List<OnboardingSlideData> onboardingSlides = [
  OnboardingSlideData(
    icon: Icons.phone_iphone_rounded,
    gradientColors: [Color(0xFF241A5E), Color(0xFF3D4FD6)],
    title: 'Learn Anywhere, Anytime',
    description:
        'Access curriculum-aligned lessons on your phone, even offline. '
        'Your classroom fits in your pocket.',
  ),
  OnboardingSlideData(
    icon: Icons.foundation_rounded,
    gradientColors: [Color(0xFF5B1F91), Color(0xFF7B2FB5)],
    title: 'Strengthen Your Foundations',
    description:
        'Fill learning gaps with short, clear explanations and visual '
        'examples. Master the basics before moving forward.',
  ),
  OnboardingSlideData(
    icon: Icons.emoji_events_rounded,
    gradientColors: [Color(0xFFB3123F), Color(0xFFF0294F)],
    title: 'Learn Through Gameplay',
    description:
        'Earn XP, collect badges, and climb leaderboards. Make studying '
        'fun and stay motivated every day.',
  ),
  OnboardingSlideData(
    icon: Icons.bar_chart_rounded,
    gradientColors: [Color(0xFF0F5132), Color(0xFF1FA463)],
    title: 'Track Your Progress',
    description:
        'See exactly where you stand in every subject. Get personalized '
        'recommendations to prepare for exams.',
  ),
];
