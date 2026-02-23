import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const base = "http://devjob.runasp.net/api/Auth";
  static const baseCv = "http://devjob.runasp.net/api/CV";

  // ================================
  // REGISTER DEVELOPER
  // ================================
  Future<Map<String, dynamic>> registerDeveloper(String fullName, String email,
      String password) async {
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

  // ================================
  // REGISTER COMPANY
  // ================================
  Future<Map<String, dynamic>> registerCompany(String name, String serial,
      String phone, String email, String password) async {
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

  // ================================
  // LOGIN
  // ================================
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

  // GET PUBLIC JOBS (DEVELOPER)
  // ==============================
  Future<List> getJobs(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/jobs"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);
      return decoded["jobsDtos"] ?? [];
    }

    throw Exception("Failed to load jobs");
  }

  // ================= ADD JOB (COMPANY) =================
  Future<Map<String, dynamic>> addJob(
      String token,
      String title,
      String description,
      String location,
      int minExp,
      int maxExp,
      String jobLevel,
      String employmentType,
      String jobType,
      List<String> skills, // 👈 جديد
      ) async {

    final url = "http://devjob.runasp.net/api/jobs/add-job";

    final body = {
      "title": title,
      "description": description,
      "location": location,
      "minimumExperience": minExp,
      "maximumExperience": maxExp,
      "JobLevel": jobLevel,          // 👈 نفس الكابيتال زي الباك
      "EmploymentType": employmentType,
      "JobType": jobType,
      "skills": skills,              // 👈 مهم جداً
    };

    print("========== ADD JOB DEBUG ==========");
    print("BODY => ${jsonEncode(body)}");

    final r = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("STATUS => ${r.statusCode}");
    print("RESPONSE => ${r.body}");

    return _handle(r, "Add Job Failed");
  }



  // ================= APPLY JOB =================
  Future<Map<String, dynamic>> applyJob(
      String token,
      int jobId,
      int cvId,
      ) async {

    final url =
        "http://devjob.runasp.net/api/jobs/apply?jobId=$jobId&cvId=$cvId";

    final r = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("APPLY STATUS => ${r.statusCode}");
    print("APPLY BODY => ${r.body}");

    final decoded = jsonDecode(r.body);

    if (r.statusCode == 200 && decoded["success"] == true) {
      return decoded;
    }

    throw Exception(decoded["message"] ?? "Apply Job Failed");
  }


  // ================= DELETE JOB =================
  Future<void> deleteJob(String token, int jobId) async {
    final r = await http.delete(
      Uri.parse("http://devjob.runasp.net/api/jobs?jobid=$jobId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode != 200 && r.statusCode != 204) {
      throw Exception("Delete Job Failed");
    }
  }


  // ================================
// MY APPLICATIONS (DEVELOPER)
// ================================
  Future<List> getMyApplications(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/applications/my"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["applications"] != null) {
        return decoded["applications"];
      }
    }

    throw Exception("Failed to load my applications");
  }

  Future<Map<String, dynamic>> getApplicantHistoryCount(String token) async {

    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/user/applicant-history-count"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["applicantHistoryCount"] != null) {
        return decoded["applicantHistoryCount"];
      }
    }

    throw Exception("Failed to load applicant history count");
  }
  Future<List> getApplicantHistory(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/user/applicant-history"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded is List) {
        return decoded;
      }
    }

    throw Exception("Failed to load applicant history");
  }

  Future<Map<String, dynamic>> getUserCount(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/user/user-count"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    }

    throw Exception("Failed to load user count");
  }

  // ================================
// GET ALL APPLICANTS (NEW API)
// ================================
  Future<List> getAllApplicants(String token, int jobId) async {
    final r = await http.get(
      Uri.parse(
        "http://devjob.runasp.net/api/jobs/get-all-applicants?jobId=$jobId",
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["getApplicantDtos"] != null) {
        return decoded["getApplicantDtos"];
      }

      return [];
    }

    throw Exception("Failed to load applicants: ${r.body}");
  }

  Future<Map<String, dynamic>> getCompanyProfile(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/company/get-company-data"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return _handle(r, "Get Company Data Failed");
  }

  Future<Map<String, dynamic>> getCompanyCount(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/jobs/company-count"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["companyCount"] != null) {
        return decoded["companyCount"];
      }
    }

    throw Exception("Failed to load company count");
  }
  Future<void> addSavedJob(
      String token,
      int userId,
      int jobId,
      ) async {

    final url = "http://devjob.runasp.net/api/jobs/add-saved-job";

    print("===== ADD SAVED JOB DEBUG =====");
    print("URL => $url");
    print("TOKEN => $token");
    print("USER ID => $userId");
    print("JOB ID => $jobId");
    print("BODY => ${jsonEncode({
      "userId": userId,
      "jobId": jobId,
    })}");

    final r = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": userId,
        "jobId": jobId,
      }),
    );

    print("STATUS CODE => ${r.statusCode}");
    print("RESPONSE BODY => ${r.body}");
    print("================================");

    if (r.statusCode != 200) {
      throw Exception("Save Job Failed: ${r.body}");
    }
  }
  Future<List> getSavedJobs(String token, int userId) async {

    final url =
        "http://devjob.runasp.net/api/jobs/display-saved-jobs?useId=$userId";

    print("========= CALLING SAVED JOBS API =========");
    print("URL => $url");
    print("TOKEN => $token");

    final r = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS CODE => ${r.statusCode}");
    print("BODY => ${r.body}");
    print("==========================================");

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["displaySavedJobDtos"] != null) {
        return decoded["displaySavedJobDtos"];
      }

      return [];
    }

    throw Exception("Load Saved Jobs Failed: ${r.body}");
  }

