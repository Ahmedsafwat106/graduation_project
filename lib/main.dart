import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/screens/MockInterviewInstructionsScreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'features/theme/theme_cubit.dart';
import 'core/api_service.dart';
import 'features/applications/applications_cubit.dart';
import 'features/auth/AuthCubit.dart';
import 'features/chat/ChatCubit.dart';
import 'features/cv/cv_cubit.dart';
import 'features/jobs/jobs_cubit.dart';
import 'features/notification/notification_cubit.dart';
import 'features/profile/profile_cubit.dart';
import 'features/interview/MockInterviewCubit.dart';
import 'screens/splash_screen.dart';
import 'screens/MockInterviewScreen.dart';
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
  await EasyLocalization.ensureInitialized();

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

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const DevJobApp(),
    ),
  );
}

class DevJobApp extends StatefulWidget {
  const DevJobApp({super.key});

  @override
  State<DevJobApp> createState() => _DevJobAppState();
}

class _DevJobAppState extends State<DevJobApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      child: const _AppContent(),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

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

        BlocProvider<MockInterviewCubit>(
          create: (_) => MockInterviewCubit(ApiService()),
        ),
      ],

      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,

            themeMode: themeMode,

            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1B4D54),
                brightness: Brightness.light,
                primary: const Color(0xFF1B4D54),
                secondary: const Color(0xFFC19A6B),
                surface: Colors.white,
                background: const Color(0xFFF4F7F6),
              ),
              scaffoldBackgroundColor: const Color(0xFFF4F7F6),
              cardColor: Colors.white,
              textTheme: GoogleFonts.cairoTextTheme(
                ThemeData.light().textTheme,
              ),
              primaryTextTheme: GoogleFonts.cairoTextTheme(
                ThemeData.light().primaryTextTheme,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF7F9FB),
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1B4D54),
                brightness: Brightness.dark,
                primary: const Color(0xFF4ECDC4),
                secondary: const Color(0xFFC19A6B),
                surface: const Color(0xFF1E2A2C),
                background: const Color(0xFF121A1C),
              ),
              scaffoldBackgroundColor: const Color(0xFF121A1C),
              cardColor: const Color(0xFF1E2A2C),
              dividerColor: const Color(0xFF2E3E41),
              textTheme: GoogleFonts.cairoTextTheme(
                ThemeData.dark().textTheme,
              ),
              primaryTextTheme: GoogleFonts.cairoTextTheme(
                ThemeData.dark().primaryTextTheme,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF243035),
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Color(0xFF7A9BA0)),
              ),
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

                case "/mock-interview-instructions":
                  return MaterialPageRoute(
                    builder: (_) => const MockInterviewInstructionsScreen(),
                  );

                case "/mock-interview":
                  final args = settings.arguments as Map<String, String>? ?? {};
                  return MaterialPageRoute(
                    builder: (_) => MockInterviewScreen(
                      track: args["track"] ?? "Backend",
                      interviewLevel: args["interviewLevel"] ?? "Mid level",
                    ),
                  );
              }

              return null;
            },
          );
        },
      ),
    );
  }
}