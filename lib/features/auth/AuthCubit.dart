import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'AuthState.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiService api;
  AuthCubit(this.api) : super(AuthInitial());

  // ============================
  // LOGIN
  // ============================
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

      emit(AuthSuccess("LOGIN_SUCCESS"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


// LOAD PUBLIC JOBS (DEVELOPER) ✅
// ============================
  Future<void> loadJobs() async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        throw Exception("User not logged in");
      }

      final jobs = await api.getJobs(token);
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

// ============================
// APPLY JOB (DEVELOPER) ✅
// ============================
  Future<void> applyJob(int jobId) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        throw Exception("User not logged in");
      }

      await api.applyJob(token, jobId);
      emit(AuthSuccess("JOB_APPLIED"));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


// ============================
// LOAD COMPANY JOBS (COMPANY) ✅
// ============================
  Future<void> loadCompanyJobs() async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(AuthFailure("No token found"));
        return;
      }

      final jobs = await api.getAllCompanyJobs(token);

      print("MY JOBS COUNT => ${jobs.length}");
      print(jobs);

      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  // ============================
// LOAD MY APPLICATIONS
// ============================
  Future<void> loadMyApplications() async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final apps = await api.getMyApplications(token);
      emit(ApplicationsLoaded(apps));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // ================= ADD JOB =================
  Future<void> addJob(
      String title,
      String description,
      String location,
      int minExp,
      int maxExp,
      String jobLevel,
      String employmentType,
      String jobType,
      ) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(AuthFailure("No token found"));
        return;
      }

      final result = await api.addJob(
        token,
        title,
        description,
        location,
        minExp,
        maxExp,
        jobLevel,
        employmentType,
        jobType,
      );

      if (result["success"] == true) {
        emit(AuthSuccess("JOB_ADDED"));
      } else {
        emit(AuthFailure(
          "Add Job Failed\n"
              "Status: ${result["statusCode"]}\n"
              "Error: ${result["error"]}",
        ));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }





// ============================
// LOAD JOB APPLICANTS
// ============================
  Future<void> loadJobApplicants(int jobId) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final users = await api.getJobApplicants(token, jobId);
      emit(ApplicantsLoaded(users));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> updateJob(
      int jobId,
      String title,
      String description,
      String location,
      String jobType,
      String jobLevel,
      String employmentType,
      ) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(AuthFailure("No token found"));
        return;
      }

      await api.updateJob(
        token,
        jobId,
        title,
        description,
        location,
        jobType,
        jobLevel,
        employmentType,
      );

      emit(AuthSuccess("JOB_UPDATED"));
      await loadCompanyJobs();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }





  Future<void> deleteJob(int jobId) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(AuthFailure("No token found"));
        return;
      }

      await api.deleteJob(token, jobId);

      emit(AuthSuccess("JOB_DELETED"));
      loadCompanyJobs(); // 🔄 reload list
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> loadRecommendedJobs() async {
    emit(AuthLoading());

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      emit(AuthFailure("No token found"));
      return;
    }

    final jobs = await api.getRecommendedJobs(token);
    emit(JobsLoaded(jobs));
  }




// ============================
// باقي الكود زي ما هو
// ============================
// register / uploadCv / loadCvs / deleteCv / profile / addJob



// ============================
  // REGISTER DEVELOPER
  // ============================
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

  // ============================
  // REGISTER COMPANY
  // ============================
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

  // ============================
  // AUTO LOGIN
  // ============================
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(token));
    } else {
      emit(AuthInitial());
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthInitial());
  }

  // ============================
  // UPLOAD CV (لمسناهش)
  // ============================
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
  // ============================
// LOAD CVS
// ============================
  Future<void> loadCvs() async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final cvs = await api.getAllCvs(token);
      emit(CvsLoaded(cvs));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

// ============================
// DELETE CV
// ============================
  Future<void> deleteCv(int cvId) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.deleteCv(token, cvId);
      emit(AuthSuccess("CV_DELETED"));
      loadCvs(); // refresh list
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  // ============================
  // LOAD USER PROFILE
  // ============================
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

  // ============================
  // UPDATE USER PROFILE
  // ============================
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

  // ============================
  // UPDATE COMPANY
  // ============================
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

  // ============================
  // CHANGE EMAIL
  // ============================
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