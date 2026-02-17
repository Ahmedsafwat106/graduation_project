import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/profile/profile_state..dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ApiService api;
  ProfileCubit(this.api) : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    emit(ProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      final data = await api.getUserData(token);
      emit(ProfileLoaded(data));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateUserProfile(
      String first, String last, String phone, String city) async {
    emit(ProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      await api.updateUserProfile(token, first, last, phone, city);
      emit(ProfileSuccess("PROFILE_UPDATED"));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateCompany(
      String company, String phone, String city, String field) async {
    emit(ProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      await api.updateCompanyProfile(token, company, phone, city, field);
      emit(ProfileSuccess("COMPANY_UPDATED"));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
