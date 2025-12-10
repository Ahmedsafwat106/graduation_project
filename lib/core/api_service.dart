import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const base = "http://devjob.runasp.net/api/Auth";
  static const baseCv = "http://devjob.runasp.net/api/CV";


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


  Future<Map<String, dynamic>> registerCompany(
      String name, String serial, String phone, String email, String password) async {

    final body = {
      "CompanyName": name.trim(),
      "SerailNumber": serial.trim(),
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


  Future<Map<String, dynamic>> uploadCv(String filePath, String token) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseCv/Upload"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath("Cv", filePath),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _handle(response, "Upload CV Failed");
  }


  Future<Map<String, dynamic>> getUserData(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/User/get-user-data"),
      headers: {"Authorization": "Bearer $token"},
    );

    return _handle(r, "Get User Data Failed");
  }

  Future<Map<String, dynamic>> updateUserProfile(
      String token,
      String first,
      String last,
      String phone,
      String city) async {

    final body = {
      "firstName": first,
      "lastName": last,
      "phone": phone,
      "city": city,
    };

    final r = await http.put(
      Uri.parse("http://devjob.runasp.net/api/user/update-user-profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return _handle(r, "Update User Profile Failed");
  }

  Future<Map<String, dynamic>> updateCompanyProfile(
      String token,
      String companyName,
      String phone,
      String city,
      String field) async {

    final body = {
      "companyName": companyName,
      "phone": phone,
      "city": city,
      "field": field,
    };

    final r = await http.put(
      Uri.parse("http://devjob.runasp.net/api/company/Update-profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return _handle(r, "Update Company Profile Failed");
  }


  Future<Map<String, dynamic>> changeEmail(String token, String newEmail) async {
    final uri =
        "http://devjob.runasp.net/api/user/change-email?newEmail=$newEmail&token=$token";

    final r = await http.post(Uri.parse(uri), headers: {
      "Authorization": "Bearer $token",
    });

    return _handle(r, "Change Email Failed");
  }


  Map<String, dynamic> _handle(http.Response r, String msg) {
    if (r.statusCode == 200 || r.statusCode == 201) {
      if (r.body.isEmpty) return {"success": true};

      try {
        return jsonDecode(r.body);
      } catch (_) {
        return {"success": true};
      }
    }
    throw Exception("$msg: ${r.body}");
  }
}
