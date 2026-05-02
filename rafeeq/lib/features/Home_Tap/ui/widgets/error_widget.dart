import 'package:flutter/material.dart';
import '../../../../core/theming/theme.dart';
import '../../../../l10n/app_localizations.dart';

class HomeErrorWidget extends StatelessWidget {
  final String messageKey;
  final AppLocalizations loc;
  final VoidCallback onRetry;

  const HomeErrorWidget({
    super.key,
    required this.messageKey,
    required this.loc,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Translate the key coming from Cubit
    String errorMessage;
    switch (messageKey) {
      case "error_connection":
        errorMessage = loc.error_connection;
        break;
      case "error_server":
        errorMessage = loc.error_server;
        break;
      case "error_gps_disabled":
        errorMessage = loc.error_gps_disabled;
        break;
      default:
        errorMessage = loc.error_unexpected;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 15),
            Text(
              errorMessage,
              style: TextStyles.font18WhiteBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.rafeeqYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onRetry,
                child: Text(loc.retry, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}