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
  bool _isLoading = true; // New state variable to track loading status

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true; // Set loading to true when fetching starts
    });
    try {
      final entries = await DatabaseService().getEntries();
      setState(() {
        _entries = entries;
      });
    } catch (e) {
      print('Error loading entries: $e');
      // Optionally show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load entries: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when fetching completes (whether successful or not)
      });
    }
  }

  void _navigateToAddEntry(String? mood) async { // Made mood nullable to support FAB without initial mood
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

  // Mood options for the "How are you feeling?" section
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
              : const SizedBox(), // Empty when Add button is clicked, as FAB will handle it
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      // Floating Action Button for adding a new entry
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 2 // Show FAB on Home and Profile screens
          ? FloatingActionButton(
              onPressed: () => _navigateToAddEntry(null), // Navigate to AddEntryScreen without initial mood
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Makes it circular
              ),
            )
          : null, // Hide FAB when on the Add screen itself
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Position the FAB
    );
  }

  Widget _buildHomeContent() {
    return _isLoading // Show loading spinner if data is being fetched
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
