import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'MockInterviewState.dart';

class MockInterviewCubit extends Cubit<MockInterviewState> {
  final ApiService api;

  int _questionCounter = 1;

  MockInterviewCubit(this.api) : super(MockInterviewInitial());

  Future<void> startInterview({
    required String track,
    required String interviewLevel,
  }) async {
    emit(MockInterviewLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) {
        emit(MockInterviewFailure("No token found. Please login again."));
        return;
      }

      final cvs = await api.getAllCvs(token);
      if (cvs.isEmpty) {
        emit(MockInterviewFailure(
            "You must upload your CV to your profile before starting an AI Mock Interview."));
        return;
      }

      final int activeCvId = cvs[0]["id"];

      final result = await api.startInterview(
        token,
        cvId: activeCvId,
        track: track,
        level: interviewLevel,
      );

      print("📦 FULL START INTERVIEW RESPONSE => $result");

      if (result["success"] == true) {

        _questionCounter = 1;

        final firstQuestion =
        Map<String, dynamic>.from(result["firstQuestion"] ?? {});

        firstQuestion["questionNumber"] = _questionCounter;
        firstQuestion["totalQuestions"] = 7;

        emit(MockInterviewStarted(
          interviewId: result["interviewId"],
          uploadUrl: result["upload"] ?? "",
          videoId: result["videoId"] ?? "",
          question: firstQuestion,
        ));
      } else {
        emit(MockInterviewFailure(
            result["message"] ?? "Failed to start interview"));
      }
    } catch (e) {
      emit(MockInterviewFailure(e.toString()));
    }
  }
  Future<void> uploadAndNext({
    required String filePath,
    required String uploadUrl,
    required String videoId,
    required int interviewId,
  }) async {
    emit(MockInterviewUploading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (filePath.isNotEmpty && uploadUrl.isNotEmpty) {
        await api.uploadVideoToS3(uploadUrl, filePath);
      }

      try {
        await api.confirmUpload(token, videoId);
      } catch (e) {

        print("⚠️ Confirm upload returned error but continuing: $e");
      }

      final result = await api.submitGetNextQuestion(
        token: token,
        interviewId: interviewId.toString(),
        videoId: videoId,
      );

      print("💬 SUBMIT RESPONSE => $result");

      if (result["success"] == true) {
        bool isCompleted = result["interviewCompleted"] ?? false;

        if (isCompleted || result["nextQuestion"] == null) {
          emit(MockInterviewLoading());
          final reportResult = await api.getInterviewReport(token, interviewId);
          emit(MockInterviewFinished(reportResult));
        } else {

          _questionCounter++;

          final next =
          Map<String, dynamic>.from(result["nextQuestion"] ?? {});

          next["questionNumber"] = _questionCounter;
          next["totalQuestions"] = 7;

          final nextVideoId = result["videoId"]?.toString() ?? videoId;
          final nextUploadUrl = result["upload"]?.toString() ?? "";

          emit(MockInterviewNextQuestion(
            question: next,
            uploadUrl: nextUploadUrl,
            videoId: nextVideoId,
          ));
        }
      } else {
        emit(MockInterviewFailure(
            result["message"] ?? "Failed to get next question"));
      }
    } catch (e) {
      emit(MockInterviewFailure(e.toString()));
    }
  }
}