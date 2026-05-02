import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @favs.
  ///
  /// In en, this message translates to:
  /// **'Favs'**
  String get favs;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @governorates.
  ///
  /// In en, this message translates to:
  /// **'Governorates'**
  String get governorates;

  /// No description provided for @my_favorites_places.
  ///
  /// In en, this message translates to:
  /// **'My Favorites places'**
  String get my_favorites_places;

  /// No description provided for @no_favorites.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get no_favorites;

  /// No description provided for @start_adding.
  ///
  /// In en, this message translates to:
  /// **'Start adding your favorite places!'**
  String get start_adding;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error_favorites.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading favorites'**
  String get error_favorites;

  /// No description provided for @must_visit.
  ///
  /// In en, this message translates to:
  /// **'Must Visit'**
  String get must_visit;

  /// No description provided for @special_offers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get special_offers;

  /// No description provided for @hidden_gems.
  ///
  /// In en, this message translates to:
  /// **'Hidden Gems'**
  String get hidden_gems;

  /// No description provided for @near_you.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get near_you;

  /// No description provided for @no_near_places.
  ///
  /// In en, this message translates to:
  /// **'No places found near your current location.'**
  String get no_near_places;

  /// No description provided for @error_connection.
  ///
  /// In en, this message translates to:
  /// **'Internet connection issue'**
  String get error_connection;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Sorry, a server error occurred'**
  String get error_server;

  /// No description provided for @error_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get error_unexpected;

  /// No description provided for @error_gps_disabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable GPS to see nearby places'**
  String get error_gps_disabled;

  /// No description provided for @journey_heart_egypt.
  ///
  /// In en, this message translates to:
  /// **'Journey through the heart of Egypt'**
  String get journey_heart_egypt;

  /// No description provided for @search_governorate.
  ///
  /// In en, this message translates to:
  /// **'Search for a governorate...'**
  String get search_governorate;

  /// No description provided for @no_matches_found.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get no_matches_found;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search in'**
  String get search;

  /// No description provided for @search_egypt_landmarks.
  ///
  /// In en, this message translates to:
  /// **'Discover places Egypt ...'**
  String get search_egypt_landmarks;

  /// No description provided for @search_hint_home.
  ///
  /// In en, this message translates to:
  /// **'Search for monuments, museums, or cities...'**
  String get search_hint_home;

  /// No description provided for @no_landmarks_found.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any sites matching your search.'**
  String get no_landmarks_found;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
