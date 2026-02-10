import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class CompanyApplicantsScreen extends StatefulWidget {
  final int jobId;
  const CompanyApplicantsScreen({super.key, required this.jobId});

  @override
  State<CompanyApplicantsScreen> createState() =>
      _CompanyApplicantsScreenState();
}

class _CompanyApplicantsScreenState extends State<CompanyApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().loadJobApplicants(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Applicants"),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApplicantsLoaded) {
            if (state.applicants.isEmpty) {
              return const Center(child: Text("No applicants yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.applicants.length,
              itemBuilder: (context, index) {
                final user = state.applicants[index];
                return _applicantCard(user);
              },
            );
          }

          if (state is AuthFailure) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _applicantCard(Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user["fullName"] ?? "No Name",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(user["email"] ?? "No Email"),
          const SizedBox(height: 6),
          Text(
            "Status: ${user["status"] ?? "Pending"}",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
