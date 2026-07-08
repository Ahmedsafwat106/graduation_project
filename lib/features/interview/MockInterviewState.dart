abstract class MockInterviewState {}

class MockInterviewInitial extends MockInterviewState {}

class MockInterviewLoading extends MockInterviewState {}

class MockInterviewUploading extends MockInterviewState {
  final double progress;
  final String label;

  MockInterviewUploading({this.progress = 0.0, this.label = "Uploading…"});
}

class MockInterviewStarted extends MockInterviewState {
  final int interviewId;
  final String uploadUrl;
  final String videoId;
  final Map<String, dynamic> question;

  MockInterviewStarted({
    required this.interviewId,
    required this.uploadUrl,
    required this.videoId,
    required this.question,
  });
}

class MockInterviewNextQuestion extends MockInterviewState {
  final Map<String, dynamic> question;
  final String uploadUrl;
  final String videoId;

  MockInterviewNextQuestion({
    required this.question,
    required this.uploadUrl,
    required this.videoId,
  });
}

class MockInterviewFinished extends MockInterviewState {
  final Map<String, dynamic> reportData;
  MockInterviewFinished(this.reportData);
}

class MockInterviewFailure extends MockInterviewState {
  final String message;
  MockInterviewFailure(this.message);
}