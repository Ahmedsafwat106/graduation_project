import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/notification/NotificationState.dart';
import '../features/notification/notification_cubit.dart';
import '../models/NotificationCard.dart';


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

            /// HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: BlocBuilder<
                  NotificationCubit,
                  NotificationState>(
                builder: (context, state) {

                  if (state is NotificationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is NotificationLoaded) {

                    final notifications =
                        state.notifications;

                    if (notifications.isEmpty) {
                      return const Center(
                        child:
                        Text("No notifications yet"),
                      );
                    }

                    return ListView.builder(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 16),
                      itemCount:
                      notifications.length,
                      itemBuilder:
                          (context, index) {

                        final item =
                        notifications[index];

                        return NotificationCard(
                          title:
                          item["title"] ?? "",
                          message:
                          item["message"] ?? "",
                          time: item["createdDate"] != null
                              ? item["createdDate"].toString().substring(0, 16)
                              : "",
                          isRead:
                          item["isRead"] ?? false,
                        );
                      },
                    );
                  }

                  if (state is NotificationFailure) {
                    return Center(
                      child: Text(state.message),
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