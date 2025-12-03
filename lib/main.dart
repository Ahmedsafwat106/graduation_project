import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api_service.dart';
import 'features/auth/AuthCubit.dart';


import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/LoginScreen.dart';
import 'screens/RegisterScreen.dart';
import 'screens/ForgotPasswordScreen.dart';
import 'screens/ResetPasswordScreen.dart';
import 'screens/DeveloperHomeScreen.dart';

void main() {
  runApp(const DevJobApp());
}

class DevJobApp extends StatelessWidget {
  const DevJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(ApiService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "DevJob",
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: "Poppins",
        ),

        // -------------------------
        // ROUTING
        // -------------------------
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case "/splash":
              return MaterialPageRoute(
                  builder: (_) => const SplashScreen());

            case "/onboarding":
              return MaterialPageRoute(
                  builder: (_) => const OnBoardingScreen());

            case "/login":
              return MaterialPageRoute(
                  builder: (_) => const LoginScreen());

            case "/register":
              final role = settings.arguments as String? ?? "developer";
              return MaterialPageRoute(
                  builder: (_) => RegisterScreen(role: role));

            case "/forgot":
              return MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen());

            case "/reset":
              final args = settings.arguments as Map<String, String>? ?? {};
              return MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  token: args["token"] ?? "",
                  email: args["email"] ?? "",
                ),
              );

            case "/dashboard":
              return MaterialPageRoute(
                builder: (_) => const DeveloperHomeScreen(),
              );

            default:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
          }
        },

        initialRoute: "/splash",
      ),
    );
  }
}
