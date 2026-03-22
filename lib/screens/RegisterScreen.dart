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

  bool _obscureDevPass = true;
  bool _obscureDevConfirm = true;
  bool _obscureComPass = true;
  bool _obscureComConfirm = true;

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

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 8) return "At least 8 characters";
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Must contain uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(value)) return "Must contain lowercase letter";
    if (!RegExp(r'[0-9]').hasMatch(value)) return "Must contain number";
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) return "Must contain special character (@,#,...)";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.message == "LOGIN_SUCCESS") {
            if (role == "developer") {
              Navigator.pushReplacementNamed(context, "/upload-cv");
            } else {
              Navigator.pushReplacementNamed(context, "/company-dashboard");
            }
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 45),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1FA463), Color(0xFF159957)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "DevJob",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Create your account and start your journey 🚀",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Center(
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _roleButton("developer")),
                              Expanded(child: _roleButton("company")),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (role == "developer") ...[
                          _modernField("Full Name", devName, Icons.person_outline),
                          _modernField("Email", devEmail, Icons.email_outlined),
                          _modernFieldPass(
                            "Password",
                            devPass,
                            Icons.lock_outline,
                            obscure: _obscureDevPass,
                            onToggle: () => setState(() => _obscureDevPass = !_obscureDevPass),
                          ),
                          _modernFieldPass(
                            "Confirm Password",
                            devConfirm,
                            Icons.lock_outline,
                            obscure: _obscureDevConfirm,
                            onToggle: () => setState(() => _obscureDevConfirm = !_obscureDevConfirm),
                          ),
                        ] else ...[
                          _modernField("Company Name", comName, Icons.business_outlined),
                          _modernField("Email", comEmail, Icons.email_outlined),
                          _modernField("Serial Number", comSerial, Icons.confirmation_number_outlined),
                          _modernField("Phone Number", comPhone, Icons.phone_outlined),
                          _modernFieldPass(
                            "Password",
                            comPass,
                            Icons.lock_outline,
                            obscure: _obscureComPass,
                            onToggle: () => setState(() => _obscureComPass = !_obscureComPass),
                          ),
                          _modernFieldPass(
                            "Confirm Password",
                            comConfirm,
                            Icons.lock_outline,
                            obscure: _obscureComConfirm,
                            onToggle: () => setState(() => _obscureComConfirm = !_obscureComConfirm),
                          ),
                        ],

                        const SizedBox(height: 25),

                        state is AuthLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1FA463),
                                  Color(0xFF159957),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),

                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1FA463),
                                    Color(0xFF159957),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),

                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),

                                  onTap: () {
                                    if (role == "developer") {
                                      final passError = validatePassword(devPass.text);

                                      if (devName.text.isEmpty ||
                                          devEmail.text.isEmpty ||
                                          devPass.text.isEmpty) {
                                        _error("Fill all developer fields");
                                        return;
                                      }

                                      if (passError != null) {
                                        _error(passError);
                                        return;
                                      }

                                      if (devPass.text != devConfirm.text) {
                                        _error("Passwords do not match");
                                        return;
                                      }

                                      context.read<AuthCubit>().registerDeveloper(
                                        devName.text,
                                        devEmail.text,
                                        devPass.text,
                                      );
                                    } else {
                                      final passError = validatePassword(comPass.text);

                                      if (comName.text.isEmpty ||
                                          comEmail.text.isEmpty ||
                                          comSerial.text.isEmpty ||
                                          comPhone.text.isEmpty ||
                                          comPass.text.isEmpty) {
                                        _error("Fill all company fields");
                                        return;
                                      }

                                      if (passError != null) {
                                        _error(passError);
                                        return;
                                      }

                                      if (comPass.text != comConfirm.text) {
                                        _error("Passwords do not match");
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

                                  child: const Center(
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "By signing up you agree to our Terms & Conditions",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Color(0xFF1FA463),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _roleButton(String r) {
    final isSelected = role == r;
    return GestureDetector(
      onTap: () => setState(() => role = r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          r == "developer" ? "Developer" : "Company",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF1E1E1E) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _modernField(String hint, TextEditingController c, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1FA463)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _modernFieldPass(
      String hint,
      TextEditingController c,
      IconData icon, {
        required bool obscure,
        required VoidCallback onToggle,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1FA463)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}