import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import 'ForgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  String role = "developer";

  final devEmail = TextEditingController();
  final devPass = TextEditingController();

  final cmpEmail = TextEditingController();
  final cmpPass = TextEditingController();

  @override
  void dispose() {
    devEmail.dispose();
    devPass.dispose();
    cmpEmail.dispose();
    cmpPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 50),
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
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Find your dream job faster 🚀",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
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
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess &&
                        state.message == "LOGIN_SUCCESS") {

                      if (role == "developer") {
                        Navigator.pushReplacementNamed(
                            context, "/upload-cv");
                      } else {
                        Navigator.pushReplacementNamed(
                            context, "/company-dashboard");
                      }
                    }
                    if (state is AuthSuccess && state.message == "VERIFY_EMAIL") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please verify your email first 📧"),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }

                    if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Center(
                          child: Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Center(
                          child: Text(
                            "Sign in to continue",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

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
                          _modernField(
                              "Email Address",
                              devEmail,
                              Icons.email_outlined),
                          _modernField(
                              "Password",
                              devPass,
                              Icons.lock_outline,
                              isPass: true),
                        ] else ...[
                          _modernField(
                              "Company Email",
                              cmpEmail,
                              Icons.business_center_outlined),
                          _modernField(
                              "Password",
                              cmpPass,
                              Icons.lock_outline,
                              isPass: true),
                        ],

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const ForgotPasswordScreen(),
                              ),
                            ),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFF1FA463),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        state is AuthLoading
                            ? const Center(
                            child:  CircularProgressIndicator(color: Color(0xFF1FA463), strokeWidth: 3))
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
                              borderRadius:
                              BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  offset:
                                  const Offset(0, 10),
                                ),
                              ],
                            ),

                            child: SizedBox(
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
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),

                                    onTap: () {
                                      final email = role == "developer"
                                          ? devEmail.text
                                          : cmpEmail.text;

                                      final pass = role == "developer"
                                          ? devPass.text
                                          : cmpPass.text;

                                      context.read<AuthCubit>().login(
                                        email,
                                        pass,
                                        role,
                                      );
                                    },

                                    child: const Center(
                                      child: Text(
                                        "Login",
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
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),


            const SizedBox(height: 20),

            Row(
              children: [

                Expanded(
                  child: Divider(color: Colors.grey.shade300),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "or",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                Expanded(
                  child: Divider(color: Colors.grey.shade300),
                ),
              ],
            ),
            const SizedBox(height: 28),

            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, "/register"),
              child: const Text(
                "Create Account",
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
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          r == "developer" ? "Developer" : "Company",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color:
            isSelected ? const Color(0xFF1E1E1E) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _modernField(
      String hint,
      TextEditingController c,
      IconData icon, {
        bool isPass = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: c,
        obscureText: isPass ? _obscure : false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1FA463)),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18),

          suffixIcon: isPass
              ? IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscure = !_obscure;
              });
            },
          )
              : null,
        ),
      ),
    );

  }
}