import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'jobs_state..dart';


class JobsCubit extends Cubit<JobsState> {
  final ApiService api;
  JobsCubit(this.api) : super(JobsInitial());

  Future<void> loadJobs() async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        throw Exception("User not logged in");
      }

      final jobs = await api.getJobs(token);
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
      ) async {
    emit(JobsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

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

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      emit(JobsFailure("No token found"));
      return;
    }

    final jobs = await api.getRecommendedJobs(token);
    emit(JobsLoaded(jobs));
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

      // 👇 المهم
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

      if (token.isEmpty) {
        throw Exception("No token found");
      }

      final counts = await api.getCompanyCount(token);
      final jobs = await api.getAllCompanyJobs(token);

      emit(
        CompanyDashboardLoaded(
          counts: counts,
          jobs: jobs,
        ),
      );

    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }
  Future<void> loadDeveloperDashboard() async {
    emit(JobsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        throw Exception("No token found");
      }

      final counts = await api.getUserCount(token);
      final jobs = await api.getJobs(token);

      emit(
        DeveloperDashboardLoaded(
          counts: counts,
          jobs: jobs,
        ),
      );

    } catch (e) {
      emit(JobsFailure(e.toString()));
    }
  }

}
