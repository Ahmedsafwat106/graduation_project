import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';

class CompanyJobsScreen extends StatefulWidget {
  const CompanyJobsScreen({super.key});

  @override
  State<CompanyJobsScreen> createState() => _CompanyJobsScreenState();
}

class _CompanyJobsScreenState extends State<CompanyJobsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadCompanyJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Jobs"),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<JobsCubit, JobsState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JobsLoaded) {
            if (state.jobs.isEmpty) {
              return const Center(child: Text("No jobs yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                final job = state.jobs[index];
                final int? jobId = job["id"];
                final int count = job["count"] ?? 0;

                if (jobId == null) {
                  return const SizedBox();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(job["title"] ?? ""),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job["location"] ?? ""),
                        const SizedBox(height: 4),
                        Text(
                          "$count Applicants",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // 👥 Applicants
                        IconButton(
                          icon: const Icon(Icons.people, color: Colors.blue),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/company-applicants", // ✅ الصح
                              arguments: jobId,
                            );
                          },
                        ),

                        // ✏️ Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/edit-job",
                              arguments: job,
                            );
                          },
                        ),

                        // 🗑 Delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<JobsCubit>().deleteJob(jobId);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is JobsFailure) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
