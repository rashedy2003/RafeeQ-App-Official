import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> getHomeData() async {
    emit(HomeLoading());
    try {
      // محاكاة لطلب الـ API (هنغير ده لما نربط فعلياً)
      await Future.delayed(const Duration(seconds: 2));

      // بيانات تجريبية تحتوي على URLs (زي ما هييجي من السيرفر)
      final mustVisit = [
        {
          'title': 'Giza Pyramids',
          'image': 'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368',
          'description': 'The only surviving wonder of the ancient world.',
          'price': '\$45.00'
        },
        {
          'title': 'Luxor Temple',
          'image': 'https://images.unsplash.com/photo-1572252009286-268acec5ca0a',
          'description': 'A large Ancient Egyptian temple complex.',
          'price': '\$30.00'
        },
      ];

      final hiddenGems = [
        {
          'title': 'Abdeen Palace',
          'image': 'https://images.unsplash.com/photo-1553913861-c0fddf2619ee',
          'description': 'A masterpiece of architectural history.'
        },
        {
          'title': 'Siwa Oasis',
          'image': 'https://images.unsplash.com/photo-1590059392604-0c68c62c9383',
          'description': 'A natural paradise in the desert.'
        },
      ];

      emit(HomeSuccess(mustVisit, hiddenGems));
    } catch (e) {
      emit(HomeError("Failed to load home data: $e"));
    }
  }
}