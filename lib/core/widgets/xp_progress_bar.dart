import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:foundationx_frontend/core/models/models.dart';

class XPProgressBar extends StatelessWidget {
  final UserModel user;
  final double percent;

  const XPProgressBar({
    super.key,
    required this.user,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Level ${user.level}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${user.xpPoints} XP"),
              ],
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              percent: percent.clamp(0.0, 1.0),
              lineHeight: 12,
              backgroundColor: Colors.grey.shade200,
              progressColor: Colors.orange,
              barRadius: const Radius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}