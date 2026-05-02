import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class GovernoratesHeader extends StatelessWidget {
  const GovernoratesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // يفضل استخدام loc للترجمة هنا أيضاً لو أردت
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Region",
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Discover sites by city to tailor your Egyptian journey.",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }
}