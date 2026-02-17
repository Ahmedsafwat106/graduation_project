import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'cv_state..dart';

class CvCubit extends Cubit<CvState> {
  final ApiService api;
  CvCubit(this.api) : super(CvInitial());

  Future<void> uploadCv(String filePath) async {
    emit(CvLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.uploadCv(filePath, token);

      // 👇 من غير CvSuccess
      await loadCvs();

    } catch (e) {
      emit(CvFailure(e.toString()));
    }
  }
  Future<void> loadCvs() async {
    emit(CvLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      print("TOKEN => $token");

      final cvs = await api.getAllCvs(token);

      // 👇 هنا تحط الـ print
      print("CV BODY RAW => $cvs");

      emit(CvsLoaded(cvs));
    } catch (e) {
      emit(CvFailure(e.toString()));
    }
  }



  Future<void> deleteCv(int cvId) async {
    emit(CvLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await api.deleteCv(token, cvId);

      // 👇 reload بس
      await loadCvs();

    } catch (e) {
      emit(CvFailure(e.toString()));
    }
  }


}
