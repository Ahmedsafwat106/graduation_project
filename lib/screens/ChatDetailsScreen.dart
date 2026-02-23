import 'package:flutter/material.dart';

class ChatDetailsScreen extends StatelessWidget {
  final int userId;
  final int jobId;

  const ChatDetailsScreen({
    super.key,
    required this.userId,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text("Chat Messages Here"),
      ),
    );
  }
}