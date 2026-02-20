import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/applications/applications_cubit.dart';
import '../features/applications/applications_state..dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState
    extends State<MyApplicationsScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ApplicationsCubit>().loadMyApplications();
    context.read<ApplicationsCubit>().loadApplicantHistoryCount();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Interview":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Waiting":
        return Colors.orange;
      default:
        return Colors.blue;
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Application History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= COUNTS =================
                  BlocBuilder<ApplicationsCubit,
                      ApplicationsState>(
                    builder: (context, state) {

                      if (state
                      is ApplicantHistoryCountLoaded) {

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
                            MainAxisAlignment
                                .spaceAround,
                            children: [
                              _countItem(
                                  c["totalApplied"] ?? 0,
                                  "Total Applied",
                                  Colors.black),
                              _countItem(
                                  c["interview"] ?? 0,
                                  "Interview",
                                  Colors.green),
                              _countItem(
                                  c["waiting"] ?? 0,
                                  "Waiting",
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

                  if (state is ApplicationsLoaded) {

                    if (state.applications.isEmpty) {
                      return const Center(
                          child:
                          Text("No applications yet"));
                    }

                    return ListView.builder(
                      padding:
                      const EdgeInsets.all(16),
                      itemCount:
                      state.applications.length,
                      itemBuilder:
                          (context, index) {

                        final app =
                        state.applications[index];

                        return _applicationCard(app);
                      },
                    );
                  }

                  if (state is ApplicationsFailure) {
                    return Center(
                        child:
                        Text(state.message));
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

  // ================= COUNT ITEM =================
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
              fontWeight:
              FontWeight.bold,
              color: color),
        ),
        Text(label),
      ],
    );
  }

  // ================= APPLICATION CARD =================
  Widget _applicationCard(Map app) {

    final status = app["status"] ?? "Waiting";
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TOP ROW =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔹 Icon Container
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 12),

              // 🔹 Title + Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app["jobTitle"] ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app["companyName"] ?? "",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(height: 1),

          const SizedBox(height: 12),

          // ================= BOTTOM ROW =================
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [

              // 🔹 Applied Date
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    "Applied on ${app["appliedDate"] ?? ""}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // 🔹 View Details
              GestureDetector(
                onTap: () {
                  // تقدر تفتح صفحة تفاصيل هنا
                },
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
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