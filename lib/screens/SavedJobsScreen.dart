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

            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Saved Jobs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  BlocBuilder<JobsCubit, JobsState>(
                    builder: (context, state) {

                      if (state is SavedJobsLoaded) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6),
                          decoration: BoxDecoration(
                            color:
                            Colors.white.withOpacity(0.2),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${state.jobs.length} save",
                            style: const TextStyle(
                                color: Colors.white),
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

            // ================= LIST =================
            Expanded(
              child: BlocBuilder<JobsCubit, JobsState>(
                builder: (context, state) {

                  if (state is JobsLoading) {
                    return const Center(
                        child:
                        CircularProgressIndicator());
                  }

                  if (state is SavedJobsLoaded) {

                    if (state.jobs.isEmpty) {
                      return const Center(
                          child:
                          Text("No saved jobs"));
                    }

                    return ListView.builder(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 16),
                      itemCount: state.jobs.length,
                      itemBuilder:
                          (context, index) {

                        final job =
                        state.jobs[index];

                        return _jobCard(job);
                      },
                    );
                  }

                  if (state is JobsFailure) {
                    return Center(
                        child:
                        Text(state.message));
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

  Widget _jobCard(Map job) {

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            job["jobName"] ?? "",
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            job["location"] ?? "",
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Saved ${job["savedDate"]}",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // تفتح صفحة تفاصيل الوظيفة
              },
              child: const Text("Apply Now"),
            ),
          ),
        ],
      ),
    );
  }
}