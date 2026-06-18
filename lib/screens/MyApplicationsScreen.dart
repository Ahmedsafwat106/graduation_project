import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/applications/applications_cubit.dart';
import '../features/applications/applications_state..dart';
import '../widgets/shimmer_widgets.dart';

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
    context
        .read<ApplicationsCubit>()
        .loadApplicantHistoryScreen();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Interview":
        return AppColors.primary;
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
              return const ShimmerList(card: ShimmerApplicantCard());
            }

            if (state is ApplicantHistoryScreenLoaded) {

              final history = state.history;
              final counts = state.counts;

              return Column(
                children: [

                  Container(
                    padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
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

                                const SizedBox(width: 10),

                                const Text(
                                  "Application History",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.filter_list,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

            InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {},
            child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),
                                blurRadius: 14,
                                offset:
                                const Offset(0, 6),
                              ),
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
                                Colors.black,
                              ),
                              _countItem(
                                counts["interview"] ?? 0,
                                "Interview",
                                AppColors.primary,
                              ),
                              _countItem(
                                counts["waiting"] ?? 0,
                                "Waiting",
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),
            )
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: history.isEmpty
                        ? const Center(
                      child: Text(
                        "No applications yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding:
                      const EdgeInsets.fromLTRB(
                          16, 4, 16, 20),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final app = history[index];
                        return _modernApplicationCard(app);
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _modernApplicationCard(Map app) {
    final rawStatus = app["jobStatus"] ?? "New";

    final status =
    rawStatus == "New" ? "Waiting" : rawStatus;

    final statusColor =
    _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  app["jobName"] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6),
                decoration: BoxDecoration(
                  color:
                  statusColor.withOpacity(0.12),
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

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "Applied on ${app["applyDate"] ?? ""}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
