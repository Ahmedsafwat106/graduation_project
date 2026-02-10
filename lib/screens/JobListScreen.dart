import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import 'ApplyJobScreen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Jobs"),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JobsLoaded) {
            if (state.jobs.isEmpty) {
              return const Center(child: Text("No jobs available"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.jobs.length,
              itemBuilder: (context, index) {
                final job = state.jobs[index];

                // ✅ اطبع شكل الـ job الحقيقي اللي جاي من الباك
                print("JOB FROM API => $job");

                return _jobCard(job);
              },
            );
          }

          if (state is AuthFailure) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text("Something went wrong"));
        },
      ),
    );
  }

  Widget _jobCard(Map job) {
    final extensions = job["detected_extensions"] ?? {};

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
            job["company_name"] ?? "Unknown Company",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Text(job["description"] ?? ""),

          const SizedBox(height: 10),

          Text("📍 Location: ${job["location"] ?? "N/A"}"),
          Text("💼 Type: ${extensions["schedule_type"] ?? "N/A"}"),
          Text("💰 Salary: ${job["salary"] ?? "Not specified"}"),
          Text("🕒 Posted: ${extensions["posted_at"] ?? ""}"),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyJobScreen(job: job),
                  ),
                );
              },
              child: const Text(
                "Apply",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
