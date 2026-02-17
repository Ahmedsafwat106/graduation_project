import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/applications/applications_cubit.dart';
import '../features/applications/applications_state..dart';
import '../features/cv/cv_cubit.dart';
import '../features/cv/cv_state..dart';

class ApplyJobScreen extends StatefulWidget {
  final Map job;
  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {

  int? selectedCvId;

  @override
  void initState() {
    super.initState();
    context.read<CvCubit>().loadCvs();
  }

  @override
  Widget build(BuildContext context) {

    final int? jobId =
        widget.job["id"] ??
            widget.job["jobId"] ??
            widget.job["job_id"];

    if (jobId == null) {
      return const Scaffold(
        body: Center(child: Text("Invalid Job ID")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply Job"),
        backgroundColor: Colors.green,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ApplicationsCubit, ApplicationsState>(
            listener: (context, state) {
              if (state is ApplicationsSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Applied successfully ✅")),
                );
                Navigator.pop(context);
              }

              if (state is ApplicationsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                widget.job["title"] ?? "",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.job["description"] ??
                    widget.job["desctiption"] ??
                    "",
              ),

              const SizedBox(height: 20),

              const Text(
                "Select CV",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              BlocBuilder<CvCubit, CvState>(
                builder: (context, state) {

                  if (state is CvLoading) {
                    return const CircularProgressIndicator();
                  }

                  if (state is CvsLoaded) {

                    if (state.cvs.isEmpty) {
                      return const Text("No CV uploaded");
                    }

                    return DropdownButton<int>(
                      value: selectedCvId,
                      isExpanded: true,
                      hint: const Text("Choose your CV"),
                      items: state.cvs.map<DropdownMenuItem<int>>((cv) {
                        return DropdownMenuItem<int>(
                          value: cv["id"],
                          child: Text(cv["cvName"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCvId = value;
                        });
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: selectedCvId == null
                      ? null
                      : () {
                    context
                        .read<ApplicationsCubit>()
                        .applyJob(jobId, selectedCvId!);
                  },
                  child: const Text(
                    "Confirm Apply",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
