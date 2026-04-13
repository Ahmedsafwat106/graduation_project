import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';

class EditJobScreen extends StatefulWidget {
  final Map job;
  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late TextEditingController title;
  late TextEditingController description;
  late TextEditingController location;

  late String jobType;
  late String jobLevel;
  late String employmentType;

  @override
  void initState() {
    super.initState();

    title = TextEditingController(text: widget.job["title"] ?? "");
    description =
        TextEditingController(text: widget.job["description"] ?? "");
    location = TextEditingController(text: widget.job["location"] ?? "");

    jobType = widget.job["jobType"] ?? "Onsite";
    jobLevel = widget.job["jobLevel"] ?? "Mid";
    employmentType = widget.job["employmentType"] ?? "Parttime";
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int jobId = widget.job["id"];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: BlocConsumer<JobsCubit, JobsState>(
        listener: (context, state) {
          if (state is JobActionSuccess && state.message == "JOB_UPDATED") {
            Navigator.pop(context);
          }

          if (state is JobsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Job",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Update your job details",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    children: [
                      _modernField(
                        "Job Title",
                        title,
                        Icons.work_outline,
                      ),
                      _modernField(
                        "Description",
                        description,
                        Icons.description_outlined,
                        max: 4,
                      ),
                      _modernField(
                        "Location",
                        location,
                        Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 30),

                      state is AuthLoading
                          ? const CircularProgressIndicator(color: Color(0xFF1FA463), strokeWidth: 3)
                          : SizedBox(
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                              context.read<JobsCubit>().updateJob(
                                jobId,
                                title.text.trim(),
                                description.text.trim(),
                                location.text.trim(),
                                jobType,
                                jobLevel,
                                employmentType,
                              );
                            },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(color: Color(0xFF1FA463), strokeWidth: 3)
                                : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

  Widget _modernField(String label, TextEditingController c,
      IconData icon,
      {int max = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        maxLines: max,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1FA463)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}