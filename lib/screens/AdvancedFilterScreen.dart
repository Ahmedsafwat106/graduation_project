import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';

class AdvancedFilterScreen extends StatefulWidget {
  const AdvancedFilterScreen({super.key});

  @override
  State<AdvancedFilterScreen> createState() =>
      _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState
    extends State<AdvancedFilterScreen> {

  List<String> selectedJobTypes = [];
  String selectedLevel = "MidLevel";
  List<String> selectedSkills = [];
  double minimumSalary = 5000;

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadAllSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters"),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<JobsCubit, JobsState>(
        builder: (context, state) {

          List<String> skills = [];

          if (state is SkillsLoaded) {
            skills = state.skills;
          } else if (state is JobsLoading) {
            return const Center(child: CircularProgressIndicator());
          }


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                // Job Types
                const Text("Job Type",
                    style: TextStyle(
                        fontWeight: FontWeight.bold)),

                CheckboxListTile(
                  title: const Text("FullTime"),
                  value:
                  selectedJobTypes.contains("FullTime"),
                  onChanged: (value) {
                    setState(() {
                      value == true
                          ? selectedJobTypes
                          .add("FullTime")
                          : selectedJobTypes
                          .remove("FullTime");
                    });
                  },
                ),

                CheckboxListTile(
                  title: const Text("Remote"),
                  value:
                  selectedJobTypes.contains("Remote"),
                  onChanged: (value) {
                    setState(() {
                      value == true
                          ? selectedJobTypes
                          .add("Remote")
                          : selectedJobTypes
                          .remove("Remote");
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Experience Level
                const Text("Experience Level",
                    style: TextStyle(
                        fontWeight: FontWeight.bold)),

                DropdownButton<String>(
                  value: selectedLevel,
                  items: const [
                    DropdownMenuItem(
                        value: "JuniorLevel",
                        child: Text("Junior")),
                    DropdownMenuItem(
                        value: "MidLevel",
                        child: Text("Mid")),
                    DropdownMenuItem(
                        value: "SeniorLevel",
                        child: Text("Senior")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Skills
                const Text("Skills",
                    style: TextStyle(
                        fontWeight: FontWeight.bold)),

                Wrap(
                  spacing: 6,
                  children: skills
                      .map((skill) => FilterChip(
                    label: Text(skill),
                    selected:
                    selectedSkills.contains(
                        skill),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedSkills
                            .add(skill)
                            : selectedSkills
                            .remove(skill);
                      });
                    },
                  ))
                      .toList(),
                ),

                const SizedBox(height: 20),

                // Salary
                const Text("Minimum Salary",
                    style: TextStyle(
                        fontWeight: FontWeight.bold)),

                Slider(
                  min: 0,
                  max: 20000,
                  divisions: 20,
                  value: minimumSalary,
                  label:
                  minimumSalary.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      minimumSalary = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Apply Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize:
                    const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    context.read<JobsCubit>().savePreferences(
                      selectedJobTypes,
                      selectedLevel,
                      selectedSkills,
                      minimumSalary.toInt(),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Apply Filter",
                    style:
                    TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
