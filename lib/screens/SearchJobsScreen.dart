import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import '../widgets/loading_indicator.dart';
import 'ApplyJobScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchJobsScreen extends StatefulWidget {
  final List jobs;
  const SearchJobsScreen({super.key, required this.jobs});

  @override
  State<SearchJobsScreen> createState() => _SearchJobsScreenState();
}

class _SearchJobsScreenState extends State<SearchJobsScreen> {
  List _displayedJobs = [];
  List<String> recentSearches = [];
  String query = "";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _displayedJobs = widget.jobs;
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList("recent_searches") ?? [];
    });
  }

  Future<void> _saveRecent(String value) async {
    if (value.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    recentSearches.remove(value);
    recentSearches.insert(0, value);
    if (recentSearches.length > 10) {
      recentSearches = recentSearches.sublist(0, 10);
    }
    await prefs.setStringList("recent_searches", recentSearches);
    setState(() {});
  }

  void _onSearch(String value) {
    setState(() {
      query = value;
      _isSearching = value.trim().isNotEmpty;
    });

    if (value.trim().isEmpty) {
      setState(() => _displayedJobs = widget.jobs);
      return;
    }

    context.read<JobsCubit>().searchJobs(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          autofocus: true,
          onChanged: _onSearch,
          onSubmitted: (value) => _saveRecent(value),
          decoration: const InputDecoration(
            hintText: "Search jobs...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: AppColors.primaryDark),
        ),
      ),
      body: Column(
        children: [
          if (!_isSearching && recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Searches",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove("recent_searches");
                          setState(() => recentSearches = []);
                        },
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: recentSearches.map((text) {
                      return ActionChip(
                        label: Text(text),
                        avatar: const Icon(Icons.history, size: 16),
                        onPressed: () {
                          _onSearch(text);
                          _saveRecent(text);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

          Expanded(
            child: BlocBuilder<JobsCubit, JobsState>(
              builder: (context, state) {
                if (_isSearching && state is JobsLoading) {
                  const LoadingIndicator();
                }

                if (_isSearching && state is JobsLoaded) {
                  _displayedJobs = state.jobs;
                }

                if (_isSearching && state is JobsFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (_displayedJobs.isEmpty) {
                  return Center(
                    child: Text(
                      _isSearching
                          ? "No jobs found"
                          : "No jobs available",
                      style: const TextStyle(
                          fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    key: ValueKey(_displayedJobs.length),
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayedJobs.length,
                    itemBuilder: (context, index) {
                      return _jobCard(context, _displayedJobs[index]);
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

  Widget _jobCard(BuildContext context, Map job) {
    int? jobId;
    final rawId = job["job_id"] ?? job["id"] ?? job["jobId"];
    if (rawId is int) jobId = rawId;
    else if (rawId is String) jobId = int.tryParse(rawId);

    final String? externalUrl = job["apply_Link"];
    final bool canApplyInsideApp =
        jobId != null && (externalUrl == null || externalUrl.isEmpty);
    final bool hasExternalLink =
        externalUrl != null && externalUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job["title"] ?? "Unknown Job",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job["companyName"] ??
                          job["company_name"] ??
                          "Unknown Company",
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                job["location"] ?? "N/A",
                style:
                const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  job["jobType"] ?? "",
                  style: const TextStyle(
                    color: AppColors.primary,
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
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  if (canApplyInsideApp) {
                    _saveRecent(query);
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
                          uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasExternalLink) ...[
                      const Icon(Icons.open_in_new,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      canApplyInsideApp ? "Apply Now" : "Apply External",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}