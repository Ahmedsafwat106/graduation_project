import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import 'ApplyJobScreen.dart';

enum JobLoadType { all, recommended }

class JobListScreen extends StatefulWidget {
  final JobLoadType loadType;

  const JobListScreen({
    super.key,
    required this.loadType,
  });

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUser();

    if (widget.loadType == JobLoadType.all) {
      context.read<JobsCubit>().loadJobs();
    } else {
      context.read<JobsCubit>().loadRecommendedJobs();
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt("userId");

    setState(() {
      userId = storedUserId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [

          /// ================= MODERN HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1FA463),
                  Color(0xFF159957),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Jobs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, "/advanced-filter")
                          .then((_) {
                        context
                            .read<JobsCubit>()
                            .loadRecommendedJobs();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          /// ================= JOB LIST =================
          Expanded(
            child: BlocBuilder<JobsCubit, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (state is JobsLoaded) {
                  if (state.jobs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No jobs available",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: state.jobs.length,
                    itemBuilder: (context, index) {
                      final job = state.jobs[index];
                      return _modernJobCard(context, job);
                    },
                  );
                }

                if (state is JobsFailure) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= MODERN JOB CARD (UI ONLY) =================
  Widget _modernJobCard(BuildContext context, Map job) {
    final int? jobId =
        job["id"] ?? job["jobId"] ?? job["job_id"];

    final bool canApply = jobId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [

          /// ❤️ Save Button (Modern Floating Style)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1FA463).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Color(0xFF1FA463),
                ),
                onPressed: () {
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User not loaded"),
                      ),
                    );
                    return;
                  }

                  if (jobId == null) return;

                  context.read<JobsCubit>().saveJob(userId!, jobId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Job Saved"),
                    ),
                  );
                },
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// JOB TITLE
              Text(
                job["title"] ?? "",
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),

              const SizedBox(height: 6),

              /// COMPANY NAME
              Text(
                job["company_name"] ??
                    job["companyName"] ??
                    "Unknown Company",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 12),

              /// DESCRIPTION
              Text(
                job["description"] ??
                    job["desctiption"] ??
                    "",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 14),

              /// LOCATION ROW (MODERN)
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    job["location"] ?? "N/A",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// APPLY BUTTON (GRADIENT BRAND)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: canApply
                          ? const [
                        Color(0xFF1FA463),
                        Color(0xFF159957),
                      ]
                          : [
                        Colors.grey.shade400,
                        Colors.grey.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: canApply
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ApplyJobScreen(job: job),
                        ),
                      );
                    }
                        : null,
                    child: Text(
                      canApply ? "Apply Now" : "External Job",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}