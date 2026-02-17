import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/profile/profile_cubit.dart';
import '../features/profile/profile_state..dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditProfileScreen({required this.data, super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController first;
  late TextEditingController last;
  late TextEditingController phone;
  late TextEditingController city;

  @override
  void initState() {
    first = TextEditingController(text: widget.data["firstName"]);
    last = TextEditingController(text: widget.data["lastName"]);
    phone = TextEditingController(text: widget.data["phone"] ?? "");
    city = TextEditingController(text: widget.data["city"] ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile Updated ✓")));
            Navigator.pop(context);
          }
        },

        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _field("First Name", first),
                _field("Last Name", last),
                _field("Phone", phone),
                _field("City", city),

                const SizedBox(height: 25),

                state is AuthLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  onPressed: () {
                    context.read<ProfileCubit>().updateUserProfile(
                      first.text,
                      last.text,
                      phone.text,
                      city.text,
                    );
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}