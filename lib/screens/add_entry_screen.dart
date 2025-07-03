import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

import '../models/journal_entry.dart';
import '../services/database_service.dart';

class AddEntryScreen extends StatefulWidget {
  final String? initialMood;
  const AddEntryScreen({super.key, this.initialMood});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  String? selectedMood; // This will hold the selected mood string
  List<String> selectedHashtags = [];

  int _selectedIndex = 1;

  // Define the list of moods with emojis and labels
  final List<Map<String, String>> moods = [
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😠', 'label': 'Angry'},
    {'emoji': '😌', 'label': 'Relaxed'},
    {'emoji': '🤩', 'label': 'Excited'},
    {'emoji': '😍', 'label': 'Loved'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  final List<String> hashtags = [
    '#happy',
    '#sad',
    '#angry',
    '#relaxed',
    '#excited',
    '#loved',
    '#tired',
  ];

  @override
  void initState() {
    super.initState();
    // Set the initial mood if provided (e.g., from the home screen mood selection)
    selectedMood = widget.initialMood;
  }

  // Function to pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to toggle the selection of hashtags
  void _toggleHashtag(String tag) {
    setState(() {
      if (selectedHashtags.contains(tag)) {
        selectedHashtags.remove(tag);
      } else {
        selectedHashtags.add(tag);
      }
    });
  }

  // Function to save the journal entry
  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Validate if title and content are not empty
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    // Handle image upload to Supabase Storage
    String? imageUrl;
    if (_selectedImage != null) {
      try {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final String path = 'journal_images/$fileName'; // Folder and filename in storage

        // Upload the file to the 'journal-images' bucket
        await Supabase.instance.client.storage
            .from('journal-images') // Your bucket name
            .upload(path, _selectedImage!,
                fileOptions: const FileOptions(upsert: true));

        // Get the public URL of the uploaded image
        imageUrl = Supabase.instance.client.storage
            .from('journal-images')
            .getPublicUrl(path);

        print('Image uploaded to: $imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
        // Show an error message to the user if image upload fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
        return; // Prevent saving entry if image upload fails
      }
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    // Create a new JournalEntry object with all the collected data
    final newEntry = JournalEntry(
      title: title,
      content: content,
      date: formattedDate,
      mood: selectedMood, // Assign the selected mood
      hashtags: selectedHashtags.join(', '), // Save hashtags as a comma-separated string
      imagePath: imageUrl, // Save the Supabase image URL
    );

    try {
      // Insert the new entry into the database
      await DatabaseService().insertEntry(newEntry);
      Navigator.pop(context); // Go back to the previous screen (Home screen)
    } catch (e) {
      print('Error saving entry to database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save entry: $e')),
      );
    }
  }

  // Handles navigation bar taps
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pop(context); // Navigate back to Home screen
    }
    // No action for index 1 (Add screen itself)
    // No action for index 2 (Profile screen is handled by Home screen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood selection section
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Row of tappable mood emojis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: moods.map((mood) {
                      final bool isSelected = selectedMood == mood['label'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = mood['label']; // Update selected mood
                          });
                        },
                        child: AnimatedContainer( // Use AnimatedContainer for smooth transitions
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade100 // Highlight color
                                : Colors.grey.shade100, // Default soft color
                            borderRadius: BorderRadius.circular(16), // Rounded corners
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood['emoji']!,
                                style: const TextStyle(fontSize: 36), // Large emoji size
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood['label']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.blue.shade800 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24), // Add some space after mood selection

                  // Display selected mood (optional, as the icons themselves show selection)
                  if (selectedMood != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Current Mood: ${moods.firstWhere((m) => m['label'] == selectedMood)['emoji']} ${selectedMood!}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),

                  // Image preview section
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Title input field
                  const Text(
                    'Title',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Add a title to this entry',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content (Story) input field
                  const Text(
                    'Story',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: 'Write something...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mood Tags (Hashtags) section
                  const Text(
                    'Mood Tags',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hashtags.map((tag) {
                      final isSelected = selectedHashtags.contains(tag);
                      return GestureDetector(
                        onTap: () => _toggleHashtag(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.blue.shade800
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action bar (camera, gallery, save button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => _pickImage(ImageSource.camera),
                  tooltip: 'Take Photo',
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  tooltip: 'Pick from Gallery',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation bar
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
}
