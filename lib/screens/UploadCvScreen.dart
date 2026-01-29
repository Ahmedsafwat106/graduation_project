import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class UploadCvScreen extends StatefulWidget {
  const UploadCvScreen({super.key});

  @override
  State<UploadCvScreen> createState() => _UploadCvScreenState();
}

class _UploadCvScreenState extends State<UploadCvScreen> {
  String? selectedFile;
  String role = "developer";

  @override
  void initState() {
    super.initState();
    _loadRole();
    context.read<AuthCubit>().loadCvs();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role") ?? "developer";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Upload CV",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.message == "CV_UPLOADED") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("CV Uploaded Successfully 🎉"),
                backgroundColor: Colors.green,
              ),
            );
            context.read<AuthCubit>().loadCvs();
          }

          if (state is AuthSuccess && state.message == "CV_DELETED") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("CV deleted successfully"),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },

        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // =========================
          // USER ALREADY HAS CV
          // =========================
          if (state is CvsLoaded && state.cvs.isNotEmpty) {
            final cv = state.cvs.first;

            return Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf,
                      size: 80, color: Colors.green),

                  const SizedBox(height: 15),

                  const Text(
                    "You already uploaded a CV",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔥 NEW BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, "/developer-dashboard");
                    },
                    child: const Text(
                      "Go to Dashboard",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().deleteCv(cv["id"]);
                    },
                    child: const Text(
                      "Delete CV",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          // =========================
          // NO CV → UPLOAD
          // =========================
          return Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.upload_file,
                          size: 60, color: Color(0xFF4CAF50)),

                      const SizedBox(height: 16),

                      Text(
                        selectedFile ?? "No file selected",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selectedFile == null
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                        onPressed: () async {
                          final result =
                          await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );

                          if (result != null &&
                              result.files.single.path != null) {
                            setState(() {
                              selectedFile = result.files.single.path!;
                            });
                          }
                        },
                        child: const Text("Choose PDF"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                GestureDetector(
                  onTap: () {
                    if (selectedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please select a CV first")),
                      );
                      return;
                    }

                    context.read<AuthCubit>().uploadCv(selectedFile!);
                  },
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF66BB6A),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Upload CV",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
