import 'package:flutter/material.dart';
import '../utils/validators.dart'; // we use the helper methods from validators.dart

class PasswordStrengthBar extends StatelessWidget {
  final int score; // number from 0 to 4

  const PasswordStrengthBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // get color + label based on score
    final color = colorPwd(context, score);
    final label = labelPwd(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // colored strength bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: (score / 4).clamp(0, 1), // ensures it's always between 0-1
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(.15),
          ),
        ),
        const SizedBox(height: 6),
        // label shows "Weak", "Okay", etc.
        Text(
          'Password Strength: $label',
          style: TextStyle(
            fontSize: 12.5,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
