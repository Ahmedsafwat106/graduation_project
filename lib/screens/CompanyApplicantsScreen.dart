import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/applications/applications_cubit.dart';
import '../features/applications/applications_state..dart';
import '../features/chat/ChatCubit.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import 'ChatDetailsScreen.dart';

class CompanyApplicantsScreen extends StatefulWidget {
  final int jobId;
  const CompanyApplicantsScreen({super.key, required this.jobId});

  @override
  State<CompanyApplicantsScreen> createState() =>
      _CompanyApplicantsScreenState();
}

class _CompanyApplicantsScreenState extends State<CompanyApplicantsScreen> {

  String searchQuery = "";
  int? companyId;
  bool isCompanyLoaded = false;
  int? _loadingUserId;
  final Map<int, String> _statusOverrides = {};

  int? _rtNew;
  int? _rtInterview;
  int? _rtAccepted;
  int? _rtRejected;

  @override
  void initState() {
    super.initState();
    _loadCompanyIdFromPrefs();
    context.read<ApplicationsCubit>().loadApplicantsScreen(widget.jobId);
    context.read<JobsCubit>().connectJobHub();
  }

  Future<void> _loadCompanyIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    companyId = prefs.getInt("userId");
    setState(() => isCompanyLoaded = true);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "New":
        return Colors.blue;
      case "Reviewed":
        return Colors.orange;
      case "Interview":
        return const Color(0xFF1FA463);
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: BlocListener<JobsCubit, JobsState>(
          listener: (context, state) {
            if (state is StatusUpdatedForCompany) {
              setState(() {
                _rtNew = state.countNew;
                _rtInterview = state.countInterview;
                _rtAccepted = state.countAccepted;
                _rtRejected = state.countRejected;
              });
            }
          },
          child: Column(
            children: [

              Container(
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

                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Applicants",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

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
                        onChanged: (value) {
                          setState(() => searchQuery = value.toLowerCase());
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search, color: Color(0xFF1FA463)),
                          hintText: "Search applicants...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    BlocBuilder<ApplicationsCubit, ApplicationsState>(
                      builder: (context, state) {
                        if (state is ApplicantsScreenLoaded) {
                          final c = state.counts;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _countItem(
                                  c["totalApplicant"] ?? 0,
                                  "Total",
                                  Colors.black,
                                ),
                                _countItem(
                                  _rtNew ?? c["totalNew"] ?? 0,
                                  "New",
                                  Colors.blue,
                                ),
                                _countItem(
                                  _rtInterview ?? c["totalInterview"] ?? 0,
                                  "Interview",
                                  const Color(0xFF1FA463),
                                ),
                                _countItem(
                                  _rtAccepted ?? c["totalReviewed"] ?? 0,
                                  "Reviewed",
                                  Colors.orange,
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: BlocBuilder<ApplicationsCubit, ApplicationsState>(
                  builder: (context, state) {

                    if (state is ApplicationsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ApplicantsScreenLoaded) {
                      final filtered = state.applicants
                          .where((user) => (user["name"] ?? "")
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery))
                          .toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.people_outline,
                                  size: 60, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                "No applicants yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "No one has applied for this job yet",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _modernApplicantCard(filtered[index]);
                        },
                      );
                    }

                    if (state is ApplicationsFailure) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countItem(int number, String label, Color color) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _modernApplicantCard(Map user) {
    final int userId = user["userId"] ?? 0;
    final String status =
        _statusOverrides[userId] ?? user["status"] ?? "New";
    final Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  user["name"] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FA463).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${user["matchScore"] ?? 0}%",
                  style: const TextStyle(
                    color: Color(0xFF1FA463),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "${user["yearOfex"] ?? 0} years experience",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (user["skillName"] as List?)
                ?.map(
                  (skill) => Chip(
                label: Text(skill),
                backgroundColor: const Color(0xFFF4F7F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
                .toList() ??
                [],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: status,
                iconEnabledColor: statusColor,
                items: const [
                  DropdownMenuItem(value: "New", child: Text("New")),
                  DropdownMenuItem(
                      value: "Reviewed", child: Text("Reviewed")),
                  DropdownMenuItem(
                      value: "Interview", child: Text("Interview")),
                  DropdownMenuItem(
                      value: "Rejected", child: Text("Rejected")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _statusOverrides[userId] = value;
                    });
                    context.read<ApplicationsCubit>().updateStatus(
                      widget.jobId,
                      userId,
                      value,
                    );
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1FA463), Color(0xFF159957)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.25),
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _loadingUserId == userId
                    ? null
                    : () async {

                  setState(() => _loadingUserId = userId);

                  final chatCubit = context.read<ChatCubit>();
                  final prefs = await SharedPreferences.getInstance();

                  if (!isCompanyLoaded ||
                      companyId == null ||
                      userId == 0) {
                    setState(() => _loadingUserId = null);
                    return;
                  }

                  final key = "conversation_${widget.jobId}_$userId";
                  int? convoId = prefs.getInt(key);

                  if (convoId == null) {
                    convoId = await chatCubit.startConversation(
                      userId,
                      widget.jobId,
                      companyId!,
                    );

                    if (convoId != null) {
                      await prefs.setInt(key, convoId);
                    }
                  }

                  setState(() => _loadingUserId = null);

                  if (convoId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to start chat"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatDetailsScreen(
                        conversationId: convoId!,
                      ),
                    ),
                  );
                },
                child: _loadingUserId == userId
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Start Chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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