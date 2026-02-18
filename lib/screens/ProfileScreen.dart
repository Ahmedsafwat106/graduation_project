import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import '../features/profile/profile_cubit.dart';
import '../features/profile/profile_state..dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String role = "developer";

  @override
  void initState() {
    super.initState();
    _loadRole();
    context.read<ProfileCubit>().loadUserProfile();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role") ?? "developer";
    });
  }

  void _openApplicants(BuildContext context) async {
    final jobsCubit = context.read<JobsCubit>();
    await jobsCubit.loadCompanyJobs();

    final state = jobsCubit.state;

    if (state is JobsLoaded && state.jobs.isNotEmpty) {
      final int jobId = state.jobs.first["id"];

      Navigator.pushNamed(
        context,
        "/company-applicants",
        arguments: jobId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No jobs found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {

          // ✅ Loading
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Failure (يعرضلك الخطأ الحقيقي)
          if (state is ProfileFailure) {
            return Center(
              child: Text(state.message),
            );
          }

          // ✅ Success Load
          if (state is ProfileLoaded) {
            final data = state.user;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(Icons.person,
                        size: 55, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  if (role == "company") ...[
                    _info("Company", data["companyName"] ?? ""),
                    _info("Email", data["email"] ?? ""),
                    _info("Phone", data["phone"] ?? "Not set"),
                    _info("City", data["city"] ?? "Not set"),
                    _info("Field", data["field"] ?? "Not set"),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize:
                        const Size(double.infinity, 50),
                      ),
                      onPressed: () => _openApplicants(context),
                      child: const Text(
                        "View Applicants",
                        style:
                        TextStyle(color: Colors.white),
                      ),
                    ),
                  ],

                  if (role == "developer") ...[
                    _info("Name",
                        "${data['firstName'] ?? ""} ${data['lastName'] ?? ""}"),
                    _info("Email", data["email"] ?? ""),
                    _info("Phone", data["phone"] ?? "Not set"),
                    _info("City", data["city"] ?? "Not set"),
                  ],
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _info(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.grey)),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
