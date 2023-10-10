/// A model representing a note.
///
/// Contains an `id` and `content`.
class Note {
  /// Creates a new [Note] instance with the given `id` and `content`.
  Note(this.id, this.content);

  /// Creates a [Note] instance from a JSON map.
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      json['id'] as String,
      json['content'] as String,
    );
  }

  /// The unique identifier for this note.
  final String id;

  /// The content or text of the note.
  final String content;

  /// Converts the [Note] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }
}
