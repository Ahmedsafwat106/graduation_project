import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/theme/theme_cubit.dart';
import '../widgets/theme_toggle_button.dart';
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
    final isDark = context.watch<ThemeCubit>().isDark;
    final cardColor = isDark ? const Color(0xFF1E2A2C) : Colors.white;
    final fieldColor = isDark ? const Color(0xFF243035) : const Color(0xFFF7F9FB);
    final bgColor = isDark ? const Color(0xFF121A1C) : const Color(0xFFF4F7F6);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final textSecondary = isDark ? const Color(0xFF7A9BA0) : Colors.grey;
    final roleBg = isDark ? const Color(0xFF243035) : const Color(0xFFF1F3F5);
    final roleSelectedBg = isDark ? const Color(0xFF2E3E41) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 12, 50),
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
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ThemeToggleButton(color: Colors.white),
                    ),
                  ),
                  const Text(
                    "DevJob",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
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
                        Navigator.pushReplacementNamed(context, "/upload-cv");
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

                        Center(
                          child: Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Center(
                          child: Text(
                            "Sign in to continue",
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: roleBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _roleButton(
                                  "developer",
                                  roleSelectedBg: roleSelectedBg,
                                  textPrimary: textPrimary,
                                ),
                              ),
                              Expanded(
                                child: _roleButton(
                                  "company",
                                  roleSelectedBg: roleSelectedBg,
                                  textPrimary: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (role == "developer") ...[
                          _modernField(
                            "Email Address",
                            devEmail,
                            Icons.email_outlined,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                          ),
                          _modernField(
                            "Password",
                            devPass,
                            Icons.lock_outline,
                            isPass: true,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                          ),
                        ] else ...[
                          _modernField(
                            "Company Email",
                            cmpEmail,
                            Icons.business_center_outlined,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                          ),
                          _modernField(
                            "Password",
                            cmpPass,
                            Icons.lock_outline,
                            isPass: true,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                          ),
                        ],

                        const SizedBox(height: 6),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            ),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        state is AuthLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3,
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
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
                  child: Divider(
                    color: isDark
                        ? const Color(0xFF2E3E41)
                        : Colors.grey.shade300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "or",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF7A9BA0) : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark
                        ? const Color(0xFF2E3E41)
                        : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/register"),
              child: const Text(
                "Create Account",
                style: TextStyle(
                  color: AppColors.primary,
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

  Widget _roleButton(
    String r, {
    required Color roleSelectedBg,
    required Color textPrimary,
  }) {
    final isSelected = role == r;

    return GestureDetector(
      onTap: () => setState(() => role = r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? roleSelectedBg : Colors.transparent,
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
            color: isSelected ? textPrimary : Colors.grey,
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
    required Color fieldColor,
    required Color textSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: c,
        obscureText: isPass ? _obscure : false,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF1E1E1E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
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