import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/profile/profile_cubit.dart';
import '../features/profile/profile_state..dart';

class EditCompanyScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditCompanyScreen({required this.data, super.key});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  late TextEditingController company;
  late TextEditingController phone;
  late TextEditingController city;
  late TextEditingController field;

  @override
  void initState() {
    company = TextEditingController(text: widget.data["companyName"]);
    phone = TextEditingController(text: widget.data["phone"] ?? "");
    city = TextEditingController(text: widget.data["city"] ?? "");
    field = TextEditingController(text: widget.data["field"] ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Company Updated ✓")),
            );
            Navigator.pop(context);
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
                    colors: [
                      Color(0xFF1FA463),
                      Color(0xFF159957),
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
                          "Edit Company",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Update your company profile",
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
                    children: [

                      _modernField(
                        "Company Name",
                        company,
                        Icons.business_outlined,
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
                      _modernField(
                        "Field",
                        field,
                        Icons.work_outline,
                      ),

                      const SizedBox(height: 30),
                      state is AuthLoading
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
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              context.read<ProfileCubit>().updateCompany(
                                company.text,
                                phone.text,
                                city.text,
                                field.text,
                              );
                            },
                            child: const Text(
                              "Save Changes",
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
            ],
          );
        },
      ),
    );
  }

  Widget _modernField(
      String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
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
        ),
      ),
    );
  }
}