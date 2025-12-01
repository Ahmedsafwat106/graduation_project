import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'LoginScreen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String token;
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final tokenController = TextEditingController(text: token);
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FFFA),
      body: SafeArea(
        child: SingleChildScrollView(
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 25,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your reset token and new password",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 25),

                    _field("Token", tokenController),
                    const SizedBox(height: 14),

                    _field("New Password", newPasswordController,
                        isPass: true),
                    const SizedBox(height: 14),

                    _field("Confirm Password", confirmPasswordController,
                        isPass: true),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () async {
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Passwords do not match"),
                            ),
                          );
                          return;
                        }

                        final api = ApiService();
                        try {
                          await api.resetPassword(
                            tokenController.text,
                            email,
                            newPasswordController.text,
                            confirmPasswordController.text,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password reset successfully"),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4CAF50),
                              Color(0xFF66BB6A),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController controller,
      {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
