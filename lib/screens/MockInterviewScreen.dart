import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/app_colors.dart';
import '../features/interview/MockInterviewCubit.dart';
import '../features/interview/MockInterviewState.dart';

class MockInterviewScreen extends StatefulWidget {
  final String track;
  final String interviewLevel;

  const MockInterviewScreen({
    super.key,
    this.track = "Backend",
    this.interviewLevel = "Mid level",
  });

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraHasError = false;

  FlutterTts? _flutterTts;
  bool _isSpeaking = false;

  Timer? _countdownTimer;
  int _timeLeft = 120;

  String _currentUploadUrl = "";
  String _currentVideoId = "";
  int _currentInterviewId = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initCamera();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MockInterviewCubit>().startInterview(
        track: widget.track,
        interviewLevel: widget.interviewLevel,
      );
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopSpeaking();
    _cameraController?.dispose();
    super.dispose();
  }

  void _initTts() {
    try {
      _flutterTts = FlutterTts();
      _flutterTts!.setLanguage("en-US");
      _flutterTts!.setSpeechRate(0.45);
      _flutterTts!.setVolume(1.0);
      _flutterTts!.setPitch(1.0);

      _flutterTts!.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _flutterTts!.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _flutterTts!.setErrorHandler((msg) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (e) {
      print("TTS Initialization Error: $e");
    }
  }

  Future<void> _speak(String text) async {
    if (_flutterTts == null || text.isEmpty) return;
    try {
      await _flutterTts!.stop();
      await _flutterTts!.speak(text);
    } catch (e) {
      print("TTS Speak Error: $e");
    }
  }

  Future<void> _stopSpeaking() async {
    if (_flutterTts == null) return;
    try {
      await _flutterTts!.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } catch (e) {
      print("TTS Stop Error: $e");
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraHasError = true);
        return;
      }
      final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraHasError = false;
        });

        final cubitState = context.read<MockInterviewCubit>().state;
        if (cubitState is MockInterviewStarted ||
            cubitState is MockInterviewNextQuestion) {
          _startCameraRecording();
        }
      }
    } catch (e) {
      print("Camera Initialization Error: $e");
      if (mounted) {
        setState(() {
          _cameraHasError = true;
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _startCameraRecording() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isRecordingVideo) return;
    try {
      await _cameraController!.startVideoRecording();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error starting video recording: $e");
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _timeLeft = 120);
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timeLeft > 0) {
            setState(() => _timeLeft--);
          } else {
            _countdownTimer?.cancel();
            _submitResponse();
          }
        });
  }

  Future<void> _submitResponse() async {
    _countdownTimer?.cancel();
    _stopSpeaking();

    String path = "";
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        _cameraController!.value.isRecordingVideo) {
      try {
        final file = await _cameraController!.stopVideoRecording();
        path = file.path;
      } catch (e) {
        print("Error stopping video recording: $e");
      }
    }

    if (mounted) {
      context.read<MockInterviewCubit>().uploadAndNext(
        filePath: path,
        uploadUrl: _currentUploadUrl,
        videoId: _currentVideoId,
        interviewId: _currentInterviewId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MockInterviewCubit, MockInterviewState>(
      listener: (context, state) {
        if (state is MockInterviewStarted) {
          _currentUploadUrl = state.uploadUrl;
          _currentVideoId = state.videoId;
          _currentInterviewId = state.interviewId;
          _speak(state.question["question"] ?? "");
          _startTimer();
          _startCameraRecording();
        } else if (state is MockInterviewNextQuestion) {
          _currentUploadUrl = state.uploadUrl;
          _currentVideoId = state.videoId;
          _speak(state.question["question"] ?? "");
          _startTimer();
          _startCameraRecording();
        } else if (state is MockInterviewFinished) {
          _countdownTimer?.cancel();
          _stopSpeaking();
          _cameraController?.dispose();
          _cameraController = null;
          _isCameraInitialized = false;
        } else if (state is MockInterviewFailure) {
          _countdownTimer?.cancel();
          _stopSpeaking();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "AI Mock Interview",
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _showExitDialog,
          ),
        ),
        body: BlocBuilder<MockInterviewCubit, MockInterviewState>(
          builder: (context, state) {
            if (state is MockInterviewInitial ||
                state is MockInterviewLoading) {
              return _buildLoadingScreen("Initializing Mock Interview...");
            }
            if (state is MockInterviewUploading) {
              return _buildLoadingScreen(
                  "Uploading & processing your response...");
            }
            if (state is MockInterviewFailure) {
              return _buildFailureScreen(state.message);
            }
            if (state is MockInterviewFinished) {
              return _buildCompletedScreen(state.reportData);
            }
            if (state is MockInterviewStarted) {
              return _buildInterviewDashboard(state.question);
            }
            if (state is MockInterviewNextQuestion) {
              return _buildInterviewDashboard(state.question);
            }
            return const Center(child: Text("Welcome to AI Mock Interview"));
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(String status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 4),
            const SizedBox(height: 24),
            Text(status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureScreen(String error) {
    bool isCvMissing = error.contains("CV") || error.contains("cv");

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text("An Error Occurred",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (isCvMissing) {
                  Navigator.pop(context);
                } else {
                  context.read<MockInterviewCubit>().startInterview(
                    track: widget.track,
                    interviewLevel: widget.interviewLevel,
                  );
                }
              },
              child:
              Text(isCvMissing ? "Go to Upload CV" : "Retry Interview"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Exit to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedScreen(Map<String, dynamic> report) {
    final double overallScore =
    (report["overallScore"] ?? 0.0).toDouble();
    final double commScore =
    (report["communicationScore"] ?? 0.0).toDouble();
    final double confScore =
    (report["confidenceScore"] ?? 0.0).toDouble();
    final double bodyScore =
    (report["bodyLanguageScore"] ?? 0.0).toDouble();

    final String emotionalProfile =
        report["emotionalProfile"] ?? "No analysis available.";
    final String speechProfile =
        report["speechProfile"] ?? "No analysis available.";
    final String bodyLanguageSummary =
        report["bodyLanguageSummary"] ?? "No analysis available.";

    final List<dynamic> strengths = report["strengths"] ?? [];
    final List<dynamic> improvements =
        report["areasForImprovement"] ?? [];
    final List<dynamic> recommendations =
        report["recommendations"] ?? [];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.analytics_outlined,
                      color: AppColors.primary, size: 64),
                  const SizedBox(height: 12),
                  const Text(
                    "Interview Performance Report",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                  Text("AI-Generated Feedback",
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("Performance Scores",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildScoreCard("Overall", overallScore, Colors.blue),
                _buildScoreCard(
                    "Communication", commScore, Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildScoreCard("Confidence", confScore, Colors.orange),
                _buildScoreCard(
                    "Body Language", bodyScore, Colors.purple),
              ],
            ),

            const SizedBox(height: 24),
            _buildProfileSection(
                "Emotional & Tone Profile", emotionalProfile, Icons.psychology),
            _buildProfileSection("Speech & Clarity Profile", speechProfile,
                Icons.record_voice_over),
            _buildProfileSection("Body Language Summary", bodyLanguageSummary,
                Icons.accessibility_new),

            const SizedBox(height: 24),
            if (strengths.isNotEmpty) ...[
              const Text("👍 Key Strengths",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const SizedBox(height: 8),
              ...strengths.map((s) => _buildBulletItem(s.toString())),
              const SizedBox(height: 16),
            ],

            if (improvements.isNotEmpty) ...[
              const Text("📉 Areas For Improvement",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
              const SizedBox(height: 8),
              ...improvements.map((i) => _buildBulletItem(i.toString())),
              const SizedBox(height: 16),
            ],

            if (recommendations.isNotEmpty) ...[
              const Text("💡 AI Actionable Recommendations",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              ...recommendations
                  .map((r) => _buildBulletItem(r.toString())),
              const SizedBox(height: 24),
            ],

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Finish & Exit",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, double score, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text("$score / 10",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(
      String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
            ],
          ),
          const Divider(),
          Text(content,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary)),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.3))),
        ],
      ),
    );
  }

  Widget _buildInterviewDashboard(Map<String, dynamic> question) {
    final String questionText =
        question["question"] ?? question["Question"] ?? "No question data";

    final int currentNum =
    (question["questionNumber"] ?? 1) as int;
    final int totalQuestions =
    (question["totalQuestions"] ?? 7) as int;

    final double progress = totalQuestions > 0
        ? (currentNum / totalQuestions).clamp(0.0, 1.0)
        : 0.0;

    Color timerColor = Colors.green;
    if (_timeLeft <= 30) {
      timerColor = Colors.red;
    } else if (_timeLeft <= 60) {
      timerColor = Colors.orange;
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Question $currentNum of $totalQuestions",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary),
                    ),
                    Text(
                      "${(progress * 100).toInt()}% Done",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: timerColor, size: 20),
                  const SizedBox(width: 10),
                  Text("Remaining Time:",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const Spacer(),
                  Text("$_timeLeft s",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: timerColor)),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.forum_outlined,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text("AI Question",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600)),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                              _isSpeaking
                                  ? Icons.volume_up
                                  : Icons.volume_mute,
                              color: AppColors.primary),
                          onPressed: () => _isSpeaking
                              ? _stopSpeaking()
                              : _speak(questionText),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(questionText,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                height: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isCameraInitialized && _cameraController != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AspectRatio(
                          aspectRatio:
                          _cameraController!.value.aspectRatio,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_off_outlined,
                              color: Colors.white.withOpacity(0.4),
                              size: 48),
                          const SizedBox(height: 8),
                          Text(
                              _cameraHasError
                                  ? "Camera not detected."
                                  : "Starting Front Camera...",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12)),
                        ],
                      ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _RecordingPulseDot(),
                            SizedBox(width: 6),
                            Text("REC",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.stop_circle_outlined, size: 24),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 2),
                onPressed: _submitResponse,
                label: const Text("Submit & Next",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Exit Interview?"),
        content: const Text(
            "Are you sure you want to quit? Your progress will be lost."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Exit",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _RecordingPulseDot extends StatefulWidget {
  const _RecordingPulseDot();

  @override
  State<_RecordingPulseDot> createState() => _RecordingPulseDotState();
}

class _RecordingPulseDotState extends State<_RecordingPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
              color: Colors.red, shape: BoxShape.circle)),
    );
  }
}