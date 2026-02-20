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
    context.read<ApplicationsCubit>()
        .loadApplicantHistoryScreen();
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
        child: BlocBuilder<ApplicationsCubit,
            ApplicationsState>(
          builder: (context, state) {

            if (state is ApplicationsLoading) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (state is ApplicantHistoryScreenLoaded) {

              final history = state.history;
              final counts = state.counts;

              return Column(
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
                              icon: const Icon(
                                  Icons.arrow_back,
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
                        Container(
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
                                  counts["totalApplied"] ?? 0,
                                  "Total Applied",
                                  Colors.black),
                              _countItem(
                                  counts["interview"] ?? 0,
                                  "Interview",
                                  Colors.green),
                              _countItem(
                                  counts["waiting"] ?? 0,
                                  "Waiting",
                                  Colors.orange),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ================= LIST =================
                  Expanded(
                    child: history.isEmpty
                        ? const Center(
                        child: Text(
                            "No applications yet"))
                        : ListView.builder(
                      padding:
                      const EdgeInsets.all(16),
                      itemCount: history.length,
                      itemBuilder:
                          (context, index) {

                        final app =
                        history[index];

                        return _applicationCard(app);
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is ApplicationsFailure) {
              return Center(
                  child: Text(state.message));
            }

            return const SizedBox();
          },
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

    final rawStatus = app["jobStatus"] ?? "New";

    // 👇 نحول New إلى Waiting
    final status =
    rawStatus == "New" ? "Waiting" : rawStatus;

    final statusColor =
    _getStatusColor(status);

    return Container(
      margin:
      const EdgeInsets.only(bottom: 18),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color:
                  Colors.green.withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  app["jobName"] ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor
                      .withOpacity(0.12),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "Applied on ${app["applyDate"] ?? ""}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}