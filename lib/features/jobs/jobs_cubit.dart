import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import '../../core/signalr_service.dart';
import 'jobs_state..dart';


class JobsCubit extends Cubit<JobsState> {
  final ApiService api;
  JobsCubit(this.api) : super(JobsInitial());

  Future<void> loadJobs() async {
    emit(JobsLoading());
    try {
      final jobs = await api.getAllJobs();
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }

  Future<void> loadCompanyJobs() async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(JobsFailure("No token found"));
        return;
      }

      final jobs = await api.getAllCompanyJobs(token);
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }
  Future<void> addJob(
      String title,
      String description,
      String location,
      int minExp,
      int maxExp,
      String jobLevel,
      String employmentType,
      String jobType,
      List<String> skills,
      ) async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      print("ADD JOB TOKEN => $token");
      if (token.isEmpty) {
        emit(JobsFailure("No token found"));
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
        skills,
      );

      if (result["success"] == true) {
        emit(JobActionSuccess("JOB_ADDED"));
      } else {
        emit(JobsFailure(result["error"]));
      }
    } catch (e) {
      emit(JobsFailure(e.toString()));
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
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(JobsFailure("No token found"));
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

      emit(JobActionSuccess("JOB_UPDATED"));
      await loadCompanyJobs();
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }

  Future<void> deleteJob(int jobId) async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(JobsFailure("No token found"));
        return;
      }

      await api.deleteJob(token, jobId);
      emit(JobActionSuccess("JOB_DELETED"));
      loadCompanyJobs();
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }

  Future<void> loadRecommendedJobs() async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) {
        emit(JobsFailure("No token found"));
        return;
      }
      final jobs = await api.getRecommendedJobs(token);
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }

  Future<void> savePreferences(
      List<String> jobTypes,
      String jobLevel,
      List<String> skills,
      int minimumSalary,
      ) async {

    emit(JobsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(JobsFailure("No token found"));
        return;
      }

      await api.saveUserPreferences(
        token,
        jobTypes,
        jobLevel,
        skills,
        minimumSalary,
      );

      final jobs = await api.getRecommendedJobs(token);
      emit(JobsLoaded(jobs));

    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }


  Future<void> loadAllSkills() async {
    emit(JobsLoading());
    try {
      final skills = await api.getAllSkills();
      emit(SkillsLoaded(skills));
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }
  Future<void> loadCompanyDashboard() async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) throw Exception("No token found");

      Map<String, dynamic> counts = {};
      try {
        counts = await api.getCompanyCount(token);
      } catch (e) {
        print("⚠️ company count error: $e");
        counts = {"applicants": 0, "hires": 0, "activeJob": 0};
      }

      final jobs = await api.getAllCompanyJobs(token);
      emit(CompanyDashboardLoaded(counts: counts, jobs: jobs));

    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }
  Future<void> loadDeveloperDashboard() async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) throw Exception("No token found");

      final counts = await api.getUserCount(token);
      final jobs = await api.getAllJobs();

      emit(DeveloperDashboardLoaded(counts: counts, jobs: jobs));
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }
  Future<void> loadSavedJobs(int userId) async {
    emit(JobsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        emit(JobsFailure("No token"));
        return;
      }

      final jobs = await api.getSavedJobs(token, userId);
      emit(SavedJobsLoaded(jobs));
    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }

  Future<void> saveJob(int userId, int jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      print("===== CUBIT SAVE DEBUG =====");
      print("TOKEN => $token");
      print("USER ID => $userId");
      print("JOB ID => $jobId");
      print("============================");

      await api.addSavedJob(token, userId, jobId);

      print("✅ SAVE COMPLETED");

    } catch (e) {
      print("❌ SAVE ERROR => $e");
      emit(JobsFailure(e.toString()));
    }
  }
  Future<void> connectJobHub() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final myAppUser = prefs.getString("appUser") ?? "";
    final myUserId = prefs.getInt("userId") ?? 0;

    if (token.isEmpty) return;

    await SignalRService().connectJobHub(
      token: token,

      onApplyCountForDeveloper: (userId, applyCount) {
        if (userId == myAppUser) {
          emit(DeveloperApplyCountUpdated(
            userId: userId,
            applyCount: applyCount,
          ));
        }
      },

      onApplyCountForCompany: (applyCount, newCount) {
        emit(CompanyApplyCountUpdated(
          applyCount: applyCount,
          newCount: newCount,
        ));
      },

      onActiveJobsUpdated: (active, companyId) {
        emit(ActiveJobsUpdated(
          active: active,
          companyId: companyId,
        ));
      },

      onStatusUpdatedForCompany: (data) {
        emit(StatusUpdatedForCompany(
          newStatus: _str(data, ["newStatus", "NewStatus"]),
          countInterview: _int(data, ["countInterviewForCompany", "CountInterviewForCompany"]),
          countAccepted: _int(data, ["countAcceptedForCompany", "CountAcceptedForCompany"]),
          countRejected: _int(data, ["countRejectedForCompany", "CountRejectedForCompany"]),
          countNew: _int(data, ["countNewForCompany", "CountNewForCompany"]),
        ));
      },

      onStatusUpdatedForDeveloper: (data) {
        emit(StatusUpdatedForDeveloper(
          newStatus: _str(data, ["newStatus", "NewStatus"]),
          countAccepted: _int(data, ["countAcceptedForDeveloper", "CountAcceptedForDeveloper"]),
          countRejected: _int(data, ["countRejectedForDeveloper", "CountRejectedForDeveloper"]),
          countNew: _int(data, ["countNewForDeveloper", "CountNewForDeveloper"]),
          countInterview: _int(data, ["countInterviewForDeveloper", "CountInterviewForDeveloper"]),
        ));
      },
    );
  }

  int _int(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v != null) return v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    return 0;
  }

  String _str(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v != null) return v.toString();
    }
    return "";
  }
}
