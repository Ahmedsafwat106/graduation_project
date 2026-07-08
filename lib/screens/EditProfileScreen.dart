import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/profile/profile_cubit.dart';
import '../features/profile/profile_state..dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditProfileScreen({required this.data, super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  late TextEditingController first;
  late TextEditingController last;
  late TextEditingController phone;
  late TextEditingController city;

  @override
  void initState() {
    first =
        TextEditingController(text: widget.data["firstName"]);
    last =
        TextEditingController(text: widget.data["lastName"]);
    phone =
        TextEditingController(text: widget.data["phone"] ?? "");
    city =
        TextEditingController(text: widget.data["city"] ?? "");
    super.initState();
  }

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    phone.dispose();
    city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile Updated ✓"),
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileFailure) {
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
                padding:
                const EdgeInsets.fromLTRB(20, 50, 20, 30),
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
                          color:
                          Colors.white.withOpacity(0.2),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Update your personal information",
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
                  padding:
                  const EdgeInsets.fromLTRB(
                      20, 20, 20, 30),
                  child: Column(
                    children: [
                      _modernField(
                        "First Name",
                        first,
                        Icons.person_outline,
                      ),
                      _modernField(
                        "Last Name",
                        last,
                        Icons.person_outline,
                      ),
                      _modernField(
                        "Phone",
                        phone,
                        Icons.phone_outlined,
                      ),
                      _modernField(
                        "City",
                        city,
                        Icons.location_city_outlined,
                      ),

                      const SizedBox(height: 30),
                      state is ProfileLoading
                          ? const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)
                          : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient:
                            const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ),
                            borderRadius:
                            BorderRadius.circular(
                                18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(0.25),
                                blurRadius: 14,
                                offset:
                                const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.transparent,
                              shadowColor:
                              Colors.transparent,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(18),
                              ),
                            ),
                            onPressed: () {
                              if (first.text.trim().isEmpty || last.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("First Name and Last Name are required")),
                                );
                                return;
                              }
                              context
                                  .read<ProfileCubit>()
                                  .updateUserProfile(
                                first.text,
                                last.text,
                                phone.text,
                                city.text,
                              );
                            },
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
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
            ],
          );
        },
      ),
    );
  }

  Widget _modernField(
      String label,
      TextEditingController c,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
          Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(
              vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}