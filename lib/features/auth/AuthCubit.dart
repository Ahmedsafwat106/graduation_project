import 'dart:convert';

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

      print("LOGIN RESPONSE => $result");

      String token = "";

      if (result["token"] != null) {
        token = result["token"];
      } else if (result["Token"] != null) {
        token = result["Token"];
      } else if (result["accessToken"] != null) {
        token = result["accessToken"];
      } else if (result["jwt"] != null) {
        token = result["jwt"];
      } else if (result["data"] != null &&
          result["data"]["token"] != null) {
        token = result["data"]["token"];
      }

      print("ACTUAL TOKEN => $token");

      if (token.isEmpty) {
        throw Exception("Login failed: Token is EMPTY from API");
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", token);
      await prefs.setString("role", role);

      print("🔐 TOKEN SAVED SUCCESSFULLY");

      Map<String, dynamic>? userData;

      try {
        userData = await api.getUserData(token);
        print("USER DATA RESPONSE => $userData");
      } catch (e) {

        print("⚠️ GET USER DATA ERROR => $e");
      }

      final int? fixedUserId = userData?["id"];
      final String? appUser = userData?["appUser"];
      final String? name = userData?["name"];


      if (name != null && name.isNotEmpty) {
        await prefs.setString("userName", name);
        print("✅ USER NAME SAVED => $name");
      }

      if (appUser != null && appUser.isNotEmpty) {
        await prefs.setString("appUser", appUser);
        print("✅ APP USER SAVED => $appUser");
      }

      if (fixedUserId != null) {
        await prefs.setInt("userId", fixedUserId);
        print("✅ USER ID SAVED => $fixedUserId");
      } else {
        print("⚠️ USER ID IS NULL (لكن اللوجين هيكمل عادي)");
      }

      final List<String> savedAccounts =
          prefs.getStringList("saved_accounts") ?? [];

      final newAccount = jsonEncode({
        "email": email,
        "token": token,
        "role": role,
        "name": name ?? email,
        "userId": fixedUserId,
        "appUser": appUser ?? "",
      });

      savedAccounts.removeWhere((a) {
        try {
          return jsonDecode(a)["email"] == email;
        } catch (_) {
          return false;
        }
      });

      savedAccounts.add(newAccount);
      await prefs.setStringList("saved_accounts", savedAccounts);

      // ================= SEND DEVICE ID =================
      await sendDeviceIdAfterLogin();

      emit(AuthSuccess("LOGIN_SUCCESS"));
    } catch (e) {
      print("❌ LOGIN ERROR => $e");
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
      await login(email, password, "company");
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> registerDeveloper(
      String name, String email, String password) async {
    emit(AuthLoading());
    try {
      await api.registerDeveloper(name, email, password);
      await login(email, password, "developer");
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

    final deviceId = OneSignal.User.pushSubscription.id;


    print("ONESIGNAL PLAYER ID => $deviceId");

    return deviceId;
  }



  // ================= SEND DEVICE ID =================
  Future<void> sendDeviceIdAfterLogin() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) return;

    String? deviceId;

    for (int i = 0; i < 5; i++) {

      deviceId = OneSignal.User.pushSubscription.id;

      if (deviceId != null && deviceId.isNotEmpty) {
        break;
      }

      print("⌛ Waiting for OneSignal Player ID...");
      await Future.delayed(const Duration(seconds: 2));
    }

    if (deviceId == null || deviceId.isEmpty) {
      print("❌ FAILED TO GET PLAYER ID");
      return;
    }

    print("🔥 PLAYER ID => $deviceId");

    try {

      await api.sendDeviceId(token, deviceId);

      print("✅ DEVICE ID SENT SUCCESSFULLY");

    } catch (e) {

      print("❌ SEND DEVICE ID ERROR => $e");

    }

  }



}