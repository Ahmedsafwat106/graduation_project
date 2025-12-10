import 'package:flutter/material.dart';

class DeveloperHomeScreen extends StatefulWidget {
  const DeveloperHomeScreen({super.key});

  @override
  State<DeveloperHomeScreen> createState() => _DeveloperHomeScreenState();
}

class _DeveloperHomeScreenState extends State<DeveloperHomeScreen> {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // -------------------------
      // APP BAR
      // -------------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back 👋",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "Developer",
              style: TextStyle(
                fontSize: 22,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // -------------------------
      // BODY CONTENT
      // -------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 25),
            _buildJobList(),
          ],
        ),
      ),

      // -------------------------
      // NAVIGATION BAR
      // -------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (i) async {
          if (i == 2) {
            await Navigator.pushNamed(context, "/profile");
            setState(() => currentTab = 0);
            return;
          }
          setState(() => currentTab = i);
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Applications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // -------------------------
  // WIDGETS
  // -------------------------

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search for jobs...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tabButton("Jobs", 0),
        _tabButton("Applied", 1),
        _tabButton("Saved", 2),
      ],
    );
  }

  Widget _tabButton(String text, int index) {
    bool selected = currentTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => currentTab = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return Column(
      children: [
        _jobCard(
          company: "Google",
          title: "Flutter Developer",
          location: "California, USA",
          salary: "\$4k - \$7k",
        ),
        const SizedBox(height: 20),
        _jobCard(
          company: "Microsoft",
          title: "Backend Developer",
          location: "New York, USA",
          salary: "\$5k - \$8k",
        ),
        const SizedBox(height: 20),
        _jobCard(
          company: "Amazon",
          title: "UI/UX Designer",
          location: "Remote",
          salary: "\$3k - \$5k",
        ),
      ],
    );
  }

  Widget _jobCard({
    required String company,
    required String title,
    required String location,
    required String salary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(
                  company[0],
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                company,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 5),
              Text(location, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                salary,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
