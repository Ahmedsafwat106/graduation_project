import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});
  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final minExp = TextEditingController();
  final maxExp = TextEditingController();
  final skillController = TextEditingController();

  List<String> skills = [];
  String jobLevel = "Senior";
  String employmentType = "Fulltime";
  String jobType = "Hybrid";

  bool _skillsError = false;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    location.dispose();
    minExp.dispose();
    maxExp.dispose();
    skillController.dispose();
    super.dispose();
  }

  void _submit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final hasSkills = skills.isNotEmpty;

    setState(() => _skillsError = !hasSkills);

    if (!isFormValid || !hasSkills) return;

    final min = int.tryParse(minExp.text.trim());
    final max = int.tryParse(maxExp.text.trim());

    if (min == null || max == null) return;

    if (min > max) {
      setState(() {});
      _formKey.currentState?.validate();
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
      skills,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: BlocConsumer<JobsCubit, JobsState>(
        listener: (context, state) {
          if (state is JobActionSuccess && state.message == "JOB_ADDED") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Job Added Successfully ✅")),
            );
            context.read<JobsCubit>().loadCompanyJobs();
            Navigator.pushNamed(context, "/company-jobs");
          }
          if (state is JobsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, "/company-dashboard"),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create New Job",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Fill job details professionally",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.read<JobsCubit>().loadCompanyJobs();
                        Navigator.pushNamed(context, "/company-jobs");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.list_alt_rounded,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      children: [
                        _modernField(
                          label: "Job Title",
                          controller: title,
                          icon: Icons.work_outline,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Job title is required";
                            }
                            if (v.trim().length < 3) {
                              return "Title must be at least 3 characters";
                            }
                            return null;
                          },
                        ),

                        _modernField(
                          label: "Description",
                          controller: description,
                          icon: Icons.description_outlined,
                          maxLines: 4,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Description is required";
                            }
                            if (v.trim().length < 10) {
                              return "Description must be at least 10 characters";
                            }
                            return null;
                          },
                        ),

                        _modernField(
                          label: "Location",
                          controller: location,
                          icon: Icons.location_on_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Location is required";
                            }
                            return null;
                          },
                        ),

                        _modernField(
                          label: "Minimum Experience (Years)",
                          controller: minExp,
                          icon: Icons.timeline_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Minimum experience is required";
                            }
                            final val = int.tryParse(v.trim());
                            if (val == null) {
                              return "Must be a valid number";
                            }
                            if (val < 0) {
                              return "Cannot be negative";
                            }
                            return null;
                          },
                        ),

                        _modernField(
                          label: "Maximum Experience (Years)",
                          controller: maxExp,
                          icon: Icons.bar_chart_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Maximum experience is required";
                            }
                            final val = int.tryParse(v.trim());
                            if (val == null) {
                              return "Must be a valid number";
                            }
                            final min = int.tryParse(minExp.text.trim()) ?? 0;
                            if (val < min) {
                              return "Max must be greater than or equal to min";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 5),

                        _modernDropdown(
                          "Job Level",
                          jobLevel,
                          ["Junior", "Mid", "Senior"],
                              (v) => setState(() => jobLevel = v),
                        ),

                        _modernDropdown(
                          "Employment Type",
                          employmentType,
                          ["Fulltime", "Parttime"],
                              (v) => setState(() => employmentType = v),
                        ),

                        _modernDropdown(
                          "Job Type",
                          jobType,
                          ["Onsite", "Remote", "Hybrid"],
                              (v) => setState(() => jobType = v),
                        ),

                        const SizedBox(height: 15),

                        // Skills Section
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: _skillsError
                                ? Border.all(color: Colors.red, width: 1.5)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Skills Required",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (_skillsError)
                                    const Text(
                                      "* Add at least one skill",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: skillController,
                                      decoration: InputDecoration(
                                        hintText: "Add skill (e.g. Flutter)",
                                        filled: true,
                                        fillColor: const Color(0xFFF4F7F6),
                                        prefixIcon: const Icon(
                                            Icons.psychology_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (v) {
                                        if (v.trim().isNotEmpty) {
                                          setState(() {
                                            skills.add(v.trim());
                                            skillController.clear();
                                            _skillsError = false;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1FA463),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                      onPressed: () {
                                        if (skillController.text
                                            .trim()
                                            .isNotEmpty) {
                                          setState(() {
                                            skills.add(
                                                skillController.text.trim());
                                            skillController.clear();
                                            _skillsError = false;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              if (skills.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: skills
                                      .map(
                                        (e) => Chip(
                                      label: Text(e),
                                      backgroundColor:
                                      const Color(0xFFE8F5E9),
                                      deleteIconColor: Colors.red,
                                      onDeleted: () {
                                        setState(() => skills.remove(e));
                                        if (skills.isEmpty) {
                                          setState(
                                                  () => _skillsError = true);
                                        }
                                      },
                                    ),
                                  )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        state is JobsLoading
                            ? const CircularProgressIndicator(color: Color(0xFF1FA463), strokeWidth: 3)
                            : SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1FA463),
                                  Color(0xFF159957),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: _submit,
                              child: const Text(
                                "Post Job",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _modernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1FA463)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _modernDropdown(
      String label,
      String value,
      List<String> items,
      Function(String) onChanged,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}