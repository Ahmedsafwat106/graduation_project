import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final minExp = TextEditingController();
  final maxExp = TextEditingController();

  String jobLevel = "Senior";
  String employmentType = "Fulltime";
  String jobType = "Hybrid";

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    location.dispose();
    minExp.dispose();
    maxExp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Job"),
        backgroundColor: Colors.green,
      ),
      body: BlocConsumer<JobsCubit, JobsState>(
        listener: (context, state) {
          if (state is JobActionSuccess && state.message == "JOB_ADDED") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Job Added Successfully ✅")),
            );
            context.read<JobsCubit>().loadCompanyJobs();

            Navigator.pushReplacementNamed(context, "/company-jobs");
          }

          if (state is JobsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _field("Job Title", title),
                _field("Description", description, maxLines: 3),
                _field("Location", location),
                _field("Minimum Experience (Years)", minExp),
                _field("Maximum Experience (Years)", maxExp),

                const SizedBox(height: 10),

                _dropdown(
                  "Job Level",
                  jobLevel,
                  ["Junior", "Mid", "Senior"],
                      (v) => setState(() => jobLevel = v),
                ),

                _dropdown(
                  "Employment Type",
                  employmentType,
                  ["Fulltime", "Parttime"],
                      (v) => setState(() => employmentType = v),
                ),

                _dropdown(
                  "Job Type",
                  jobType,
                  ["Onsite", "Remote", "Hybrid"],
                      (v) => setState(() => jobType = v),
                ),

                const SizedBox(height: 25),

                state is AuthLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (title.text.isEmpty ||
                          description.text.isEmpty ||
                          location.text.isEmpty ||
                          minExp.text.isEmpty ||
                          maxExp.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text("Please fill all fields")),
                        );
                        return;
                      }

                      final min = int.tryParse(minExp.text);
                      final max = int.tryParse(maxExp.text);

                      if (min == null || max == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text("Experience must be numbers")),
                        );
                        return;
                      }

                      context.read<JobsCubit>().addJob(

                      title.text.trim(),
                        description.text.trim(),
                        location.text.trim(),
                        min,
                        max,
                        jobLevel,
                        employmentType,
                        jobType,
                      );
                    },
                    child: const Text(
                      "Add Job",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
      String label,
      String value,
      List<String> items,
      Function(String) onChanged,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ),
        )
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}