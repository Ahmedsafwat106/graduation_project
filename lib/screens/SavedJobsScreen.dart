import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import '../widgets/shimmer_widgets.dart';
import 'ApplyJobScreen.dart';

class SavedJobsScreen extends StatefulWidget {
  final int userId;

  const SavedJobsScreen({super.key, required this.userId});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List _cachedJobs = [];

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadSavedJobs(widget.userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Saved Jobs",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<JobsCubit, JobsState>(
                        builder: (context, state) {
                          final count = state is SavedJobsLoaded
                              ? state.jobs.length
                              : _cachedJobs.length;
                          if (count == 0) return const SizedBox();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$count Saved",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _isSearching = value.trim().isNotEmpty);
                        if (value.trim().isEmpty) {
                          context.read<JobsCubit>().loadSavedJobs(widget.userId);
                        } else {
                          context.read<JobsCubit>().searchSavedJobs(value);
                        }
                      },
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search, color: Color(0xFF1FA463)),
                        hintText: "Search saved jobs...",
                        border: InputBorder.none,
                        suffixIcon: _isSearching
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _isSearching = false);
                            context.read<JobsCubit>().loadSavedJobs(widget.userId);
                          },
                        )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<JobsCubit, JobsState>(
                builder: (context, state) {

                  if (state is JobsLoading && _cachedJobs.isEmpty) {
                    return const ShimmerList(card: ShimmerJobCard());
                  }

                  if (state is JobsLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 5,
                      itemBuilder: (_, __) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }

                  if (state is SavedJobsLoaded) {
                    _cachedJobs = state.jobs;
                  }

                  if (state is JobsFailure && _cachedJobs.isEmpty) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (_cachedJobs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_border,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            _isSearching ? "No results found" : "No saved jobs yet",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isSearching
                                ? "Try a different search"
                                : "Start saving jobs to see them here",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF1FA463),
                    onRefresh: () async {
                      _searchController.clear();
                      setState(() => _isSearching = false);
                      context.read<JobsCubit>().loadSavedJobs(widget.userId);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: _cachedJobs.length,
                        itemBuilder: (context, index) {
                          return _modernJobCard(_cachedJobs[index], index);
                        }
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernJobCard(Map job, int index) {

    final String name = job["jobName"] ?? job["title"] ?? "";
    final String location = job["location"] ?? "";
    final String savedDate = job["savedDate"] ?? "";
    final List skills = job["skills"] ?? [];

    bool isSaved = true;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.green : Colors.grey,
                ),
                onPressed: () async {

                  final cubit = context.read<JobsCubit>();

                  setState(() {
                    _cachedJobs.removeAt(index);
                  });

                  cubit.saveJob(
                    widget.userId,
                    job["jobId"] ?? job["id"],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                location,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),

          if (savedDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  "Saved $savedDate",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],

          if (skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills
                  .toSet()
                  .take(4)
                  .map((s) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FA463).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  s.toString(),
                  style: const TextStyle(
                    color: Color(0xFF1FA463),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1FA463), Color(0xFF159957)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplyJobScreen(job: job),
                      ),
                    );
                  },
                  child: const Center(
                    child: Text(
                      "Apply Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}