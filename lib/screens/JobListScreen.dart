import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final Set<int> _savedJobIds = {};
  @override
  void initState() {
    super.initState();
    _loadUser();
    if (widget.loadType == JobLoadType.recommended) {
      context.read<JobsCubit>().loadRecommendedJobs();
    } else {
      context.read<JobsCubit>().loadJobs();
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

          Container(
            width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7F6),
            ),
            child: Row(
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Text(
                    "Jobs",
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list,
                        color: Color(0xFF1FA463)),
                    onPressed: () {
                      Navigator.pushNamed(context, "/advanced-filter")
                          .then((_) {
                        if (widget.loadType == JobLoadType.recommended) {
                          context.read<JobsCubit>().loadRecommendedJobs();
                        } else {
                          context.read<JobsCubit>().loadJobs();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<JobsCubit, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (state is JobsLoaded) {
                  print("===== JOBS RESPONSE =====");
                  print(state.jobs);
                  print("=========================");
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
  Widget _modernJobCard(BuildContext context, Map job) {


    int? jobId;
    final rawId = job["job_id"] ?? job["id"] ?? job["jobId"];
    if (rawId is int) {
      jobId = rawId;
    } else if (rawId is String) {
      jobId = int.tryParse(rawId);
    }

    final String title = job["title"] ?? "";
    final String company = job["companyName"] ?? job["company_name"] ?? "";


    final String? externalUrl = job["apply_Link"];

    final bool canApplyInsideApp = jobId != null &&
        (externalUrl == null || externalUrl.isEmpty);
    final bool hasExternalLink = externalUrl != null && externalUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),

              if (canApplyInsideApp)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FA463).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _savedJobIds.contains(jobId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _savedJobIds.contains(jobId)
                          ? Colors.red
                          : const Color(0xFF1FA463),
                    ),
                    onPressed: () {
                      if (userId == null || jobId == null) return;

                      setState(() {
                        if (_savedJobIds.contains(jobId)) {
                          _savedJobIds.remove(jobId);
                        } else {
                          _savedJobIds.add(jobId!);
                        }
                      });

                      context.read<JobsCubit>().saveJob(userId!, jobId!);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _savedJobIds.contains(jobId)
                                ? "Job Saved ✅"
                                : "Job Removed",
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            company.isEmpty ? "Unknown Company" : company,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 12),

          Text(
            job["desctiption"] ?? job["description"] ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(height: 1.5, color: Colors.black87),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                job["location"] ?? "N/A",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FA463).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job["jobType"] ?? "",
                  style: const TextStyle(
                    color: Color(0xFF1FA463),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1FA463),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                if (canApplyInsideApp) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyJobScreen(job: job),
                    ),
                  );
                } else if (hasExternalLink) {

                  final uri = Uri.parse(externalUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Can't open link"),
                      ),
                    );
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasExternalLink) ...[
                    const Icon(Icons.open_in_new,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    canApplyInsideApp ? "Apply Now" : "Apply External",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}