import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/register_request_body.dart';
import '../register_repo.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepo _registerRepo;
  RegisterCubit(this._registerRepo) : super(RegisterInitial());

  void emitRegisterStates(RegisterRequestBody registerRequestBody) async {
    emit(RegisterLoading());
    try {
      await _registerRepo.register(registerRequestBody);
      emit(RegisterSuccess());
    } catch (error) {
      emit(RegisterError(error.toString()));
    }
  }
}