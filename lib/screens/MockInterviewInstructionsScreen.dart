import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MockInterviewInstructionsScreen extends StatefulWidget {
  const MockInterviewInstructionsScreen({super.key});

  @override
  State<MockInterviewInstructionsScreen> createState() => _MockInterviewInstructionsScreenState();
}

class _MockInterviewInstructionsScreenState extends State<MockInterviewInstructionsScreen> {

  String _selectedTrack = "Backend";
  String _selectedLevel = "Mid level";

  final List<String> _tracks = [
    "Backend",
    "Frontend",
    "Full Stack",
    "Flutter",
    "Android",
    "iOS",
    "Mobile",
    "Web Development",
    "Desktop Development",
    "Game Development",
    "Embedded Systems",
    "Data Science",
    "Data Analysis",
    "Data Engineering",
    "Machine Learning",
    "Deep Learning",
    "Artificial Intelligence",
    "Computer Vision",
    "Natural Language Processing",
    "Cyber Security",
    "Cloud Computing",
    "DevOps",
    "Site Reliability Engineering",
    "UI/UX Design",
    "QA",
    "Software Testing",
    "Automation Testing",
    "Database",
    "Business Intelligence",
    "Blockchain",
    "AR/VR",
    "IoT",
    "Networking",
    "System Administration",
    "ERP",
    "Product Management",
    "Project Management"
  ];
  final List<String> _levels = ["Junior", "Mid level", "Senior"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Mock Interview Instructions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.video_camera_front,
                      size: 72,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "Prepare for Success",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "You will answer 7 mock interview questions curated by AI.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "Select Your Interview Focus",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedTrack,
                  decoration: InputDecoration(
                    labelText: "Track",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.code, color: AppColors.primary),
                  ),
                  items: _tracks.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTrack = val);
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: InputDecoration(
                    labelText: "Experience Level",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.bar_chart, color: AppColors.primary),
                  ),
                  items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLevel = val);
                  },
                ),

                const SizedBox(height: 32),
                const Text(
                  "Instructions & Rules",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                _instructionStep(
                  "1",
                  "Enable Camera & Audio Permissions",
                  "The application needs access to your front camera and microphone to record your responses.",
                ),
                const SizedBox(height: 16),
                _instructionStep(
                  "2",
                  "120-Second Response Time",
                  "For each question, you have up to 120 seconds to formulate and record your answer. The timer will automatically submit when it hits zero.",
                ),
                const SizedBox(height: 16),
                _instructionStep(
                  "3",
                  "Video Upload & AI Evaluation",
                  "When you finish answering, your response will be securely uploaded. Our AI will analyze your communication skills, body language, and answer completeness to provide instantaneous feedback.",
                ),
                const SizedBox(height: 16),
                _instructionStep(
                  "4",
                  "Keep a Steady Environment",
                  "Ensure you are in a quiet, well-lit room and facing the camera directly for the best analysis results.",
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {

                      Navigator.pushReplacementNamed(
                        context,
                        "/mock-interview",
                        arguments: {
                          "track": _selectedTrack,
                          "interviewLevel": _selectedLevel,
                        },
                      );
                    },
                    child: const Text(
                      "Start Mock Interview",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _instructionStep(String num, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}