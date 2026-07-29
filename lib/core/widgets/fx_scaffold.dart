import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/theme/app_colors.dart';
import 'package:foundationx_frontend/core/theme/app_text_styles.dart';

/// Scaffold with a floating, snapping app bar in the app's primary blue 

class FXScaffold extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget body;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FXScaffold({
    super.key,
    required this.title,
    required this.body,
    this.centerTitle = false,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            centerTitle: centerTitle,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            automaticallyImplyLeading: false,
            title: Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: foregroundColor ?? Colors.white,
              ),
            ),
            leading: leading ??
                (showBackButton && Navigator.canPop(context)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null),
            actions: actions,
          ),
        ],
        body: body,
      ),
    );
  }
}
