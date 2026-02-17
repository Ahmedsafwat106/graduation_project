import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/screens/EditJobScreen..dart';

import 'core/api_service.dart';
import 'features/applications/applications_cubit.dart';
import 'features/auth/AuthCubit.dart';

// Screens
import 'features/cv/cv_cubit.dart';
import 'features/jobs/jobs_cubit.dart';
import 'features/profile/profile_cubit.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/LoginScreen.dart';
import 'screens/RegisterScreen.dart';
import 'screens/ForgotPasswordScreen.dart';
import 'screens/ResetPasswordScreen.dart';
import 'screens/JobListScreen.dart';
import 'screens/UploadCvScreen.dart';
import 'screens/ProfileScreen.dart';
import 'screens/EditProfileScreen.dart';
import 'screens/EditCompanyScreen.dart';
import 'screens/AddJobScreen.dart';
import 'screens/CompanyDashboardScreen.dart';
import 'screens/DeveloperDashboardScreen.dart';
import 'screens/MyApplicationsScreen.dart';
import 'screens/CompanyApplicantsScreen.dart';
import 'screens/CompanyJobsScreen.dart';


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
        BlocProvider<JobsCubit>(
          create: (_) => JobsCubit(ApiService()),
        ),
        BlocProvider<CvCubit>(
          create: (_) => CvCubit(ApiService()),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(ApiService()),
        ),
        BlocProvider<ApplicationsCubit>(
          create: (_) => ApplicationsCubit(ApiService()),
        ),
      ],
      child: MaterialApp(

      debugShowCheckedModeBanner: false,
        title: "DevJob",
        initialRoute: "/splash",

        onGenerateRoute: (settings) {
          switch (settings.name) {

          // =====================
          // BASIC FLOW
          // =====================
            case "/splash":
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );

            case "/onboarding":
              return MaterialPageRoute(
                builder: (_) => const OnBoardingScreen(),
              );

            case "/login":
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );

            case "/register":
              final role = settings.arguments as String? ?? "developer";
              return MaterialPageRoute(
                builder: (_) => RegisterScreen(role: role),
              );

            case "/forgot":
              return MaterialPageRoute(
                builder: (_) => const ForgotPasswordScreen(),
              );

            case "/reset":
              final args = settings.arguments as Map<String, String>? ?? {};
              return MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  token: args["token"] ?? "",
                  email: args["email"] ?? "",
                ),
              );

          // =====================
          // DEVELOPER
          // =====================
            case "/developer-dashboard":
              return MaterialPageRoute(
                builder: (_) => const DeveloperDashboardScreen(),
              );

          /// 🔹 لو محتاج تفتح JobList مباشرة
            case "/jobs":
              return MaterialPageRoute(
                builder: (_) => const JobListScreen(
                  loadType: JobLoadType.all,
                ),
              );

            case "/upload-cv":
              return MaterialPageRoute(
                builder: (_) => const UploadCvScreen(),
              );

            case "/profile":
              return MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              );

            case "/edit-profile":
              final data = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => EditProfileScreen(data: data),
              );

            case "/my-applications":
              return MaterialPageRoute(
                builder: (_) => const MyApplicationsScreen(),
              );

          // =====================
          // COMPANY
          // =====================
            case "/company-dashboard":
              return MaterialPageRoute(
                builder: (_) => const CompanyDashboardScreen(),
              );

            case "/add-job":
              return MaterialPageRoute(
                builder: (_) => const AddJobScreen(),
              );

            case "/edit-company":
              final data = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => EditCompanyScreen(data: data),
              );

            case "/company-applicants":
              final jobId = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => CompanyApplicantsScreen(jobId: jobId),
              );

            case "/company-jobs":
              return MaterialPageRoute(
                builder: (_) => const CompanyJobsScreen(),
              );

            case "/edit-job":
              final job = settings.arguments as Map;
              return MaterialPageRoute(
                builder: (_) => EditJobScreen(job: job),
              );

          // =====================
          // FALLBACK
          // =====================
            default:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
              );
          }
        },
      ),
    );
  }
}