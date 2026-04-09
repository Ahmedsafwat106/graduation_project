import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'applications_state..dart';

class ApplicationsCubit extends Cubit<ApplicationsState> {
  final ApiService api;

  ApplicationsCubit(this.api) : super(ApplicationsInitial());

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    if (token.isEmpty) throw Exception("No token found");
    return token;
  }

  Future<void> applyJob(int jobId, int cvId) async {
    emit(ApplicationsLoading());
    try {
      final token = await _getToken();

      await api.applyJob(token, jobId, cvId);

      emit(ApplicationsSuccess("JOB_APPLIED"));
    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }

  Future<void> loadMyApplications() async {
    emit(ApplicationsLoading());
    try {
      final token = await _getToken();

      final apps = await api.getMyApplications(token);
      emit(ApplicationsLoaded(apps));
    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }

  Future<void> loadApplicantsScreen(int jobId) async {
    emit(ApplicationsLoading());

    try {
      final token = await _getToken();

      final applicants = await api.getAllApplicants(token, jobId);
      final counts = await api.getApplicantCount(token, jobId);

      emit(ApplicantsScreenLoaded(
        applicants: applicants,
        counts: counts,
      ));
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
      final token = await _getToken();

      await api.updateApplicantStatus(
        token,
        jobId,
        userId,
        status,
      );

      final current = state;
      if (current is ApplicantsScreenLoaded) {
        final updated = current.applicants.map((a) {
          if ((a["userId"] ?? 0) == userId) {
            return {...a, "status": status};
          }
          return a;
        }).toList();

        emit(ApplicantsScreenLoaded(
          applicants: updated,
          counts: current.counts,
        ));
      }
    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }

  Future<void> loadApplicantHistoryScreen() async {
    emit(ApplicationsLoading());

    try {
      final token = await _getToken();

      final history = await api.getApplicantHistory(token);
      final counts = await api.getApplicantHistoryCount(token);

      emit(ApplicantHistoryScreenLoaded(
        history: history,
        counts: counts,
      ));
    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }

  Future<void> searchApplicants(int jobId, String query) async {
    if (query.trim().isEmpty) {
      await loadApplicantsScreen(jobId);
      return;
    }

    try {
      final token = await _getToken();

      final allApplicants = await api.getAllApplicants(token, jobId);

      final filtered = allApplicants.where((a) {
        final name = (a["name"] ?? "").toString().toLowerCase();
        final skills = (a["skillName"] ?? []).toString().toLowerCase();

        return name.contains(query.toLowerCase()) ||
            skills.contains(query.toLowerCase());
      }).toList();

      final current = state;
      Map<String, dynamic> counts = {};

      if (current is ApplicantsScreenLoaded) {
        counts = current.counts;
      }

      emit(ApplicantsScreenLoaded(
        applicants: filtered,
        counts: counts,
      ));
    } catch (e) {
      emit(ApplicationsFailure(e.toString()));
    }
  }
}