import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/AuthCubit.dart';
import '../features/auth/AuthState.dart';
import '../features/theme/theme_cubit.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/theme_toggle_button.dart';

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

  String? _devPassError;
  String? _devConfirmError;
  String? _comPassError;
  String? _comConfirmError;

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
    final errors = <String>[];
    if (value.length < 8) errors.add("At least 8 characters");
    if (!RegExp(r'[A-Z]').hasMatch(value)) errors.add("Uppercase letter");
    if (!RegExp(r'[a-z]').hasMatch(value)) errors.add("Lowercase letter");
    if (!RegExp(r'[0-9]').hasMatch(value)) errors.add("Number");
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) errors.add("Special character (!@#\$&*~)");
    return errors.isEmpty ? null : errors.join(" • ");
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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.message == "LOGIN_SUCCESS") {
            if (role == "developer") {
              Navigator.pushReplacementNamed(context, "/upload-cv");
            } else {
              Navigator.pushReplacementNamed(context, "/company-dashboard");
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
          return SingleChildScrollView(
            child: Column(
              children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 12, 45),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
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
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Create your account and start your journey 🚀",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Center(
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

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
                            "Full Name",
                            devName,
                            Icons.person_outline,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernField(
                            "Email",
                            devEmail,
                            Icons.email_outlined,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernFieldPass(
                            "Password",
                            devPass,
                            Icons.lock_outline,
                            obscure: _obscureDevPass,
                            onToggle: () =>
                                setState(() => _obscureDevPass = !_obscureDevPass),
                            errorText: _devPassError,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernFieldPass(
                            "Confirm Password",
                            devConfirm,
                            Icons.lock_outline,
                            obscure: _obscureDevConfirm,
                            onToggle: () => setState(
                                () => _obscureDevConfirm = !_obscureDevConfirm),
                            errorText: _devConfirmError,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                        ] else ...[
                          _modernField(
                            "Company Name",
                            comName,
                            Icons.business_outlined,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernField(
                            "Email",
                            comEmail,
                            Icons.email_outlined,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernField(
                            "Serial Number",
                            comSerial,
                            Icons.confirmation_number_outlined,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernField(
                            "Phone Number",
                            comPhone,
                            Icons.phone_outlined,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernFieldPass(
                            "Password",
                            comPass,
                            Icons.lock_outline,
                            obscure: _obscureComPass,
                            onToggle: () =>
                                setState(() => _obscureComPass = !_obscureComPass),
                            errorText: _comPassError,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                          _modernFieldPass(
                            "Confirm Password",
                            comConfirm,
                            Icons.lock_outline,
                            obscure: _obscureComConfirm,
                            onToggle: () => setState(
                                () => _obscureComConfirm = !_obscureComConfirm),
                            errorText: _comConfirmError,
                            fieldColor: fieldColor,
                            textSecondary: textSecondary,
                            textPrimary: textPrimary,
                          ),
                        ],

                        const SizedBox(height: 25),

                        state is AuthLoading
                            ? const LoadingIndicator()
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
                                        if (role == "developer") {
                                          if (devName.text.isEmpty ||
                                              devEmail.text.isEmpty ||
                                              devPass.text.isEmpty) {
                                            _error("Fill all developer fields");
                                            return;
                                          }

                                          setState(() {
                                            _devPassError =
                                                validatePassword(devPass.text);
                                            _devConfirmError =
                                                devPass.text != devConfirm.text
                                                    ? "Passwords do not match"
                                                    : null;
                                          });

                                          if (_devPassError != null ||
                                              _devConfirmError != null) return;

                                          context
                                              .read<AuthCubit>()
                                              .registerDeveloper(
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

                                          setState(() {
                                            _comPassError =
                                                validatePassword(comPass.text);
                                            _comConfirmError =
                                                comPass.text != comConfirm.text
                                                    ? "Passwords do not match"
                                                    : null;
                                          });

                                          if (_comPassError != null ||
                                              _comConfirmError != null) return;

                                          context
                                              .read<AuthCubit>()
                                              .registerCompany(
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "By signing up you agree to our Terms & Conditions",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account?",
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
          );
        },
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
    required Color fieldColor,
    required Color textSecondary,
    required Color textPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: c,
        style: TextStyle(color: textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary),
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
    String? errorText,
    required Color fieldColor,
    required Color textSecondary,
    required Color textPrimary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(20),
            border: errorText != null
                ? Border.all(color: Colors.red.shade300)
                : null,
          ),
          child: TextField(
            controller: c,
            obscureText: obscure,
            style: TextStyle(color: textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: textSecondary),
              prefixIcon: Icon(icon, color: AppColors.primary),
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
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
        else
          const SizedBox(height: 16),
      ],
    );
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}