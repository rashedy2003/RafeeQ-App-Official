import 'package:flutter/material.dart';
import '../../../../core/theming/theme.dart';
import '../../../../l10n/app_localizations.dart';

class HomeLocationErrorWidget extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onEnablePressed;

  const HomeLocationErrorWidget({
    super.key,
    required this.loc,
    required this.onEnablePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.surfaceDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_off_rounded, color: ColorsManager.rafeeqYellow, size: 40),
          const SizedBox(height: 10),
          Text(
            "Please enable location for better experience",
            style: TextStyles.font18WhiteBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: onEnablePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.rafeeqYellow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Enable", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}