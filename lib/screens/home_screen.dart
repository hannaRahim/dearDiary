import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/journal_entry.dart';
import 'add_entry_screen.dart';
import 'profile_screen.dart'; 
import '../widgets/journal_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<JournalEntry> _entries = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseService().getEntries();
    setState(() {
      _entries = entries;
    });
  }

  void _navigateToAddEntry(String mood) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(initialMood: mood),
      ),
    );
    _loadEntries(); // Refresh after returning
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      _navigateToAddEntry('Neutral'); 
    }
  }

  // Mood options
  final List<Map<String, String>> moods = [
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😠', 'label': 'Angry'},
    {'emoji': '😌', 'label': 'Relaxed'},
    {'emoji': '🤩', 'label': 'Excited'},
    {'emoji': '😍', 'label': 'Loved'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DearDiary'),
        centerTitle: true,
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _selectedIndex == 2
              ? const ProfileScreen()
              : const SizedBox(), // Empty when Add button is clicked
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'HELLO',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),

          // Mood slider
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: moods.length,
              itemBuilder: (context, index) {
                final mood = moods[index];
                return GestureDetector(
                  onTap: () => _navigateToAddEntry(mood['label']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            mood['emoji']!,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mood['label']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Recent Entries
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recent Entries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _entries.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No journal entries yet.")),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return JournalTile(
                      entry: entry,
                      onDelete: () => _deleteEntry(entry.id!),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _deleteEntry(int id) async {
    await DatabaseService().deleteEntry(id);
    _loadEntries();
  }
}
