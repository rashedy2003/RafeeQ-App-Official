import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  // بنبدأ بـ index = 0 اللي هي صفحة الـ Home
  NavigationCubit() : super(NavigationInitial(0));

  void changePage(int index) {
    emit(NavigationInitial(index));
  }
}