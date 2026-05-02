import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/models/login_request_body.dart';
import '../data/repos/login_repo.dart';
import 'login_state.dart';
import '../../../../core/networking/secure_storage_helper.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '116814442413-pch0bv0djq1efnvov9bpp10bf1jmvib3.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  LoginCubit(this._loginRepo) : super(LoginInitial());

  Future<void> loginWithGoogle() async {
    emit(LoginLoading());
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(LoginInitial());
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      debugPrint("✅ تم الحصول على الـ idToken: $idToken");

      if (idToken != null) {
        // ✅ بنكلم الـ Repo مباشرة
        final response = await _loginRepo.loginWithGoogle(
          LoginRequestBody(idToken: idToken),
        );

        if (response.token != null) {
          await SecureStorageHelper.saveToken(response.token!);
          emit(LoginSuccess(response));
          debugPrint("✅ نجاح تسجيل الدخول بجوجل");
        } else {
          emit(LoginError("السيرفر لم يرسل توكن"));
        }
      } else {
        emit(LoginError("فشل الحصول على token من جوجل"));
      }
    } catch (error) {
      debugPrint("❌ Error: $error");
      emit(LoginError("حدث خطأ أثناء تسجيل الدخول: $error"));
    }
  }

  void emitLoginStates(LoginRequestBody loginRequestBody) async {
    emit(LoginLoading());
    try {
      final response = await _loginRepo.login(loginRequestBody);
      if (response.token != null) {
        await SecureStorageHelper.saveToken(response.token!);
        emit(LoginSuccess(response));
      } else {
        emit(LoginError("Token is missing"));
      }
    } catch (error) {
      emit(LoginError(error.toString()));
    }
  }
}





// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../data/models/login_request_body.dart';
// import '../data/repos/login_repo.dart';
// import 'login_state.dart';
// import '../../../../core/networking/secure_storage_helper.dart';
// import 'package:flutter/material.dart';
//
// class LoginCubit extends Cubit<LoginState> {
//   final LoginRepo _loginRepo;
//
//   // استخدام الـ Instance الموحد للمكتبة
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
//
//   LoginCubit(this._loginRepo) : super(LoginInitial()) {
//     // عمل Initialize للمكتبة أول ما الـ Cubit يتكريت
//     // جوه الـ Constructor بتاع الـ LoginCubit
//     _googleSignIn.initialize(
//       // ده الـ Client ID بتاع الـ iOS اللي الباك اند بعته
//       clientId: '1002849388134-eb6m8ct1fok6mu7t1hh500gg579ekbqg.apps.googleusercontent.com',
//       // ده الـ Client ID بتاع الـ Android (Web Client) اللي الباك اند بعته
//       serverClientId: '1002849388134-hntpmickcc9etk6bn3vbq1k51l4m393p.apps.googleusercontent.com',
//     );
//   }
//
//   // ميثود اللوجين بجوجل بالتحديث الجديد
//   Future<void> loginWithGoogle() async {
//     emit(LoginLoading());
//     try {
//       // 1. التأكد من أن المنصة تدعم authenticate (الأندرويد والـ iOS بيدعموها)
//       if (_googleSignIn.supportsAuthenticate()) {
//
//         // 2. طلب الـ Authentication (دي اللي بتفتح النافذة في الإصدار الجديد)
//         final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
//
//         if (googleUser == null) {
//           emit(LoginInitial());
//           return;
//         }
//
//         // 3. الحصول على الـ idToken (اللي الباك اند مستنيه)
//         final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//         final String? idToken = googleAuth.idToken;
//
//         if (idToken != null) {
//           // 4. إرسال التوكن للباك اند
//           final response = await _loginRepo.login(
//             LoginRequestBody(idToken: idToken),
//           );
//
//           if (response.token != null) {
//             await SecureStorageHelper.saveToken(response.token!);
//             emit(LoginSuccess(response));
//           } else {
//             emit(LoginError("Backend authentication failed"));
//           }
//         } else {
//           emit(LoginError("Could not get ID Token from Google"));
//         }
//       } else {
//         emit(LoginError("Platform not supported for Google Auth"));
//       }
//     } catch (error) {
//       debugPrint("❌ Google Auth Error: $error");
//       emit(LoginError("Google Sign-In failed: $error"));
//     }
//   }
//   // ميثود اللوجين العادي (بدون تعديل)
//   void emitLoginStates(LoginRequestBody loginRequestBody) async {
//     emit(LoginLoading());
//     try {
//       final response = await _loginRepo.login(loginRequestBody);
//       if (response.token != null) {
//         await SecureStorageHelper.saveToken(response.token!);
//         emit(LoginSuccess(response));
//       } else {
//         emit(LoginError("Token is missing"));
//       }
//     } catch (error) {
//       emit(LoginError(error.toString()));
//     }
//   }
// }