import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class ApplyJobScreen extends StatelessWidget {
  final Map job;
  const ApplyJobScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final int? jobId = job["id"] is int
        ? job["id"]
        : int.tryParse(job["id"]?.toString() ?? "");

    if (jobId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Apply Job"),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Text(
            "Invalid Job ID",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply Job"),
        backgroundColor: Colors.green,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.message == "JOB_APPLIED") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Applied successfully ✅")),
            );
            Navigator.pop(context);
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job["title"] ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(job["description"] ?? ""),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                      context.read<AuthCubit>().applyJob(jobId);
                    },
                    child: state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Confirm Apply",
                      style: TextStyle(color: Colors.white),
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
