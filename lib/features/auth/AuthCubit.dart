import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
          result["jwt"] ??
          "";

      if (token.isEmpty) {
        throw Exception("Login failed: No token returned from API");
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", token);
      await prefs.setString("role", role);

      print("🔐 TOKEN SAVED");

      // ================= GET USER DATA =================
      final userData = await api.getUserData(token);

      final int? fixedUserId = userData["id"];
      final String? appUser = userData["appUser"];
      final String? name = userData["name"];

      // ================= STORAGE =================

      if (name != null && name.isNotEmpty) {
        await prefs.setString("userName", name);
      }

      if (appUser != null && appUser.isNotEmpty) {
        await prefs.setString("appUser", appUser);
        print("✅ APP USER SAVED => $appUser");
      }

      if (fixedUserId != null) {
        await prefs.setInt("userId", fixedUserId);
        print("✅ USER ID SAVED => $fixedUserId");
      } else {
        print("⚠️ USER ID IS NULL");
      }

      // ================= SEND DEVICE ID =================
      await sendDeviceIdAfterLogin();

      emit(AuthSuccess("LOGIN_SUCCESS"));

    } catch (e) {
      print("❌ LOGIN ERROR => $e");
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

  Future<String?> getDeviceId() async {
    // ده الـ Player ID الحقيقي بتاع الجهاز
    final deviceId = OneSignal.User.pushSubscription.id;

    // نطبعه في التيرمنال عشان تاخده للباك وتتأكد
    print("ONESIGNAL PLAYER ID => $deviceId");

    return deviceId;
  }



  // ================= SEND DEVICE ID =================
  Future<void> sendDeviceIdAfterLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) return;

    final deviceId = OneSignal.User.pushSubscription.id;

    if (deviceId != null && deviceId.isNotEmpty) {
      print("🔥 PLAYER ID => $deviceId");

      try {
        await api.sendDeviceId(token, deviceId);
        print("✅ DEVICE ID SENT SUCCESSFULLY");
      } catch (e) {
        print("❌ SEND DEVICE ID ERROR: $e");
      }
    } else {
      print("❌ DEVICE ID IS NULL");
    }
  }


}