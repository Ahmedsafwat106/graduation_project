import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'applications_state..dart';


class ApplicationsCubit extends Cubit<ApplicationsState> {
  final ApiService api;
  ApplicationsCubit(this.api) : super(ApplicationsInitial());

  Future<void> applyJob(int jobId, int cvId) async {
    emit(ApplicationsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        throw Exception("User not logged in");
      }

      await api.applyJob(token, jobId, cvId);

      emit(ApplicationsSuccess("JOB_APPLIED"));
    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }


  Future<void> loadMyApplications() async {
    emit(ApplicationsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final apps = await api.getMyApplications(token);
      emit(ApplicationsLoaded(apps));
    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }

  Future<void> loadApplicantsScreen(int jobId) async {
    emit(ApplicationsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        throw Exception("No token found");
      }

      final applicants =
      await api.getAllApplicants(token, jobId);

      final counts =
      await api.getApplicantCount(token, jobId);

      emit(
        ApplicantsScreenLoaded(
          applicants: applicants,
          counts: counts,
        ),
      );

    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }


  Future<void> updateStatus(
      int jobId,
      int userId,
      String status,
      ) async {

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.updateApplicantStatus(
          token,
          jobId,
          userId,
          status);

      await loadApplicantsScreen(jobId);

    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }
  Future<void> loadApplicantHistoryScreen() async {
    emit(ApplicationsLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        throw Exception("No token found");
      }

      final history = await api.getApplicantHistory(token);
      final counts = await api.getApplicantHistoryCount(token);

      emit(
        ApplicantHistoryScreenLoaded(
          history: history,
          counts: counts,
        ),
      );

    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }

}