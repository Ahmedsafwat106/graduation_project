import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const base = "http://devjob.runasp.net/api/Auth";

  // -----------------------
  // REGISTER DEVELOPER
  // -----------------------
  Future<Map<String, dynamic>> registerDeveloper(
      String fullName, String email, String password) async {
    final parts = fullName.trim().split(' ');
    final first = parts.isNotEmpty ? parts.first : '';
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final body = {
      "Email": email.trim(),
      "Password": password.trim(),
      "ConfirmPassword": password.trim(),
      "FirstName": first,
      "LAstName": last,
    };

    final r = await http.post(
      Uri.parse("$base/user-Register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return _handle(r, "Developer Register Failed");
  }

  // -----------------------
  // REGISTER COMPANY
  // -----------------------
  Future<Map<String, dynamic>> registerCompany(
      String name, String serial, String phone, String email, String password) async {
    final body = {
      "CompanyName": name.trim(),
      "SerailNumber": serial.trim(),  // نفس السبيلنج الغلط من السيرفر
      "Phone": phone.trim(),
      "Email": email.trim(),
      "Password": password.trim(),
      "ConfirmPassword": password.trim(),
    };

    final r = await http.post(
      Uri.parse("$base/Register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return _handle(r, "Company Register Failed");
  }

  // -----------------------
  // LOGIN
  // -----------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await http.post(
      Uri.parse("$base/Login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Email": email.trim(),
        "Password": password.trim(),
      }),
    );

    return _handle(r, "Login Failed");
  }

  // -----------------------
  // FORGOT PASSWORD
  // -----------------------
  Future<Map<String, dynamic>> forgot(String email) async {
    final r = await http.post(
      Uri.parse("$base/forget-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "ClientUri": "https://localhost:7054/api/Auth/resetPassword"
      }),
    );

    return _handle(r, "Forgot Password Failed");
  }

  // -----------------------
  // RESET PASSWORD
  // -----------------------
  Future<Map<String, dynamic>> resetPassword(
      String token,
      String email,
      String password,
      String confirmPassword) async {

    final r = await http.post(
      Uri.parse("$base/ResetPassword"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Token": token.trim(),
        "Email": email.trim(),
        "Password": password.trim(),
        "ConfirmPassword": confirmPassword.trim(),
      }),
    );

    return _handle(r, "Reset Password Failed");
  }

  // -----------------------
  // UNIVERSAL HANDLER
  // -----------------------
  Map<String, dynamic> _handle(http.Response r, String message) {
    if (r.statusCode == 200 || r.statusCode == 201) {
      if (r.body.isEmpty) return {"success": true};

      try {
        return jsonDecode(r.body);
      } catch (_) {
        return {"success": true};
      }
    } else {
      throw Exception("$message: ${r.body}");
    }
  }
}
