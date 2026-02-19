import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/applications/applications_cubit.dart';
import '../features/applications/applications_state..dart';

class CompanyApplicantsScreen extends StatefulWidget {
  final int jobId;
  const CompanyApplicantsScreen({super.key, required this.jobId});

  @override
  State<CompanyApplicantsScreen> createState() =>
      _CompanyApplicantsScreenState();
}

class _CompanyApplicantsScreenState
    extends State<CompanyApplicantsScreen> {

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    context
        .read<ApplicationsCubit>()
        .loadApplicantsScreen(widget.jobId);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "New":
        return Colors.blue;
      case "Reviewed":
        return Colors.orange;
      case "Interview":
        return Colors.green;
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
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Applicants",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // SEARCH
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: "Search applicants...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // COUNTS
                  BlocBuilder<ApplicationsCubit,
                      ApplicationsState>(
                    builder: (context, state) {

                      if (state is ApplicantsScreenLoaded) {

                        final c = state.counts;

                        return Container(
                          padding:
                          const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                  color:
                                  Colors.black12,
                                  blurRadius: 5)
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              _countItem(
                                  c["totalApplicant"] ?? 0,
                                  "Total",
                                  Colors.black),
                              _countItem(
                                  c["totalNew"] ?? 0,
                                  "New",
                                  Colors.blue),
                              _countItem(
                                  c["totalInterview"] ?? 0,
                                  "Interview",
                                  Colors.green),
                              _countItem(
                                  c["totalReviewed"] ?? 0,
                                  "Reviewed",
                                  Colors.orange),
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

            // ================= LIST =================
            Expanded(
              child: BlocBuilder<ApplicationsCubit,
                  ApplicationsState>(
                builder: (context, state) {

                  if (state is ApplicationsLoading) {
                    return const Center(
                        child:
                        CircularProgressIndicator());
                  }

                  if (state is ApplicantsScreenLoaded) {

                    final filtered = state.applicants
                        .where((user) =>
                        (user["name"] ?? "")
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery))
                        .toList();

                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text("No applicants found"));
                    }

                    return ListView.builder(
                      padding:
                      const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder:
                          (context, index) {

                        final user = filtered[index];
                        return _applicantCard(user);
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
    );
  }

  Widget _countItem(
      int number,
      String label,
      Color color,
      ) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color),
        ),
        Text(label),
      ],
    );
  }

  Widget _applicantCard(Map user) {

    final status = user["status"] ?? "New";
    final statusColor = _getStatusColor(status);

    return Container(
      margin:
      const EdgeInsets.only(bottom: 16),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user["name"] ?? "No Name",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4),
                decoration:
                BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Text(
                  "${user["matchScore"] ?? 0}%",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "${user["yearOfex"] ?? 0} years experience",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            children:
            (user["skillName"] as List?)
                ?.map((skill) =>
                Chip(
                  label: Text(skill),
                  backgroundColor:
                  Colors.grey.shade100,
                ))
                .toList() ??
                [],
          ),

          const SizedBox(height: 10),

          Text(
            "Applied: ${user["applyDate"] ?? ""}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12),
            decoration:
            BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child:
            DropdownButtonHideUnderline(
              child:
              DropdownButton<String>(
                value: status,
                iconEnabledColor:
                statusColor,
                items: const [
                  DropdownMenuItem(
                      value: "New",
                      child: Text("New")),
                  DropdownMenuItem(
                      value: "Reviewed",
                      child: Text("Reviewed")),
                  DropdownMenuItem(
                      value: "Interview",
                      child: Text("Interview")),
                  DropdownMenuItem(
                      value: "Rejected",
                      child: Text("Rejected")),
                ],
                onChanged:
                    (value) {
                  if (value != null) {
                    context
                        .read<
                        ApplicationsCubit>()
                        .updateStatus(
                      widget.jobId,
                      user["userId"],
                      value,
                    );
                  }
                },
                style: TextStyle(
                  color:
                  statusColor,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
