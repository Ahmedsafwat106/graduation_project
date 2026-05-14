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
        final msg = result["message"]?.toString().toLowerCase() ?? "";
        if (msg.contains("confirm") || msg.contains("verify") || msg.contains("email")) {
          emit(AuthSuccess("VERIFY_EMAIL"));
        } else {
          throw Exception("Login failed: Token is EMPTY");
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", token);
      await prefs.setString("role", role);

      final refreshTkn =
          result["refreshToken"] ??
              result["RefreshToken"] ??
              "";

      if (refreshTkn.isNotEmpty) {
        await prefs.setString("refreshToken", refreshTkn);
        print("✅ REFRESH TOKEN SAVED");
      }

      print("🔐 TOKEN SAVED SUCCESSFULLY");

      Map<String, dynamic>? userData;

      try {
        userData = await api.getUserData(token);
        print("USER DATA RESPONSE => $userData");
      } catch (e) {

        print("⚠️ GET USER DATA ERROR => $e");
      }

      int? fixedUserId;

      if (userData?["id"] != null) {
        fixedUserId = userData!["id"];
      } else if (userData?["userId"] != null) {
        final raw = userData!["userId"];
        if (raw is List && raw.isNotEmpty) {
          fixedUserId = raw[0] is int ? raw[0] : int.tryParse(raw[0].toString());
        } else if (raw is int) {
          fixedUserId = raw;
        }
      }

      if (fixedUserId == null && token.isNotEmpty) {
        try {
          final parts = token.split(".");
          if (parts.length == 3) {
            String payload = parts[1];
            while (payload.length % 4 != 0) payload += "=";
            final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
            final sub = decoded["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];
            if (sub != null) {
              fixedUserId = int.tryParse(sub.toString());
            }
          }
        } catch (e) {
          print("❌ Token userId parse error: $e");
        }
      }
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

      await sendOneSignalIdAfterLogin();

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
      final result = await api.registerDeveloper(name, email, password);

      if (result["token"] != null || result["Token"] != null) {
        final token = result["token"] ?? result["Token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("role", "developer");

        try {
          final userData = await api.getUserData(token);
          if (userData["name"] != null) {
            await prefs.setString("userName", userData["name"]);
          }
          if (userData["appUser"] != null) {
            await prefs.setString("appUser", userData["appUser"]);
          }
          if (userData["id"] != null) {
            await prefs.setInt("userId", userData["id"]);
          }
        } catch (_) {}

        await sendOneSignalIdAfterLogin();
        emit(AuthSuccess("LOGIN_SUCCESS"));
      } else {
        emit(AuthSuccess("REGISTERED_DEVELOPER"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> registerCompany(
      String name, String serial, String phone,
      String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await api.registerCompany(
          name, serial, phone, email, password);

      if (result["token"] != null || result["Token"] != null) {
        final token = result["token"] ?? result["Token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("role", "company");

        await sendOneSignalIdAfterLogin();
        emit(AuthSuccess("LOGIN_SUCCESS"));
      } else {
        emit(AuthSuccess("REGISTERED_COMPANY"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final refresh = prefs.getString("refreshToken");

    if (token == null || token.isEmpty) {
      emit(AuthInitial());
      return;
    }

    if (refresh != null && refresh.isNotEmpty) {
      try {
        final result = await api.refreshToken(token, refresh);
        if (result["success"] == true && result["token"] != null) {
          final newToken = result["token"];
          final newRefresh = result["refreshToken"] ?? refresh;

          await prefs.setString("token", newToken);
          await prefs.setString("refreshToken", newRefresh);

          print("✅ Token refreshed successfully");
          emit(AuthAuthenticated(newToken));
          return;
        }
      } catch (e) {
        print("⚠️ Refresh failed: $e");
      }
    }
    emit(AuthAuthenticated(token));
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

    final deviceId = await OneSignal.User.getOnesignalId();


    print("ONESIGNAL PLAYER ID => $deviceId");

    return deviceId;
  }

  Future<void> sendOneSignalIdAfterLogin() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) return;

    String? oneSignalId;

    for (int i = 0; i < 5; i++) {

      oneSignalId = await OneSignal.User.getOnesignalId();

      if (oneSignalId != null && oneSignalId.isNotEmpty) {
        break;
      }

      print("⌛ Waiting for OneSignal ID...");
      await Future.delayed(const Duration(seconds: 2));
    }

    if (oneSignalId == null || oneSignalId.isEmpty) {
      print("❌ FAILED TO GET ONESIGNAL ID");
      return;
    }

    print("🔥 ONESIGNAL ID => $oneSignalId");

    try {

      await api.sendOneSignalId(token, oneSignalId);

      print("✅ ONESIGNAL ID SENT SUCCESSFULLY");

    } catch (e) {

      print("❌ SEND ONESIGNAL ID ERROR => $e");

    }
  }


}