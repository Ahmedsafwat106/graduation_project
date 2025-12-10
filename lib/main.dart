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
import 'screens/UploadCvScreen.dart';
import 'screens/ProfileScreen.dart';
import 'screens/EditProfileScreen.dart';
import 'screens/EditCompanyScreen.dart';

void main() {
  runApp(const DevJobApp());
}

class DevJobApp extends StatelessWidget {
  const DevJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(ApiService())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "DevJob",
        theme: ThemeData(fontFamily: "Poppins"),

        onGenerateRoute: (settings) {
          switch (settings.name) {
            case "/splash":
              return MaterialPageRoute(builder: (_) => const SplashScreen());

            case "/onboarding":
              return MaterialPageRoute(builder: (_) => const OnBoardingScreen());

            case "/login":
              return MaterialPageRoute(builder: (_) => const LoginScreen());

            case "/register":
              final role = settings.arguments as String? ?? "developer";
              return MaterialPageRoute(builder: (_) => RegisterScreen(role: role));

            case "/forgot":
              return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

            case "/reset":
              final args = settings.arguments as Map<String, String>? ?? {};
              return MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  token: args["token"] ?? "",
                  email: args["email"] ?? "",
                ),
              );

            case "/upload-cv":
              return MaterialPageRoute(builder: (_) => const UploadCvScreen());

            case "/dashboard":
              return MaterialPageRoute(builder: (_) => const DeveloperHomeScreen());

            case "/profile":
              return MaterialPageRoute(builder: (_) => const ProfileScreen());

            case "/edit-profile":
              final data = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => EditProfileScreen(data: data),
              );

            case "/edit-company":
              final data = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => EditCompanyScreen(data: data),
              );

            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },

        initialRoute: "/splash",
      ),
    );
  }
}
