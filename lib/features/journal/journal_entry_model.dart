// lib/features/journal/journal_entry_model.dart
// Model cho 1 journal entry — Wave 2 premium feature.
// Persist qua JournalService (SharedPreferences, key: 'journal_entries').
//
// Design decisions:
//   - id: timestamp-based string (Wave 3: replace với UUID)
//   - streakDay: snapshot ngày streak tại thời điểm viết (immutable sau khi save)
//   - mood: nullable — user không bắt buộc phải chọn mood
//   - body: không có maxLength ở model layer, UI tự enforce nếu cần

class JournalMood {
  const JournalMood._(this.value, this.emoji, this.label);

  final String value;
  final String emoji;
  final String label;

  static const calm = JournalMood._('calm', '😌', 'Calm');
  static const motivated = JournalMood._('motivated', '💪', 'Motivated');
  static const anxious = JournalMood._('anxious', '😰', 'Anxious');
  static const tempted = JournalMood._('tempted', '😬', 'Tempted');
  static const proud = JournalMood._('proud', '🙂', 'Proud');
  static const neutral = JournalMood._('neutral', '😐', 'Neutral');

  static const all = [calm, motivated, anxious, tempted, proud, neutral];

  static JournalMood? fromValue(String? value) {
    if (value == null) return null;
    for (final m in all) {
      if (m.value == value) return m;
    }
    return null;
  }

  @override
  String toString() => value;
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.streakDay,
    required this.body,
    this.mood,
  });

  /// Unique ID — ISO8601 timestamp string (ms precision).
  /// Dùng làm key trong JSON map và sort key.
  final String id;

  /// Thời điểm tạo entry.
  final DateTime createdAt;

  /// Snapshot streak day tại lúc viết — không thay đổi dù streak reset sau đó.
  final int streakDay;

  /// Nội dung entry. Không được rỗng khi save.
  final String body;

  /// Mood tuỳ chọn — null nếu user không chọn.
  final JournalMood? mood;

  // ─────────────────────────────────────────────
  // FACTORY
  // ─────────────────────────────────────────────

  /// Tạo entry mới với id tự động từ timestamp hiện tại.
  factory JournalEntry.create({
    required int streakDay,
    required String body,
    JournalMood? mood,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();
    return JournalEntry(
      id: now.millisecondsSinceEpoch.toString(),
      createdAt: now,
      streakDay: streakDay,
      body: body,
      mood: mood,
    );
  }

  // ─────────────────────────────────────────────
  // JSON
  // ─────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'streak_day': streakDay,
        'body': body,
        'mood': mood?.value,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        streakDay: json['streak_day'] as int,
        body: json['body'] as String,
        mood: JournalMood.fromValue(json['mood'] as String?),
      );

  // ─────────────────────────────────────────────
  // COPY WITH
  // ─────────────────────────────────────────────

  JournalEntry copyWith({
    String? body,
    JournalMood? mood,
    bool clearMood = false,
  }) {
    return JournalEntry(
      id: id,
      createdAt: createdAt,
      streakDay: streakDay,
      body: body ?? this.body,
      mood: clearMood ? null : mood ?? this.mood,
    );
  }

  // ─────────────────────────────────────────────
  // DISPLAY HELPERS
  // ─────────────────────────────────────────────

  /// Preview text cho list — tối đa 80 ký tự.
  String get preview {
    if (body.length <= 80) return body;
    return '${body.substring(0, 77)}...';
  }

  @override
  String toString() =>
      'JournalEntry(id: $id, streakDay: $streakDay, mood: ${mood?.value})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is JournalEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
