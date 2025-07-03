import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<JournalEntry> _entries = [];
  int totalEntries = 0;
  int streakDays = 0;
  int photoCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final entries = await DatabaseService().getEntries();
    final uniqueDates = <String>{};
    int photoCounter = 0;

    for (var entry in entries) {
      final dateOnly = DateTime.parse(entry.date).toIso8601String().split('T').first;
      uniqueDates.add(dateOnly);

      if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
        photoCounter++;
      }
    }

    setState(() {
      _entries = entries;
      totalEntries = entries.length;
      streakDays = uniqueDates.length;
      photoCount = photoCounter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Handle logout
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hi, Siti!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Entries: $totalEntries',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // My Records Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Records',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRecordCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$streakDays days',
                  color: Colors.orange.shade100,
                ),
                _buildRecordCard(
                  icon: Icons.photo_library,
                  label: 'Photos',
                  value: '$photoCount',
                  color: Colors.purple.shade100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.black54),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}
