import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import 'ApplyJobScreen.dart';

enum JobLoadType { all, recommended }

class JobListScreen extends StatefulWidget {
  final JobLoadType loadType;

  const JobListScreen({
    super.key,
    required this.loadType,
  });

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.loadType == JobLoadType.all) {
      context.read<JobsCubit>().loadJobs();

    } else {
      context.read<JobsCubit>().loadRecommendedJobs();

    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsCubit, JobsState>(
      builder: (context, state) {
        if (state is JobsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobsLoaded){

          if (state.jobs.isEmpty) {
            return const Center(child: Text("No jobs available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.jobs.length,
            itemBuilder: (context, index) {
              final job = state.jobs[index];
              return _jobCard(context, job);
            },
          );
        }

        if (state is JobsFailure) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }

  Widget _jobCard(BuildContext context, Map job) {
    final int? jobId =
        job["id"] ??
            job["jobId"] ??
            job["job_id"];

    final bool canApply = jobId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job["title"] ?? "",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            job["company_name"] ??
                job["companyName"] ??
                "Unknown Company",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Text(
            job["description"] ??
                job["desctiption"] ??
                "",

            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          Text("📍 Location: ${job["location"] ?? "N/A"}"),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canApply ? Colors.green : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: canApply
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyJobScreen(job: job),
                  ),
                );
              }
                  : null,
              child: Text(
                canApply ? "Apply" : "External Job",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}