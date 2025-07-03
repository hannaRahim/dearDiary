import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_entry.dart';

class DatabaseService {
  // Get the Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // Since we are using Supabase, the local database instance is no longer needed.
  // We can remove the static _instance and _database, and the _internal constructor
  // if this class will solely be for Supabase operations.
  // For simplicity, we'll keep it as a singleton for now but modify its behavior.

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // No need for _initDB or _createDB methods with Supabase.
  // The table is created directly in the Supabase dashboard.

  // Insert a journal entry into Supabase
  Future<int> insertEntry(JournalEntry entry) async {
    try {
      // Supabase automatically handles the 'id' for auto-incrementing columns.
      // We don't send the 'id' when inserting a new entry.
      final response = await _supabase.from('journal_entries').insert({
        'title': entry.title,
        'content': entry.content,
        'date': entry.date,
        'mood': entry.mood,
        'hashtags': entry.hashtags,
        'imagePath': entry.imagePath,
      }).select('id'); // Select the 'id' to return it

      if (response.isNotEmpty && response.first['id'] != null) {
        return response.first['id'] as int;
      } else {
        throw Exception('Failed to insert entry: No ID returned');
      }
    } catch (e) {
      print('Error inserting entry: $e');
      rethrow; // Re-throw the exception for error handling in UI
    }
  }

  // Retrieve all journal entries from Supabase
  Future<List<JournalEntry>> getEntries() async {
    try {
      // Fetch all entries, ordered by 'id' in descending order (most recent first)
      final List<Map<String, dynamic>> data = await _supabase
          .from('journal_entries')
          .select('*') // Select all columns
          .order('id', ascending: false); // Order by id descending

      return data.map((map) => JournalEntry.fromMap(map)).toList();
    } catch (e) {
      print('Error retrieving entries: $e');
      rethrow;
    }
  }

  // Delete an entry by ID from Supabase
  Future<int> deleteEntry(int id) async {
    try {
      await _supabase.from('journal_entries').delete().eq('id', id);
      return 1; // Return 1 to indicate success (similar to sqflite's return)
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }

  // (Optional) Update an entry in Supabase
  Future<int> updateEntry(JournalEntry entry) async {
    try {
      await _supabase.from('journal_entries').update({
        'title': entry.title,
        'content': entry.content,
        'date': entry.date,
        'mood': entry.mood,
        'hashtags': entry.hashtags,
        'imagePath': entry.imagePath,
      }).eq('id', entry.id);
      return 1; // Return 1 to indicate success
    } catch (e) {
      print('Error updating entry: $e');
      rethrow;
    }
  }
}
