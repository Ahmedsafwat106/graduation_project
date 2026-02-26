import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/applications/applications_cubit.dart';
import '../features/applications/applications_state..dart';
import '../features/cv/cv_cubit.dart';
import '../features/cv/cv_state..dart';

class ApplyJobScreen extends StatefulWidget {
  final Map job;
  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {

  int? selectedCvId;

  @override
  void initState() {
    super.initState();
    context.read<CvCubit>().loadCvs();
  }

  @override
  Widget build(BuildContext context) {

    final int? jobId =
        widget.job["id"] ??
            widget.job["jobId"] ??
            widget.job["job_id"];

    if (jobId == null) {
      return const Scaffold(
        body: Center(child: Text("Invalid Job ID")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ApplicationsCubit, ApplicationsState>(
            listener: (context, state) {
              if (state is ApplicationsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Applied successfully ✅")),
                );
                Navigator.pop(context);
              }

              if (state is ApplicationsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: Column(
          children: [

            /// ================= MODERN HEADER =================
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
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Apply Job",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Confirm your application",
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

            /// ================= BODY =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// ============ JOB CARD (Premium) ============
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job["title"] ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.job["description"] ??
                                widget.job["desctiption"] ??
                                "",
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// ============ SELECT CV TITLE ============
                    const Text(
                      "Select CV",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// ============ CV DROPDOWN CARD ============
                    BlocBuilder<CvCubit, CvState>(
                      builder: (context, state) {

                        if (state is CvLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is CvsLoaded) {

                          if (state.cvs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text("No CV uploaded"),
                            );
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: DropdownButton<int>(
                              value: selectedCvId,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: const Text("Choose your CV"),
                              items: state.cvs
                                  .map<DropdownMenuItem<int>>((cv) {
                                return DropdownMenuItem<int>(
                                  value: cv["id"],
                                  child: Text(
                                    cv["cvName"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCvId = value;
                                });
                              },
                            ),
                          );
                        }

                        return const SizedBox();
                      },
                    ),

                    const Spacer(),

                    /// ============ GRADIENT APPLY BUTTON ============
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
                          onPressed: selectedCvId == null
                              ? null
                              : () {
                            context
                                .read<ApplicationsCubit>()
                                .applyJob(jobId, selectedCvId!);
                          },
                          child: const Text(
                            "Confirm Apply",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
        ),
      ),
    );
  }
}