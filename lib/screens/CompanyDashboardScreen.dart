import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import '../widgets/loading_indicator.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() =>
      _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {

  Map<String, dynamic> _counts = {};
  List _jobs = [];

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadCompanyDashboard();
    context.read<JobsCubit>().connectJobHub();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: BlocBuilder<JobsCubit, JobsState>(
          builder: (context, state) {

            if (state is JobsLoading && _counts.isEmpty) {
              const LoadingIndicator();
            }

            if (state is CompanyDashboardLoaded) {
              _counts = Map<String, dynamic>.from(state.counts);
              _jobs = state.jobs;
            }

            if (state is CompanyApplyCountUpdated) {
              _counts = Map<String, dynamic>.from(_counts);
              _counts["applicants"] = state.applyCount;
            }
            if (state is ActiveJobsUpdated) {
              _counts = Map<String, dynamic>.from(_counts);
              _counts["activeJob"] = state.active;
            }

            if (state is StatusUpdatedForCompany) {
              _counts = Map<String, dynamic>.from(_counts);
              _counts["applicants"] = state.countNew +
                  state.countInterview +
                  state.countAccepted +
                  state.countRejected;
            }

            if (state is JobsFailure) {
              return Center(child: Text(state.message));
            }

            return Column(
              children: [

                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.business, color: Colors.white),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString("token") ?? "";
                            if (token.isEmpty) return;
                            final api = ApiService();
                            final data = await api.getCompanyProfile(token);
                            Navigator.pushNamed(context, "/edit-company",
                                arguments: data);
                          },
                        ),
                      ),

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome back 👋",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "TechCorp",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.account_circle_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () => _showAccountSheet(context),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, "/notifications");
                                  },
                                  icon: const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _modernStatCard(
                        _counts["activeJob"] ?? 0,
                        "Active Jobs",
                        Icons.work_outline,
                      ),
                      _modernStatCard(
                        _counts["applicants"] ?? 0,
                        "Applicants",
                        Icons.people_outline,
                      ),
                      _modernStatCard(
                        _counts["hires"] ?? 0,
                        "Hires",
                        Icons.person_add_alt_1_outlined,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/add-job");
                        },
                        child: const Text(
                          "+ Post New Job",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      final job = _jobs[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    job["title"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  onSelected: (value) {
                                    if (value == "edit") {
                                      Navigator.pushNamed(
                                        context,
                                        "/edit-job",
                                        arguments: job,
                                      );
                                    }

                                    else if (value == "delete") {
                                      _confirmDelete(context, job["id"]);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: "edit",
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text("Edit"),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: "delete",
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text("Delete"),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Posted ${job["postedDate"] ?? ""}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/company-applicants",
                                    arguments: job["id"],
                                  );
                                },
                                child: const Text(
                                  "View Applicants",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _modernStatCard(int number, String label, IconData icon) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountSheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> accounts =
        prefs.getStringList("saved_accounts") ?? [];

    final currentToken = prefs.getString("token") ?? "";

    String currentEmail = "";
    for (final a in accounts) {
      try {
        final decoded = jsonDecode(a);
        if (decoded["token"] == currentToken) {
          currentEmail = decoded["email"];
          break;
        }
      } catch (_) {}
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Accounts",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            ...accounts.map((a) {
              final acc = jsonDecode(a);
              final isActive = acc["email"] == currentEmail;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: acc["role"] == "company"
                      ? Colors.blue.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.15),
                  child: Icon(
                    acc["role"] == "company"
                        ? Icons.business
                        : Icons.person,
                    color: acc["role"] == "company"
                        ? Colors.blue
                        : AppColors.primary,
                  ),
                ),
                title: Text(
                  acc["name"] ?? acc["email"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    acc["role"] == "company" ? "Company" : "Developer"),
                trailing: isActive
                    ? const Icon(Icons.check_circle,
                    color: AppColors.primary)
                    : null,
                onTap: () async {
                  Navigator.pop(context);
                  await prefs.setString("token", acc["token"]);
                  await prefs.setString("role", acc["role"]);
                  await prefs.setString("userName", acc["name"] ?? "");
                  await prefs.setString("appUser", acc["appUser"] ?? "");
                  if (acc["userId"] != null) {
                    await prefs.setInt("userId", acc["userId"]);
                  }
                  if (context.mounted) {
                    if (acc["role"] == "company") {
                      Navigator.pushReplacementNamed(
                          context, "/company-dashboard");
                    } else {
                      Navigator.pushReplacementNamed(
                          context, "/developer-dashboard");
                    }
                  }
                },
              );
            }).toList(),

            const Divider(height: 24),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language, color: Colors.blue),
              ),
              title: const Text("Change Language",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Wrap(
                spacing: 12,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.locale == const Locale('en')
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.setLocale(const Locale('en'));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            "EN",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.locale == const Locale('en')
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: context.locale == const Locale('ar')
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.setLocale(const Locale('ar'));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            "AR",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.locale == const Locale('ar')
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: AppColors.primary),
              ),
              title: const Text("Add Account",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/login");
              },
            ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text("Logout",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                accounts.removeWhere((a) {
                  try {
                    return jsonDecode(a)["email"] == currentEmail;
                  } catch (_) {
                    return false;
                  }
                });
                await prefs.setStringList("saved_accounts", accounts);

                if (accounts.isNotEmpty) {
                  final nextAcc = jsonDecode(accounts.last);
                  await prefs.setString("token", nextAcc["token"]);
                  await prefs.setString("role", nextAcc["role"]);
                  await prefs.setString(
                      "userName", nextAcc["name"] ?? "");
                  if (nextAcc["userId"] != null) {
                    await prefs.setInt("userId", nextAcc["userId"]);
                  }
                  if (context.mounted) {
                    if (nextAcc["role"] == "company") {
                      Navigator.pushReplacementNamed(
                          context, "/company-dashboard");
                    } else {
                      Navigator.pushReplacementNamed(
                          context, "/developer-dashboard");
                    }
                  }
                } else {
                  await prefs.clear();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, "/login");
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

void _confirmDelete(BuildContext context, int jobId) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text("Delete Job"),
      content: const Text("Are you sure you want to delete this job?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<JobsCubit>().deleteJob(jobId);
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}