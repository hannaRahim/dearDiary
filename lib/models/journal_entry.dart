class JournalEntry {
  final int? id; // id is nullable for new entries
  final String title;
  final String content;
  final String date; 
  final String? mood;         
  final String? hashtags;
  final String? imagePath;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.mood,
    this.hashtags,
    this.imagePath,
  });

  // Convert a JournalEntry into a Map. The keys must match the database column names.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'hashtags': hashtags,
      'imagePath': imagePath,
    };
  }

  // Convert a Map into a JournalEntry
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      mood: map['mood'],
      hashtags: map['hashtags'],
      imagePath: map['imagePath'],
    );
  }
}
