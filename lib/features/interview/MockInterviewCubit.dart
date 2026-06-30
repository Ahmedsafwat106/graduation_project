import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import 'MockInterviewState.dart';

class MockInterviewCubit extends Cubit<MockInterviewState> {
  final ApiService api;

  int _questionCounter = 1;
  static const int _totalQuestions = 7;

  List<Map<String, dynamic>> _questionQueue = [];
  int _currentQueueIndex = 0;

  String _currentUploadUrl = "";
  String _currentVideoId = "";
  int _currentInterviewId = 0;

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
            "You must upload your CV before starting an AI Mock Interview."));
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

      if (result["success"] != true) {
        emit(MockInterviewFailure(
            result["message"] ?? "Failed to start interview"));
        return;
      }

      _currentInterviewId = result["interviewId"];
      _currentUploadUrl = result["upload"] ?? "";
      _currentVideoId = result["videoId"] ?? "";

      _questionQueue = [];
      _currentQueueIndex = 0;
      _questionCounter = 1;

      if (result["questions"] != null && result["questions"] is List) {
        _questionQueue = List<Map<String, dynamic>>.from(
            (result["questions"] as List).map((q) => Map<String, dynamic>.from(q)));
      } else if (result["firstQuestion"] != null) {
        _questionQueue = [Map<String, dynamic>.from(result["firstQuestion"])];
      }

      if (_questionQueue.isEmpty) {
        emit(MockInterviewFailure("No questions received from server."));
        return;
      }

      final firstQuestion = Map<String, dynamic>.from(_questionQueue[0]);
      firstQuestion["questionNumber"] = 1;
      firstQuestion["totalQuestions"] = _totalQuestions;

      emit(MockInterviewStarted(
        interviewId: _currentInterviewId,
        uploadUrl: _currentUploadUrl,
        videoId: _currentVideoId,
        question: firstQuestion,
      ));
    } catch (e) {
      emit(MockInterviewFailure(e.toString()));
    }
  }

  Future<void> uploadAndNext({ required String filePath,
    required String uploadUrl,
    required String videoId,
    required int interviewId,}) async {
    emit(MockInterviewUploading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (_questionCounter > _totalQuestions) {
        print("✅ All $_totalQuestions questions done. Fetching report...");
        final reportResult = await api.getInterviewReport(token, interviewId);
        emit(MockInterviewFinished(reportResult));
        return;
      }

      if (filePath.isNotEmpty && uploadUrl.isNotEmpty) {
        await api.uploadVideoToS3(uploadUrl, filePath);
      }

      try {
        await api.confirmUpload(token, videoId);
      } catch (e) {
        print("⚠️ Confirm upload warning: $e");
      }

      final result = await api.submitGetNextQuestion(
        token: token,
        interviewId: interviewId.toString(),
        videoId: videoId,
      );

      print("========== SUBMIT RESULT ==========");
      print(result);

      _questionCounter++;
      _currentQueueIndex++;

      bool isCompleted = result["interviewCompleted"] == true ||
          _questionCounter > _totalQuestions;

      if (isCompleted) {
        print("✅ Interview complete. Getting report...");
        final reportResult = await api.getInterviewReport(token, interviewId);
        emit(MockInterviewFinished(reportResult));
        return;
      }

      Map<String, dynamic>? nextQuestion;

      if (_currentQueueIndex < _questionQueue.length) {
        nextQuestion = Map<String, dynamic>.from(
            _questionQueue[_currentQueueIndex]);
        print("📋 Using local queue question #$_currentQueueIndex");
      } else if (result["nextQuestion"] != null) {
        nextQuestion = Map<String, dynamic>.from(result["nextQuestion"]);
        print("🌐 Using server question (queue exhausted)");
      }

      if (nextQuestion == null) {
        final reportResult = await api.getInterviewReport(token, interviewId);
        emit(MockInterviewFinished(reportResult));
        return;
      }

      nextQuestion["questionNumber"] = _questionCounter;
      nextQuestion["totalQuestions"] = _totalQuestions;

      if (result["videoId"] != null && result["videoId"].toString().isNotEmpty) {
        _currentVideoId = result["videoId"].toString();
      }
      if (result["upload"] != null && result["upload"].toString().isNotEmpty) {
        _currentUploadUrl = result["upload"].toString();
      }

      emit(MockInterviewNextQuestion(
        question: nextQuestion,
        uploadUrl: _currentUploadUrl,
        videoId: _currentVideoId,
      ));
    } catch (e) {
      emit(MockInterviewFailure(e.toString()));
    }
  }
}