// ================================
// UPDATE APPLICANT STATUS (COMPANY)
// ================================
  Future<Map<String, dynamic>> updateApplicantStatus(
      String token,
      int jobId,
      int userId,
      String status,
      ) async {

    final r = await http.put(
      Uri.parse("http://devjob.runasp.net/api/jobs/update-state"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "JobId": jobId,
        "UserId": userId,
        "status": status, // لازم نفس enum بالظبط
      }),
    );

    return _handle(r, "Update Status Failed");
  }

  // ================================
// GET APPLICANT COUNT (COMPANY)
// ================================
  Future<Map<String, dynamic>> getApplicantCount(
      String token,
      int jobId,
      ) async {

    final r = await http.get(
      Uri.parse(
          "http://devjob.runasp.net/api/jobs/applicant-count?jobId=$jobId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["applicantsCount"] != null) {
        return decoded["applicantsCount"];
      }
    }

    throw Exception("Failed to load applicant count");
  }

  // ================================
// SAVE USER PREFERENCES (DEVELOPER)
// ================================
  Future<Map<String, dynamic>> saveUserPreferences(
      String token,
      List<String> jobTypes,
      String jobLevel,
      List<String> skills,
      int minimumSalary,
      ) async {

    final r = await http.post(
      Uri.parse("http://devjob.runasp.net/api/jobs/user-prefare"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "jobTypes": jobTypes,
        "JobLevel": jobLevel,
        "skills": skills,
        "MinimumSalar": minimumSalary,
      }),
    );

    return _handle(r, "Save Preferences Failed");
  }

  // ================================
// GET ALL SKILLS (NO AUTH)
// ================================
  Future<List<String>> getAllSkills() async {

    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/jobs/all-skills"),
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded is List) {
        return decoded.cast<String>();
      }
    }

    throw Exception("Failed to load skills");
  }


// ================= START CONVERSATION (COMPANY) =================
  Future<Map<String, dynamic>> startConversation(
      String token,
      int userId,
      int jobId,
      int companyId,
      ) async {

    final r = await http.post(
      Uri.parse("http://devjob.runasp.net/api/chat/start-conversation"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": userId,
        "jobId": jobId,
        "companyId": companyId,
      }),
    );

    return _handle(r, "Start Conversation Failed");
  }

  // ================= GET ALL CHATS (DEVELOPER) =================
  Future<List> getAllChats(String token) async {

    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/chat/all-chats"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["displayAllConversations"] != null) {
        return decoded["displayAllConversations"];
      }

      return [];
    }

    throw Exception("Load Chats Failed: ${r.body}");
  }

// ================================
// JOB APPLICANTS (COMPANY)
// ================================
  Future<List> getJobApplicants(String token, int jobId) async {
    final r = await http.get(
      Uri.parse(
          "http://devjob.runasp.net/api/applications/job?jobId=$jobId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    }

    throw Exception("Failed to load job applicants");
  }

  // ================= COMPANY JOBS =================
  Future<List> getAllCompanyJobs(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/jobs/get-all-jobs"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      // 🔴 مهم جدًا: لو API راجع object
      if (decoded is Map && decoded["jobs"] != null) {
        return decoded["jobs"];
      }

      // 🟢 لو راجع List مباشر
      if (decoded is List) {
        return decoded;
      }
    }

    throw Exception("Load Company Jobs Failed: ${r.body}");
  }

  Future<void> updateJob(
      String token,
      int jobId,
      String title,
      String description,
      String location,
      String jobType,
      String jobLevel,
      String employmentType,
      ) async {
    final r = await http.put(
      Uri.parse("http://devjob.runasp.net/api/jobs/update?jobId=$jobId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "Title": title,
        "Desctiption": description, // 👈 زي ما الباك كاتبه
        "Location": location,
        "JobType": jobType,
        "JobLevel": jobLevel,
        "EmploymentType": employmentType,
      }),
    );

    if (r.statusCode != 200) {
      throw Exception("Update Job Failed: ${r.body}");
    }
  }

  Future<List> getRecommendedJobs(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/jobs/Recommended-jobs"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    // 👇 هنا تحطهم
    print("RECOMMENDED STATUS => ${r.statusCode}");
    print("RECOMMENDED BODY => ${r.body}");

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded["success"] == true &&
          decoded["recommendedJobs"] != null) {
        return decoded["recommendedJobs"];
      }

      return [];
    }

    throw Exception("Failed to load recommended jobs: ${r.body}");
  }


