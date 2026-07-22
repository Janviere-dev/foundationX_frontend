import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foundationx_frontend/core/constants/app_spacing.dart';
import 'package:foundationx_frontend/core/providers/theme_provider.dart';
import 'package:foundationx_frontend/core/widgets/fx_app_bar.dart';
import 'package:foundationx_frontend/core/widgets/fx_card.dart';
import 'package:foundationx_frontend/core/widgets/fx_section_title.dart';
import 'package:foundationx_frontend/features/notifications/providers/notification_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _soundKey = 'settings_sound_effects';
  static const _reminderKey = 'settings_daily_reminder';

  late SharedPreferences _prefs;
  bool _loaded = false;
  bool _soundEffects = true;
  bool _dailyReminder = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _soundEffects = prefs.getBool(_soundKey) ?? true;
      _dailyReminder = prefs.getBool(_reminderKey) ?? true;
      _loaded = true;
    });
  }

  Future<void> _setSoundEffects(bool value) async {
    setState(() => _soundEffects = value);
    await _prefs.setBool(_soundKey, value);
  }

  Future<void> _setDailyReminder(bool value) async {
    setState(() => _dailyReminder = value);
    await _prefs.setBool(_reminderKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: const FXAppBar(title: 'Settings'),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const FXSectionTitle(title: 'Appearance'),
                FXCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                const FXSectionTitle(title: 'Notifications'),
                FXCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable notifications'),
                        subtitle: const Text(
                          'Achievement unlocks and app updates',
                        ),
                        value: notificationProvider.enabled,
                        onChanged: (value) =>
                            notificationProvider.setEnabled(value),
                      ),
                      const Divider(height: AppSpacing.lg),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Daily reminder'),
                        subtitle: const Text(
                          'Get reminded to keep your streak going',
                        ),
                        value: _dailyReminder,
                        onChanged: _setDailyReminder,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                const FXSectionTitle(title: 'Sound'),
                FXCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sound effects'),
                    subtitle: const Text('Play sounds for correct/incorrect answers'),
                    value: _soundEffects,
                    onChanged: _setSoundEffects,
                  ),
                ),
              ],
            ),
    );
  }
}