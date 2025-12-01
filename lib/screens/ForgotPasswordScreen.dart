import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'ResetPasswordScreen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();

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
                    color: Color(0xFF4CAF50)),
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
                          offset: Offset(0, 10))
                    ]),
                child: Column(
                  children: [
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        filled: true,
                        fillColor: const Color(0xFFF3F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () async {
                        try {
                          final api = ApiService();
                          await api.forgot(email.text);

                          // نروح لصفحة الريست بدون توكن
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResetPasswordScreen(
                                token: "",     // المستخدم هيدخّله بنفسه
                                email: email.text,
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("Error: $e")));
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
                          "Send Reset Link",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
