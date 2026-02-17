import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/applications/applications_cubit.dart';
import '../features/applications/applications_state..dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ApplicationsCubit>().loadMyApplications();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Applications"),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<ApplicationsCubit, ApplicationsState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApplicationsLoaded) {
            if (state.applications.isEmpty) {
              return const Center(child: Text("No applications yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.applications.length,
              itemBuilder: (context, index) {
                final app = state.applications[index];
                return _applicationCard(app);
              },
            );
          }

          if (state is ApplicationsFailure) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _applicationCard(Map app) {
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
            app["jobTitle"] ?? "",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(app["companyName"] ?? ""),
          const SizedBox(height: 8),
          Text("Status: ${app["status"] ?? "Pending"}"),
        ],
      ),
    );
  }
}