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

              /// ================= HEADER =================
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1FA463), Color(0xFF159957)],
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

                        /// TOP BAR
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            /// ✅ Welcome Text (مش Expanded)
                            const Text(
                              "Welcome back 👋",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Spacer(),

                            /// ✅ Icons تاخد المساحة المتبقية
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [

                                    _iconButton(Icons.person, () async {
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

                                    _iconButton(Icons.chat_bubble_outline, () {
                                      Navigator.pushNamed(context, "/chats");
                                    }),

                                    _iconButton(Icons.notifications_none, () {
                                      Navigator.pushNamed(context, "/notifications");
                                    }),

                                    _iconButton(Icons.favorite_border, () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      final userId = prefs.getInt("userId");

                                      if (userId != null) {
                                        Navigator.pushNamed(
                                          context,
                                          "/saved-jobs",
                                          arguments: userId,
                                        );
                                      }
                                    }),

                                    _iconButton(Icons.history, () {
                                      Navigator.pushNamed(context, "/my-applications");
                                    }),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// COUNTS CARDS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _modernCountCard(counts["applied"] ?? 0, "Applied"),
                            _modernCountCard(counts["messages"] ?? 0, "Messages"),
                            _modernCountCard(counts["interview"] ?? 0, "Interviews"),
                          ],
                        ),

                        const SizedBox(height: 25),

                        const TabBar(
                          indicatorColor: Colors.white,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
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

              /// ================= TAB VIEW =================
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
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 18),
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}