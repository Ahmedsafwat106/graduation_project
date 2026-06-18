import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
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
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {

            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
              );
            }
            if (state is ProfileFailure) {
              return Center(child: Text(state.message));
            }

            if (state is ProfileLoaded) {
              final data = state.user;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.fromLTRB(20, 30, 20, 35),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      children: [

                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [

                                const CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 55,
                                    color: AppColors.primary,
                                  ),
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              ],
                            ),

                        const SizedBox(height: 15),

                        Text(
                          role == "company"
                              ? (data["companyName"] ?? "Company")
                              : "${data['firstName'] ?? ""} ${data['lastName'] ?? ""}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          data["email"] ?? "",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [

                          if (role == "company") ...[
                            _modernInfoCard(
                                Icons.business,
                                "Company",
                                data["companyName"] ?? ""),
                            _modernInfoCard(Icons.email,
                                "Email", data["email"] ?? ""),
                            _modernInfoCard(Icons.phone,
                                "Phone",
                                data["phone"] ?? "Not set"),
                            _modernInfoCard(Icons.location_city,
                                "City",
                                data["city"] ?? "Not set"),
                            _modernInfoCard(Icons.work_outline,
                                "Field",
                                data["field"] ?? "Not set"),

                            const SizedBox(height: 25),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withOpacity(0.3),
                                      blurRadius: 18,
                                      offset:
                                      const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.transparent,
                                    shadowColor:
                                    Colors.transparent,
                                  ),
                                  onPressed: () =>
                                      _openApplicants(context),
                                  child: const Text(
                                    "View Applicants",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (role == "developer") ...[
                            _modernInfoCard(
                                Icons.person,
                                "Name",
                                "${data['firstName'] ?? ""} ${data['lastName'] ?? ""}"),
                            _modernInfoCard(Icons.email,
                                "Email", data["email"] ?? ""),
                            _modernInfoCard(Icons.phone,
                                "Phone",
                                data["phone"] ?? "Not set"),
                            _modernInfoCard(Icons.location_city,
                                "City",
                                data["city"] ?? "Not set"),
                          ],

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    ),
    );
  }

  Widget _modernInfoCard(
      IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color:
              AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}