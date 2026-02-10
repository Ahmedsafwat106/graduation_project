import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class EditJobScreen extends StatefulWidget {
  final Map job;
  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late TextEditingController title;
  late TextEditingController description;
  late TextEditingController location;

  // القيم اللي مش بتتعدل في الشاشة
  late String jobType;
  late String jobLevel;
  late String employmentType;

  @override
  void initState() {
    super.initState();

    title = TextEditingController(text: widget.job["title"] ?? "");
    description =
        TextEditingController(text: widget.job["description"] ?? "");
    location = TextEditingController(text: widget.job["location"] ?? "");

    // ناخد القيم القديمة زي ما هي
    jobType = widget.job["jobType"] ?? "Onsite";
    jobLevel = widget.job["jobLevel"] ?? "Mid";
    employmentType = widget.job["employmentType"] ?? "Parttime";
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int jobId = widget.job["id"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Job"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess && state.message == "JOB_UPDATED") {
              Navigator.pop(context); // رجوع My Jobs
            }

            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              children: [
                _field("Job Title", title),
                _field("Description", description, max: 4),
                _field("Location", location),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                    context.read<AuthCubit>().updateJob(
                      jobId,
                      title.text.trim(),
                      description.text.trim(),
                      location.text.trim(),
                      jobType,
                      jobLevel,
                      employmentType,
                    );
                  },
                  child: state is AuthLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        maxLines: max,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
