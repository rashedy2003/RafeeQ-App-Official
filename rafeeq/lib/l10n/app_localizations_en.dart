// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get scan => 'Scan';

  @override
  String get favs => 'Favs';

  @override
  String get trips => 'Trips';

  @override
  String get governorates => 'Governorates';

  @override
  String get my_favorites_places => 'My Favorites places';

  @override
  String get no_favorites => 'No Favorites Yet';

  @override
  String get start_adding => 'Start adding your favorite places!';

  @override
  String get retry => 'Retry';

  @override
  String get error_favorites => 'An error occurred while loading favorites';

  @override
  String get must_visit => 'Must Visit';

  @override
  String get special_offers => 'Special Offers';

  @override
  String get hidden_gems => 'Hidden Gems';

  @override
  String get near_you => 'Near You';

  @override
  String get no_near_places => 'No places found near your current location.';
}