// FORGOT PASSWORD
// ================================
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

// ================================
// RESET PASSWORD
// ================================
  Future<Map<String, dynamic>> resetPassword(String token,
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

  // ================================
  // UPLOAD CV (هنا المشكلة كانت)
  // ================================
  Future<Map<String, dynamic>> uploadCv(String filePath, String token) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("http://devjob.runasp.net/api/CV/Upload"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "file", // ✅ اسم الفيلد الصح
        filePath,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _handle(response, "Upload CV Failed");
  }

  // ================================
  // GET USER DATA
  // ================================
  Future<Map<String, dynamic>> getUserData(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/User/get-user-data"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      dynamic rawUserId = decoded["userId"];

      int? fixedUserId;

      // لو بيرجع ليست ناخد أول عنصر
      if (rawUserId is List && rawUserId.isNotEmpty) {
        fixedUserId = rawUserId.first;
      }
      // لو رجع رقم عادي
      else if (rawUserId is int) {
        fixedUserId = rawUserId;
      }

      return {
        "userId": fixedUserId,
        "name": decoded["name"],
      };
    }

    throw Exception("Get User Data Failed: ${r.body}");
  }

  // ================================
  // UPDATE DEVELOPER PROFILE
  // ================================
  Future<Map<String, dynamic>> updateUserProfile(String token,
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

  // ================================
  // UPDATE COMPANY PROFILE
  // ================================
  Future<Map<String, dynamic>> updateCompanyProfile(String token,
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

  // ================================
  // CHANGE EMAIL
  // ================================
  Future<Map<String, dynamic>> changeEmail(String token,
      String newEmail) async {
    final uri =
        "http://devjob.runasp.net/api/user/change-email?newEmail=$newEmail&token=$token";

    final r = await http.post(Uri.parse(uri), headers: {
      "Authorization": "Bearer $token",
    });

    return _handle(r, "Change Email Failed");
  }


  // ================================
// GET ALL CVS
// ================================
  Future<List> getAllCvs(String token) async {
    final r = await http.get(
      Uri.parse("http://devjob.runasp.net/api/cv/all-cv"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("CV STATUS => ${r.statusCode}");
    print("CV BODY => ${r.body}");

    if (r.statusCode == 204) {
      // مفيش CV
      return [];
    }

    if (r.statusCode == 200) {
      final decoded = jsonDecode(r.body);

      if (decoded is List) {
        return decoded;
      }

      if (decoded is Map && decoded["cvs"] != null) {
        return decoded["cvs"];
      }

      return [];
    }

    throw Exception("Get CVs Failed: ${r.body}");
  }



// ================================
// DELETE CV
// ================================
  Future<void> deleteCv(String token, int cvId) async {
    final r = await http.delete(
      Uri.parse("http://devjob.runasp.net/api/cv?cvid=$cvId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (r.statusCode != 200 && r.statusCode != 204) {
      throw Exception("Delete CV Failed: ${r.body}");
    }
  }


  // ================================
  // UNIVERSAL HANDLER (معدّل)
  // ================================
  Map<String, dynamic> _handle(http.Response r, String msg) {
    if (r.statusCode == 200 || r.statusCode == 201) {
      final text = r.body.trim();

      // لو الـ API رجّع URL مش JSON → نرجعه زي ما هو
      if (!text.startsWith("{") && !text.startsWith("[")) {
        return {
          "success": true,
          "url": text,
        };
      }

      return jsonDecode(text);
    }

    throw Exception("$msg: ${r.body}");
  }

  Future<void> sendDeviceId(String token, String deviceId) async {

    final url = "http://devjob.runasp.net/api/notification/device-id/$deviceId";

    print("========== SEND DEVICE ID ==========");
    print("URL => $url");
    print("TOKEN => $token");

    final r = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("STATUS CODE => ${r.statusCode}");
    print("RESPONSE BODY => ${r.body}");
    print("===================================");

    if (r.statusCode != 200) {
      throw Exception("Send Device ID Failed: ${r.body}");
    }
  }


}