import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'core/api_service.dart';
import 'features/applications/applications_cubit.dart';
import 'features/auth/AuthCubit.dart';
import 'features/chat/ChatCubit.dart';
import 'features/cv/cv_cubit.dart';
import 'features/jobs/jobs_cubit.dart';
import 'features/notification/notification_cubit.dart';
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
import 'screens/AdvancedFilterScreen.dart';
import 'screens/NotificationScreen.dart';
import 'screens/ChatListScreen.dart';
import 'screens/ChatDetailsScreen.dart';
import 'screens/SavedJobsScreen.dart';
import 'screens/SearchJobsScreen.dart';
import 'screens/EditJobScreen..dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.initialize("d1e9d034-5883-42c7-886b-60cad9162599");

  await OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    OneSignal.Notifications.addClickListener((event) {
      print("📱 Notification Clicked");
    });
    print("🔔 Notification Received: ${event.notification.title}");

    event.preventDefault();

    event.notification.display();
  });

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

        BlocProvider(
          create: (_) => ChatCubit(ApiService()),
        ),

        BlocProvider(
          create: (_) => NotificationCubit(ApiService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          fontFamily: "Poppins",
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),

        title: "DevJob",
        initialRoute: "/splash",

        onGenerateRoute: (settings) {
          switch (settings.name) {

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

            case "/developer-dashboard":
              return MaterialPageRoute(
                builder: (_) => const DeveloperDashboardScreen(),
              );

            case "/company-dashboard":
              return MaterialPageRoute(
                builder: (_) => const CompanyDashboardScreen(),
              );

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

            case "/edit-company":
              final data = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => EditCompanyScreen(data: data),
              );

            case "/add-job":
              return MaterialPageRoute(
                builder: (_) => const AddJobScreen(),
              );

            case "/company-jobs":
              return MaterialPageRoute(
                builder: (_) => const CompanyJobsScreen(),
              );

            case "/company-applicants":
              final jobId = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => CompanyApplicantsScreen(jobId: jobId),
              );

            case "/my-applications":
              return MaterialPageRoute(
                builder: (_) => const MyApplicationsScreen(),
              );

            case "/saved-jobs":
              final userId = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => SavedJobsScreen(userId: userId),
              );

            case "/advanced-filter":
              return MaterialPageRoute(
                builder: (_) => const AdvancedFilterScreen(),
              );

            case "/notifications":
              return MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              );

            case "/chats":
              return MaterialPageRoute(
                builder: (_) => const ChatListScreen(),
              );

            case "/chat-details":
              final args = settings.arguments as Map?;
              final conversationId = args?["conversationId"];

              if (conversationId == null) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text("Invalid Conversation")),
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => ChatDetailsScreen(
                  conversationId: conversationId,
                ),
              );

            case "/edit-job":
              final job = settings.arguments as Map;
              return MaterialPageRoute(
                builder: (_) => EditJobScreen(job: job),
              );
            case "/SearchJobsScreen":
              final jobs = settings.arguments as List? ?? [];
              return MaterialPageRoute(
                builder: (_) => SearchJobsScreen(jobs: jobs),
              );
          }

          return null;
        },
      ),
    );
  }
}