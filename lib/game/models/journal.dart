class JournalEntry {
  final DateTime time;
  final String text;

  const JournalEntry({required this.time, required this.text});

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'text': text,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        time: DateTime.parse(json['time'] as String),
        text: json['text'] as String,
      );
}
