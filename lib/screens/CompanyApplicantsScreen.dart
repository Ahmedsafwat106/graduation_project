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

  @override
  void initState() {
    super.initState();
    context
        .read<ApplicationsCubit>()
        .loadJobApplicants(widget.jobId);
  }

  // ✅ تحديد لون الحالة
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
      appBar: AppBar(
        title: const Text("Job Applicants"),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<ApplicationsCubit, ApplicationsState>(
        builder: (context, state) {

          if (state is ApplicationsLoading) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (state is ApplicantsLoaded) {
            if (state.applicants.isEmpty) {
              return const Center(
                  child: Text("No applicants yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.applicants.length,
              itemBuilder: (context, index) {
                final user = state.applicants[index];
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
    );
  }

  // ✅ كارت المتقدم النهائي
  Widget _applicantCard(Map user) {

    final String status = user["status"] ?? "New";
    final Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // الاسم + Match Score
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
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
            style:
            const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          // Skills
          Wrap(
            spacing: 6,
            children: (user["skillName"] as List?)
                ?.map((skill) => Chip(
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
            style:
            const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          // ✅ Dropdown ملون حسب الحالة
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color:
              statusColor.withOpacity(0.1),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: status,
                iconEnabledColor: statusColor,
                dropdownColor: Colors.white,
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
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<ApplicationsCubit>()
                        .updateStatus(
                      widget.jobId,
                      user["userId"],
                      value,
                    );
                  }
                },
                style: TextStyle(
                  color: statusColor,
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
