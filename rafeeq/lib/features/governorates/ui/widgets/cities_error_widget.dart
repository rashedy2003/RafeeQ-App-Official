import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../logic/cities_cubit.dart';

class CitiesErrorWidget extends StatelessWidget {
  final String error;
  const CitiesErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    String getDisplayMessage() {
      // فحص إذا كان الخطأ هو أحد المفاتيح المعروفة لدينا
      final Map<String, String> localErrors = {
        "error_connection": loc.error_connection,
        "error_server": loc.error_server,
        "error_unexpected": loc.error_unexpected,
        "error_gps_disabled": loc.error_gps_disabled,
      };
      return localErrors[error] ?? error; // لو مش Key، يبقى دي رسالة مترجمة من الباك إند
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 15),
            Text(getDisplayMessage(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => context.read<CitiesCubit>().getCities(),
              child: Text(loc.retry, style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}