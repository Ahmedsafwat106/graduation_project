import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

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
            final jobs = state.jobs;

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: jobs.length,
              itemBuilder: (context, i) {
                final job = jobs[i];
                return _jobCard(job);
              },
            );
          }

          return const Center(
            child: Text("No jobs found!"),
          );
        },
      ),
    );
  }

  Widget _jobCard(job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job["title"],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(job["description"]),
          const SizedBox(height: 6),
          Text("Location: ${job["location"]}"),
          Text("Salary: ${job["salary"]}"),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Apply"),
          )
        ],
      ),
    );
  }
}
