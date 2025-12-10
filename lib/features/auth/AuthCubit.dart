import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'AuthState.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiService api;
  AuthCubit(this.api) : super(AuthInitial());


  Future<void> login(String email, String password, String role) async {
    emit(AuthLoading());
    try {
      final result = await api.login(email, password);

      final token = result["token"] ??
          result["Token"] ??
          result["accessToken"] ??
          "";

      if (token.isEmpty) throw Exception("Login failed: No token returned");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("role", role);
      await prefs.setString("email", email);

      emit(AuthSuccess("LOGIN_SUCCESS"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  Future<void> registerDeveloper(
      String name, String email, String password) async {
    emit(AuthLoading());
    try {
      await api.registerDeveloper(name, email, password);
      emit(AuthSuccess("REGISTERED_DEVELOPER"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  Future<void> registerCompany(
      String name,
      String serial,
      String phone,
      String email,
      String password) async {
    emit(AuthLoading());
    try {
      await api.registerCompany(name, serial, phone, email, password);
      emit(AuthSuccess("REGISTERED_COMPANY"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token));
    } else {
      emit(AuthInitial());
    }
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthInitial());
  }


  Future<void> uploadCv(String filePath) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.uploadCv(filePath, token);
      emit(AuthSuccess("CV_UPLOADED"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> loadUserProfile() async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final data = await api.getUserData(token);

      emit(ProfileLoaded(data));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  Future<void> updateUserProfile(
      String first, String last, String phone, String city) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.updateUserProfile(token, first, last, phone, city);

      emit(AuthSuccess("PROFILE_UPDATED"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  Future<void> updateCompany(
      String company, String phone, String city, String field) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.updateCompanyProfile(token, company, phone, city, field);

      emit(AuthSuccess("COMPANY_UPDATED"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  Future<void> changeEmail(String newEmail) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.changeEmail(token, newEmail);

      emit(AuthSuccess("EMAIL_CHANGED"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
