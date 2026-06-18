import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Find your dream job easily",
      "subtitle":
      "Connect with top tech companies looking for talented developers like you",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Smart AI matching for better hiring",
      "subtitle":
      "Our intelligent algorithm matches you with the perfect opportunities based on your skills",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Secure, fast, and modern hiring platform",
      "subtitle":
      "Join thousands of developers and companies building the future together",
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final screenW = mq.size.width;

    final isSmall = screenH < 650;
    final isMedium = screenH < 800;


    final imageH = isSmall
        ? screenH * 0.28
        : isMedium
        ? screenH * 0.32
        : screenH * 0.38;

    final titleSize = isSmall ? 18.0 : isMedium ? 20.0 : 23.0;
    final subtitleSize = isSmall ? 13.0 : isMedium ? 14.0 : 15.5;
    final headerPadTop = isSmall ? 12.0 : 18.0;
    final sectionGap = isSmall ? 16.0 : isMedium ? 22.0 : 28.0;
    final buttonH = isSmall ? 48.0 : 54.0;
    final bottomPad = isSmall ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [

            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, headerPadTop, 24, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Text(
                    "DevJob",
                    style: TextStyle(
                      fontSize: isSmall ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 4,
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: screenH * 0.65,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, i) {
                  return SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.fromLTRB(20, sectionGap, 20, 8),
                    child: Column(
                      children: [

                        Container(
                          width: double.infinity,
                          height: imageH,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(pages[i]["image"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(height: sectionGap),

                        Text(
                          pages[i]["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),

                        SizedBox(height: isSmall ? 10 : 14),

                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenW * 0.04),
                          child: Text(
                            pages[i]["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: subtitleSize,
                              height: 1.6,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                      ),
                  );
                },
              ),

            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  width: _currentIndex == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: _currentIndex == i
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(22, 4, 22, bottomPad),
              child: SizedBox(
                width: double.infinity,
                height: buttonH,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        if (_currentIndex == pages.length - 1) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Center(
                        child: Text(
                          _currentIndex == pages.length - 1
                              ? "Get Started"
                              : "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmall ? 15 : 17,
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
    );
  }
}