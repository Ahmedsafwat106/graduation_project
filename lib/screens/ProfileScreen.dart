import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/profile/profile_cubit.dart';
import '../features/profile/profile_state..dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String role = "developer";

  @override
  void initState() {
    super.initState();
    _loadRole();
    context.read<ProfileCubit>().loadUserProfile();

  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role") ?? "developer";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final data = state.user;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(Icons.person, size: 55, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // ======= Developer =======
                  if (role == "developer") ...[
                    _info("Name", "${data['firstName']} ${data['lastName']}"),
                    _info("Email", data["email"]),
                    _info("Phone", data["phone"] ?? "Not set"),
                    _info("City", data["city"] ?? "Not set"),
                  ],

                  // ======= Company =======
                  if (role == "company") ...[
                    _info("Company", data["companyName"]),
                    _info("Email", data["email"]),
                    _info("Phone", data["phone"] ?? "Not set"),
                    _info("City", data["city"] ?? "Not set"),
                    _info("Field", data["field"] ?? "Not set"),
                  ],

                  const SizedBox(height: 35),


                  const Text(
                    "Choose edit mode",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/edit-profile",
                              arguments: data,
                            );
                          },
                          child: const Text("Edit Developer"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/edit-company",
                              arguments: data,
                            );
                          },
                          child: const Text("Edit Company"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Unable to load profile"));
        },
      ),
    );
  }

  Widget _info(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
