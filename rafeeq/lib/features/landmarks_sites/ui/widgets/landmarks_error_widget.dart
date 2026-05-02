import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class LandmarksErrorWidget extends StatelessWidget {
  final String errorKey;
  final VoidCallback onRetry;

  const LandmarksErrorWidget({
    super.key,
    required this.errorKey,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            _getTranslatedErrorMessage(errorKey, loc),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onRetry,
            child: Text(loc.retry),
          )
        ],
      ),
    );
  }

  String _getTranslatedErrorMessage(String errorKey, AppLocalizations loc) {
    final Map<String, String> errors = {
      'error_connection': loc.error_connection,
      'error_server': loc.error_server,
      'error_unexpected': loc.error_unexpected,
      'error_gps_disabled': loc.error_gps_disabled,
    };
    return errors[errorKey] ?? errorKey;
  }
}