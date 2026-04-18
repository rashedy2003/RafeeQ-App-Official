// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get home => 'الرئيسية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get chooseLanguage => 'اختيار اللغة';

  @override
  String get scan => 'مسح';

  @override
  String get favs => 'المفضلة';

  @override
  String get trips => 'الرحلات';

  @override
  String get governorates => 'المحافظات';

  @override
  String get my_favorites_places => 'الأماكن المفضلة';

  @override
  String get no_favorites => 'لا توجد مفضلات بعد';

  @override
  String get start_adding => 'ابدأ بإضافة أماكنك المفضلة!';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get error_favorites => 'حدث خطأ في تحميل المفضلات';
}
