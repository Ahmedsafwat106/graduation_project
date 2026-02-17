import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/cv/cv_cubit.dart';
import '../features/cv/cv_state..dart';

class UploadCvScreen extends StatefulWidget {
  const UploadCvScreen({super.key});

  @override
  State<UploadCvScreen> createState() => _UploadCvScreenState();
}

class _UploadCvScreenState extends State<UploadCvScreen> {
  String? selectedFile;

  @override
  void initState() {
    super.initState();
    context.read<CvCubit>().loadCvs();
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
      body: BlocConsumer<CvCubit, CvState>(
        listener: (context, state) {
          if (state is CvFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {

          if (state is CvLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==========================================
          // ✅ لو عنده CV
          // ==========================================
          if (state is CvsLoaded && state.cvs.isNotEmpty) {

            final cv = state.cvs.first;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        size: 80, color: Colors.green),

                    const SizedBox(height: 20),

                    const Text(
                      "You already uploaded a CV",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Go To Dashboard
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                    ),

                    const SizedBox(height: 15),

                    // Delete CV
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          context.read<CvCubit>().deleteCv(
                            cv["id"],
                          );
                        },
                        child: const Text(
                          "Delete CV",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==========================================
          // ✅ لو مفيش CV → شاشة الرفع
          // ==========================================
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
                              selectedFile =
                              result.files.single.path!;
                            });
                          }
                        },
                        child: const Text("Choose PDF"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    onPressed: () {
                      if (selectedFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                            Text("Please select a CV first"),
                          ),
                        );
                        return;
                      }

                      context
                          .read<CvCubit>()
                          .uploadCv(selectedFile!);
                    },
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
