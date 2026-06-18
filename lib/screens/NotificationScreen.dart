
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/notification/NotificationState.dart';
import '../features/notification/notification_cubit.dart';
import '../models/NotificationCard.dart';
import '../widgets/shimmer_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        "Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Mark all",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: BlocBuilder<
                  NotificationCubit,
                  NotificationState>(
                builder: (context, state) {

                  if (state is NotificationLoading) {
                    return const ShimmerList(card: ShimmerNotificationCard(), count: 6);
                  }

                  if (state is NotificationLoaded) {
                    final notifications =
                        state.notifications;

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.notifications_none_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No notifications yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 6, 16, 20),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {

                        final item = notifications[index];

                        return Container(
                          margin:
                          const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.05),
                                blurRadius: 14,
                                offset:
                                const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: NotificationCard(
                            title: item["title"] ?? "",
                            message: item["message"] ?? "",
                            time: item["createdDate"] != null
                                ? item["createdDate"]
                                .toString()
                                .substring(0, 16)
                                : "",
                            isRead:
                            item["isRead"] ?? false,
                          ),
                        );
                      },
                    );
                  }

                  if (state is NotificationFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
