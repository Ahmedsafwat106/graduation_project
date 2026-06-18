import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';
import '../features/chat/ChatCubit.dart';
import '../features/chat/ChatState.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import 'JobListScreen.dart';

class DeveloperDashboardScreen extends StatefulWidget {
  const DeveloperDashboardScreen({super.key});

  @override
  State<DeveloperDashboardScreen> createState() =>
      _DeveloperDashboardScreenState();
}

class _DeveloperDashboardScreenState
    extends State<DeveloperDashboardScreen> {

  Map<String, dynamic> _counts = {
    "applied": 0,
    "messages": 0,
    "interview": 0,
  };

  @override
  void initState() {
    super.initState();

    final cubit = context.read<JobsCubit>();

    if (cubit.cachedAllJobs.isEmpty) {
      cubit.loadDeveloperDashboard();
    }

    context.read<JobsCubit>().connectJobHub();

    context.read<ChatCubit>().stream.listen((state) {
      if (state is MessageCountUpdated) {
        if (mounted) {
          setState(() {
            _counts["messages"] = state.newCount;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomIcon(Icons.person, () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString("token") ?? "";
                if (token.isEmpty) return;

                final api = ApiService();
                final data = await api.getUserData(token);

                Navigator.pushNamed(
                  context,
                  "/edit-profile",
                  arguments: data,
                );
              }),
              _bottomIcon(Icons.chat_bubble_outline,
                      () => Navigator.pushNamed(context, "/chats")),
              _bottomIcon(Icons.favorite_border, () async {
                final prefs = await SharedPreferences.getInstance();
                int? userId = prefs.getInt("userId");

                if (userId == null) {
                  final token = prefs.getString("token") ?? "";
                  if (token.isNotEmpty) {
                    try {
                      final parts = token.split(".");
                      if (parts.length == 3) {
                        String payload = parts[1];
                        while (payload.length % 4 != 0) payload += "=";
                        final decoded = jsonDecode(
                          utf8.decode(base64Url.decode(payload)),
                        );

                        final sub = decoded[
                        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
                        ];
                        if (sub != null) {
                          userId = int.tryParse(sub.toString());

                          if (userId != null) {
                            await prefs.setInt("userId", userId);
                          }
                        }
                      }
                    } catch (e) {
                      print("❌ Token parse error: $e");
                    }
                  }
                }

                print("👤 final userId => $userId");

                if (userId != null) {
                  Navigator.pushNamed(context, "/saved-jobs", arguments: userId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please login again")),
                  );
                }
              }),
              _bottomIcon(Icons.history,
                      () => Navigator.pushNamed(context, "/my-applications")),
              _bottomIcon(Icons.account_circle_outlined, () {
                _showAccountSheet(context);
              }),
            ],
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 45, 20, 25),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [

                        const CircleAvatar(
                          radius: 26,
                          backgroundImage: AssetImage("assets/images/icon.png"),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Text(
                            "Welcome back 👋",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, "/notifications"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: () {
                        final jobsState = context.read<JobsCubit>().state;
                        List jobs = [];
                        if (jobsState is DeveloperDashboardLoaded) {
                          jobs = jobsState.jobs;
                        } else if (jobsState is JobsLoaded) {
                          jobs = jobsState.jobs;
                        }
                        Navigator.pushNamed(
                          context,
                          "/SearchJobsScreen",
                          arguments: jobs,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                            Text(
                              "Search jobs, companies...",
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              BlocBuilder<JobsCubit, JobsState>(
                buildWhen: (previous, current) {

                  return current is DeveloperDashboardLoaded ||
                      current is DeveloperApplyCountUpdated ||
                      current is StatusUpdatedForDeveloper ||
                      current is MessageCountUpdated;
                },
                builder: (context, state) {
                  if (state is DeveloperDashboardLoaded) {
                    _counts = Map<String, dynamic>.from(state.counts);
                  }
                  if (state is DeveloperApplyCountUpdated) {
                    _counts = Map<String, dynamic>.from(_counts);
                    _counts["applied"] = state.applyCount;
                  }
                  if (state is StatusUpdatedForDeveloper) {
                    _counts = Map<String, dynamic>.from(_counts);
                    _counts["interview"] = state.countInterview;
                  }

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _modernCountCard(_counts["applied"] ?? 0, "Applied"),
                            _modernCountCard(_counts["messages"] ?? 0, "Messages"),
                            _modernCountCard(_counts["interview"] ?? 0, "Interviews"),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Explore Opportunities",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const TabBar(
                            indicatorColor: AppColors.primary,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(text: "All Jobs"),
                              Tab(text: "Recommended"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Expanded(
                child: TabBarView(
                  children: [
                    JobListScreen(loadType: JobLoadType.all),
                    JobListScreen(loadType: JobLoadType.recommended),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernCountCard(int number, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _bottomIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: AppColors.primary, size: 26),
      onPressed: onTap,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  await prefs.setString("userName", nextAcc["name"] ?? "");
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