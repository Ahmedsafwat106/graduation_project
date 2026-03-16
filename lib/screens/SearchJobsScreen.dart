import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchJobsScreen extends StatefulWidget {
  final List jobs;

  const SearchJobsScreen({super.key, required this.jobs});

  @override
  State<SearchJobsScreen> createState() => _SearchJobsScreenState();
}

class _SearchJobsScreenState extends State<SearchJobsScreen> {

  List filteredJobs = [];
  List<String> recentSearches = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    filteredJobs = widget.jobs;
    loadRecent();
  }

  Future<void> loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList("recent_searches") ?? [];
    });
  }

  Future<void> saveRecent(String value) async {
    final prefs = await SharedPreferences.getInstance();

    if (!recentSearches.contains(value)) {
      recentSearches.insert(0, value);
    }

    await prefs.setStringList("recent_searches", recentSearches);
  }

  void search(String value) {

    setState(() {
      query = value;

      filteredJobs = widget.jobs.where((job) {

        final name =
        (job["title"] ??
            job["jobName"] ??
            job["company_name"] ??
            "")
            .toString()
            .toLowerCase();

        return name.contains(value.toLowerCase());

      }).toList();
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1FA463),
        elevation: 0,
        title: TextField(
          autofocus: true,
          onChanged: search,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              saveRecent(value);
            }
          },
          decoration: const InputDecoration(
            hintText: "Search jobs...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [

          if (query.isEmpty && recentSearches.isNotEmpty)

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Recent Searches",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    children: recentSearches.map((text) {

                      return ActionChip(
                        label: Text(text),
                        onPressed: () {
                          search(text);
                        },
                      );

                    }).toList(),
                  ),

                ],
              ),
            ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),

              child: ListView.builder(
                key: ValueKey(filteredJobs.length),
                padding: const EdgeInsets.all(16),
                itemCount: filteredJobs.length,

                itemBuilder: (context, index) {

                  final job = filteredJobs[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        )
                      ],
                    ),

                    child: ListTile(
                      leading: const Icon(
                        Icons.work_outline,
                        color: Color(0xFF1FA463),
                      ),

                      title: Text(
                        job["title"] ??
                            job["jobName"] ??
                            "Unknown Job",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        job["location"] ?? "Unknown location",
                      ),
                    ),
                  );

                },
              ),
            ),
          ),

        ],
      ),
    );
  }
}