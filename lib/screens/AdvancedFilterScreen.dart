import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/jobs/jobs_cubit.dart';
import '../features/jobs/jobs_state..dart';
import '../widgets/loading_indicator.dart';

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
      backgroundColor: const Color(0xFFF4F7F6),
      body: BlocBuilder<JobsCubit, JobsState>(
        builder: (context, state) {

          List<String> skills = [];

          if (state is SkillsLoaded) {
            skills = state.skills;
          } else if (state is JobsLoading) {
            const LoadingIndicator();
          }

          return Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                          "Advanced Filters",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Refine your job search",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _sectionCard(
                        title: "Job Type",
                        child: Column(
                          children: [
                            _modernCheckbox("FullTime"),
                            _modernCheckbox("Remote"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _sectionCard(
                        title: "Experience Level",
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButton<String>(
                            value: selectedLevel,
                            isExpanded: true,
                            underline: const SizedBox(),
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
                        ),
                      ),

                      const SizedBox(height: 16),

                      _sectionCard(
                        title: "Skills",
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skills
                              .map(
                                (skill) => FilterChip(
                              label: Text(skill),
                              selected:
                              selectedSkills.contains(skill),
                              selectedColor:
                              AppColors.primary.withOpacity(0.1),
                              checkmarkColor:
                              AppColors.primary,
                              labelStyle: TextStyle(
                                color: selectedSkills
                                    .contains(skill)
                                    ? AppColors.primary
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  selected
                                      ? selectedSkills.add(skill)
                                      : selectedSkills.remove(skill);
                                });
                              },
                            ),
                          )
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _sectionCard(
                        title: "Minimum Salary",
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${minimumSalary.round()} EGP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                AppColors.primary,
                                thumbColor:
                                AppColors.primary,
                                inactiveTrackColor:
                                Colors.grey.shade300,
                              ),
                              child: Slider(
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
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
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
                            onPressed: () async {

                              if (selectedJobTypes.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please select at least one job type")),
                                );
                                return;
                              }

                              await context.read<JobsCubit>().savePreferences(
                                selectedJobTypes,
                                selectedLevel,
                                selectedSkills,
                                minimumSalary.toInt(),
                              );

                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Apply Filters",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _modernCheckbox(String value) {
    final isSelected = selectedJobTypes.contains(value);

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(value),
      value: isSelected,
      activeColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onChanged: (v) {
        setState(() {
          v == true
              ? selectedJobTypes.add(value)
              : selectedJobTypes.remove(value);
        });
      },
    );
  }
}