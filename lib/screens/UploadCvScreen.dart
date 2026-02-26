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
      backgroundColor: const Color(0xFFF4F7F6),
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// ==========================================
          /// ✅ لو عنده CV بالفعل
          /// ==========================================
          if (state is CvsLoaded && state.cvs.isNotEmpty) {
            final cv = state.cvs.first;

            return Column(
              children: [

                /// ===== GRADIENT HEADER =====
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.fromLTRB(20, 50, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1FA463),
                        Color(0xFF159957),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: const Text(
                    "Your CV",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1FA463),
                                    Color(0xFF159957),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "You already uploaded a CV",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// Go To Dashboard (Gradient Button)
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1FA463),
                                      Color(0xFF159957),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      "/developer-dashboard",
                                    );
                                  },
                                  child: const Text(
                                    "Go to Dashboard",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            /// Delete CV (Soft Danger Button)
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  context
                                      .read<CvCubit>()
                                      .deleteCv(cv["id"]);
                                },
                                child: const Text(
                                  "Delete CV",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          /// ==========================================
          /// ✅ لو مفيش CV → شاشة الرفع
          /// ==========================================
          return Column(
            children: [

              /// ===== GRADIENT HEADER =====
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.fromLTRB(20, 50, 20, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1FA463),
                      Color(0xFF159957),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: const Text(
                  "Upload CV",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
                  child: Column(
                    children: [

                      /// Upload Card (Modern)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1FA463)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.upload_file_rounded,
                                size: 40,
                                color: Color(0xFF1FA463),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              selectedFile ?? "No file selected",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: selectedFile == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// Choose PDF Button (Soft)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFF4F7F6),
                                foregroundColor:
                                const Color(0xFF1FA463),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                              ),
                              icon: const Icon(Icons.attach_file),
                              label: const Text("Choose PDF"),
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
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      /// Upload Button (Brand Gradient)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1FA463),
                                Color(0xFF159957),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.green.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              if (selectedFile == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Please select a CV first"),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}