import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  void changeToArabic() => emit(const Locale('ar'));

  void changeToEnglish() => emit(const Locale('en'));
}