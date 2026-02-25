import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadDeveloperDashboard();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),

        body: SafeArea(
          child: Column(
            children: [

              // ================= HEADER + COUNTS =================
              BlocBuilder<JobsCubit, JobsState>(
                builder: (context, state) {

                  Map<String, dynamic> counts = {
                    "applied": 0,
                    "messages": 0,
                    "interview": 0,
                  };

                  if (state is DeveloperDashboardLoaded) {
                    counts = state.counts;
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        // 🔔 Top Row
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [

                            const Text(
                              "Welcome back 👋",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:8,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            Row(
                              children: [


                                // 👤 Edit Profile
                                IconButton(
                                  icon: const Icon(Icons.person, color: Colors.white),
                                  onPressed: () async {

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
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat, color: Colors.white),
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/developer-chats");
                                  },
                                ),

                                // 🔔 Notifications
                                IconButton(
                                  icon: const Icon(Icons.notifications, color: Colors.white),
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/notifications");
                                  },
                                ),

                                // ❤️ Saved Jobs
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    final userId = prefs.getInt("userId");
                                    final token = prefs.getString("token");

                                    print("======== DEBUG SAVED JOBS ========");
                                    print("USER ID => $userId");
                                    print("TOKEN => $token");
                                    print("==================================");

                                    if (userId != null) {
                                      Navigator.pushNamed(
                                        context,
                                        "/saved-jobs",
                                        arguments: userId,
                                      );
                                    } else {
                                      print("❌ USER ID IS NULL");
                                    }
                                  },
                                ),

                                // 📜 Application History
                                IconButton(
                                  icon: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context,
                                        "/my-applications");
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ================= COUNTS =================
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [

                            _countCard(
                                counts["applied"] ?? 0,
                                "Applied"),

                            _countCard(
                                counts["messages"] ?? 0,
                                "Messages"),

                            _countCard(
                                counts["interview"] ?? 0,
                                "Interviews"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ================= TAB BAR =================
                        const TabBar(
                          indicatorColor: Colors.white,
                          tabs: [
                            Tab(text: "All Jobs"),
                            Tab(text: "Recommended"),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ================= TAB VIEW =================
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

  Widget _countCard(int number, String label) {
    return Container(
      width: 95,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}