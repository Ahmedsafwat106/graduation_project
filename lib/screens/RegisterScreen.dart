import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({
    super.key,
    required this.role,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late String role;

  final devName = TextEditingController();
  final devEmail = TextEditingController();
  final devPass = TextEditingController();
  final devConfirm = TextEditingController();

  final comName = TextEditingController();
  final comEmail = TextEditingController();
  final comSerial = TextEditingController();
  final comPhone = TextEditingController();
  final comPass = TextEditingController();
  final comConfirm = TextEditingController();

  @override
  void initState() {
    role = widget.role;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, "/upload-cv");
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 50),

                const Text(
                  "DevJob",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4CAF50),
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _roleButton("developer")),
                      Expanded(child: _roleButton("company")),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                if (role == "developer") ...[
                  _field("Full Name", devName, Icons.person),
                  _field("Email", devEmail, Icons.email),
                  _field("Password", devPass, Icons.lock, isPass: true),
                  _field("Confirm Password", devConfirm, Icons.lock, isPass: true),
                ] else ...[
                  _field("Company Name", comName, Icons.business),
                  _field("Email", comEmail, Icons.email),
                  _field("Serial Number", comSerial, Icons.confirmation_number),
                  _field("Phone Number", comPhone, Icons.phone),
                  _field("Password", comPass, Icons.lock, isPass: true),
                  _field("Confirm Password", comConfirm, Icons.lock, isPass: true),
                ],

                const SizedBox(height: 20),

                state is AuthLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                  onTap: () {
                    if (role == "developer") {
                      if (devName.text.isEmpty ||
                          devEmail.text.isEmpty ||
                          devPass.text.isEmpty) {
                        _error("Fill all developer fields");
                        return;
                      }

                      context.read<AuthCubit>().registerDeveloper(
                        devName.text,
                        devEmail.text,
                        devPass.text,
                      );
                    } else {
                      if (comName.text.isEmpty ||
                          comEmail.text.isEmpty ||
                          comSerial.text.isEmpty ||
                          comPhone.text.isEmpty ||
                          comPass.text.isEmpty) {
                        _error("Fill all company fields");
                        return;
                      }

                      context.read<AuthCubit>().registerCompany(
                        comName.text,
                        comSerial.text,
                        comPhone.text,
                        comEmail.text,
                        comPass.text,
                      );
                    }
                  },
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _roleButton(String r) {
    return GestureDetector(
      onTap: () => setState(() => role = r),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: role == r ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          r == "developer" ? "Developer" : "Company",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: role == r ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController c, IconData icon,
      {bool isPass = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: c,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
