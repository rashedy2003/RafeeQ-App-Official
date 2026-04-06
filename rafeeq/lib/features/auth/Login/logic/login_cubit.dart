import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/login_request_body.dart';
import '../data/repos/login_repo.dart';
import 'login_state.dart';
import '../../../../core/networking/secure_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/login_request_body.dart';
import '../data/repos/login_repo.dart';
import 'login_state.dart';
import '../../../../core/networking/secure_storage_helper.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;
  LoginCubit(this._loginRepo) : super(LoginInitial());

  void emitLoginStates(LoginRequestBody loginRequestBody) async {
    emit(LoginLoading());
    try {
      final response = await _loginRepo.login(loginRequestBody);

      if (response.token != null) {
        // ✅ حفظ التوكن الوحيد اللي راجع
        await SecureStorageHelper.saveToken(response.token!);
        emit(LoginSuccess(response));
      } else {
        emit(LoginError("Token is missing from server response"));
      }
    } catch (error) {
      debugPrint("❌ Login Error: ${error.toString()}");
      emit(LoginError(error.toString()));
    }
  }
}