import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import '../widgets/shimmer_widgets.dart';
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

class _JobListScreenState extends State<JobListScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  int? userId;
  final Set<int> _savedJobIds = {};
  List _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadUser();

    final cubit = context.read<JobsCubit>();

    if (widget.loadType == JobLoadType.recommended) {
      if (cubit.cachedRecommendedJobs.isNotEmpty) {
        setState(() => _jobs = cubit.cachedRecommendedJobs);
      } else {
        cubit.loadRecommendedJobs();
      }
    } else {
      if (cubit.cachedAllJobs.isNotEmpty) {
        setState(() => _jobs = cubit.cachedAllJobs);
      } else {
        cubit.loadJobs();
      }
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("userId");
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                  child: Text(
                    widget.loadType == JobLoadType.all
                        ? "All Jobs"
                        : "Recommended",
                    style: const TextStyle(
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
                          context
                              .read<JobsCubit>()
                              .loadRecommendedJobs(forceRefresh: true);
                        } else {
                          context
                              .read<JobsCubit>()
                              .loadJobs(forceRefresh: true);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocConsumer<JobsCubit, JobsState>(

              listenWhen: (previous, current) {
                if (widget.loadType == JobLoadType.all) {
                  return current is AllJobsLoaded || current is JobsFailure;
                } else {
                  return current is RecommendedJobsLoaded ||
                      current is JobsFailure;
                }
              },
              listener: (context, state) {
                if (widget.loadType == JobLoadType.all &&
                    state is AllJobsLoaded) {
                  setState(() => _jobs = state.jobs);
                } else if (widget.loadType == JobLoadType.recommended &&
                    state is RecommendedJobsLoaded) {
                  setState(() => _jobs = state.jobs);
                }
              },
              buildWhen: (previous, current) {
                return current is JobsLoading ||
                    current is JobsFailure ||
                    (widget.loadType == JobLoadType.all &&
                        current is AllJobsLoaded) ||
                    (widget.loadType == JobLoadType.recommended &&
                        current is RecommendedJobsLoaded);
              },
              builder: (context, state) {
                if (state is JobsLoading && _jobs.isEmpty) {
                  return const ShimmerList(card: ShimmerJobCard());
                }

                if (state is JobsFailure && _jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1FA463),
                          ),
                          onPressed: () {
                            if (widget.loadType == JobLoadType.recommended) {
                              context
                                  .read<JobsCubit>()
                                  .loadRecommendedJobs(forceRefresh: true);
                            } else {
                              context
                                  .read<JobsCubit>()
                                  .loadJobs(forceRefresh: true);
                            }
                          },
                          child: const Text("Retry",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                if (_jobs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No jobs available",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFF1FA463),
                  onRefresh: () async {
                    if (widget.loadType == JobLoadType.recommended) {
                      await context
                          .read<JobsCubit>()
                          .loadRecommendedJobs(forceRefresh: true);
                    } else {
                      await context
                          .read<JobsCubit>()
                          .loadJobs(forceRefresh: true);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      return _modernJobCard(context, _jobs[index]);
                    },
                  ),
                );
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
    final String company =
        job["companyName"] ?? job["company_name"] ?? "";
    final String? externalUrl = job["apply_Link"];
    final bool canApplyInsideApp =
        jobId != null && (externalUrl == null || externalUrl.isEmpty);
    final bool hasExternalLink =
        externalUrl != null && externalUrl.isNotEmpty;

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

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1FA463).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _savedJobIds.contains(jobId)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: const Color(0xFF1FA463),
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
                              : "Job Removed 🗑️",
                        ),
                        duration: const Duration(seconds: 1),
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
              Expanded(
                child: Text(
                  job["location"] ?? "N/A",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

          if (job["source"] != null && job["source"].toString().isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link, size: 11, color: Colors.blue),
                  const SizedBox(width: 3),
                  Text(
                    job["source"].toString(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (widget.loadType == JobLoadType.recommended &&
              job["matchScore"] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Match: ${job["matchScore"]}%",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

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
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Can't open link")),
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