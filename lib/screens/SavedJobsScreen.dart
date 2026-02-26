import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';

class SavedJobsScreen extends StatefulWidget {
  final int userId;

  const SavedJobsScreen({super.key, required this.userId});

  @override
  State<SavedJobsScreen> createState() =>
      _SavedJobsScreenState();
}

class _SavedJobsScreenState
    extends State<SavedJobsScreen> {

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>()
        .loadSavedJobs(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [

            /// ================= MODERN GRADIENT HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color:
                          Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Saved Jobs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  /// COUNT BADGE (UI ONLY)
                  BlocBuilder<JobsCubit, JobsState>(
                    builder: (context, state) {
                      if (state is SavedJobsLoaded) {
                        return Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.2),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${state.jobs.length} Saved",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= LIST =================
            Expanded(
              child: BlocBuilder<JobsCubit, JobsState>(
                builder: (context, state) {

                  if (state is JobsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is SavedJobsLoaded) {

                    if (state.jobs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No saved jobs",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 20),
                      itemCount: state.jobs.length,
                      itemBuilder: (context, index) {
                        final job = state.jobs[index];
                        return _modernJobCard(job);
                      },
                    );
                  }

                  if (state is JobsFailure) {
                    return Center(
                        child: Text(state.message));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= MODERN JOB CARD (UI ONLY) =================
  Widget _modernJobCard(Map job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          /// JOB NAME + ICON
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF1FA463)
                      .withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bookmark,
                  color: Color(0xFF1FA463),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  job["jobName"] ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// LOCATION
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                job["location"] ?? "",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// SAVED DATE
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                "Saved ${job["savedDate"]}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// APPLY BUTTON (GRADIENT BRAND)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1FA463),
                    Color(0xFF159957),
                  ],
                ),
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  // نفس اللوجيك بتاعك بدون تغيير
                },
                child: const Text(
                  "Apply Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}