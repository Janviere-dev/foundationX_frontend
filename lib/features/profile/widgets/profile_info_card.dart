import 'package:flutter/material.dart';

import 'package:foundationx_frontend/core/theme/app_colors.dart';

class ProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });
}

/// White rounded card of label/value rows - used for both "Account
/// Information" (read-only) and the inline "Settings" section (some rows
/// carry a Switch, some a chevron) so both share one consistent look.
class ProfileInfoCard extends StatelessWidget {
  final List<ProfileInfoItem> items;

  const ProfileInfoCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].icon, color: AppColors.primary, size: 20),
              title: Text(
                items[i].label,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              subtitle: Text(
                items[i].value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: items[i].trailing ??
                  (items[i].onTap != null
                      ? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400)
                      : null),
              onTap: items[i].onTap,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            if (i < items.length - 1)
              Divider(height: 1, indent: 52, color: Theme.of(context).dividerColor),
          ],
        ],
      ),
    );
  }
}
