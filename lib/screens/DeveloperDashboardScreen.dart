import 'package:flutter/material.dart';
import 'JobListScreen.dart';

class DeveloperDashboardScreen extends StatelessWidget {
  const DeveloperDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Developer Dashboard"),
          backgroundColor: Colors.green,
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Jobs"),
              Tab(text: "Recommended"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            JobListScreen(loadType: JobLoadType.all),
            JobListScreen(loadType: JobLoadType.recommended),
          ],
        ),
      ),
    );
  }
}