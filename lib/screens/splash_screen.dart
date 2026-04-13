import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _scaleAnimation =
        Tween<double>(begin: 0.9, end: 1.08).animate(_fadeAnimation);

    _controller.forward();

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final role = prefs.getString("role") ?? "";

    if (token.isNotEmpty) {
      if (role == "company") {
        Navigator.pushReplacementNamed(context, "/company-dashboard");
      } else {
        Navigator.pushReplacementNamed(context, "/developer-dashboard");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/onboarding");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1FA463),
              Color(0xFF159957),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(

                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF1FA463),
                        size: 55,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "DevJob",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Find • Match • Grow",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: 26,
                  height: 26,
                  child:CircularProgressIndicator(color: Color(0xFF1FA463), strokeWidth: 3)
                ),
                const SizedBox(height: 20),

                const Text(
                  "Version 1.0",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}