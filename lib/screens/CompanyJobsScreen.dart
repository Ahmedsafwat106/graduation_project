import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';

class CompanyJobsScreen extends StatefulWidget {
  const CompanyJobsScreen({super.key});

  @override
  State<CompanyJobsScreen> createState() => _CompanyJobsScreenState();
}

class _CompanyJobsScreenState extends State<CompanyJobsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadCompanyJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [

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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                    const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Jobs",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Manage your posted jobs",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: BlocBuilder<JobsCubit, JobsState>(
              builder: (context, state) {
                if (state is JobsLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1FA463), strokeWidth: 3));
                }

                if (state is JobsLoaded) {
                  if (state.jobs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No jobs yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    itemCount: state.jobs.length,
                    itemBuilder: (context, index) {
                      final job = state.jobs[index];
                      final int? jobId = job["id"];
                      final int count = job["count"] ?? 0;

                      if (jobId == null) {
                        return const SizedBox();
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    job["title"] ?? "",
                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.bold,
                                      color:
                                      Color(0xFF1E1E1E),
                                    ),
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFF1FA463)
                                        .withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(
                                        16),
                                  ),
                                  child: Text(
                                    "$count Applicants",
                                    style:
                                    const TextStyle(
                                      color:
                                      Color(0xFF1FA463),
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    job["location"] ?? "",
                                    style:
                                    const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [

                                _actionButton(
                                  icon: Icons.people_outline,
                                  color: Colors.blue,
                                  label: "Applicants",
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/company-applicants",
                                      arguments: jobId,
                                    );
                                  },
                                ),

                                const SizedBox(width: 10),

                                _actionButton(
                                  icon: Icons.edit_outlined,
                                  color: Colors.orange,
                                  label: "Edit",
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/edit-job",
                                      arguments: job,
                                    );
                                  },
                                ),

                                const SizedBox(width: 10),

                                _actionButton(
                                  icon: Icons.delete_outline,
                                  color: Colors.red,
                                  label: "Delete",
                                  onTap: () {
                                    _confirmDelete(context, jobId);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
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

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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