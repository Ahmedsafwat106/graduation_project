import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import 'DeveloperHomeScreen.dart';
import 'ForgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = "developer";

  final devEmail = TextEditingController();
  final devPass = TextEditingController();

  final cmpEmail = TextEditingController();
  final cmpPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 80),

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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeveloperHomeScreen(),
                      ),
                    );
                  }
                  if (state is AuthFailure) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Sign in to continue",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 20),

                      // ROLE SWITCHER
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _roleButton("developer"),
                            ),
                            Expanded(
                              child: _roleButton("company"),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // FIELDS
                      if (role == "developer") ...[
                        _field("Email", devEmail, Icons.email),
                        _field("Password", devPass, Icons.lock, isPass: true),
                      ] else ...[
                        _field("Company Email", cmpEmail, Icons.email),
                        _field("Password", cmpPass, Icons.lock, isPass: true),
                      ],

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      state is AuthLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          minimumSize:
                          const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final email = role == "developer"
                              ? devEmail.text
                              : cmpEmail.text;

                          final pass = role == "developer"
                              ? devPass.text
                              : cmpPass.text;

                          context
                              .read<AuthCubit>()
                              .login(email, pass, role);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white, fontSize: 17),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, "/register"),
              child: const Text(
                "Create Account",
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          filled: true,
          fillColor: const Color(0xFFF3F6FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
