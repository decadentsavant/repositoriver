import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:main/models/note.dart';
import 'package:main/repositories/note_repository.dart';

/// A concrete implementation of [NoteRepository] that uses a file for storage.
class FileNoteRepository implements NoteRepository {
  /// Constructs a [FileNoteRepository] with the given file path.
  FileNoteRepository({required this.filePath});

  /// Constructs a [FileNoteRepository] with the given file path.
  ///
  /// The [filePath] is where the note data will be stored in the file system.
  final String filePath;

  /// Adds a [Note] to the storage.
  @override
  Future<void> add(Note note) async {
    final file = File(filePath);
    final notes = await getAll();
    notes.add(note);
    await file.writeAsString(const JsonEncoder().convert(notes));
  }

  /// Deletes a [Note] by its `id` from the storage.
  @override
  Future<void> delete(String id) async {
    final file = File(filePath);
    final notes = await getAll();
    notes.removeWhere((note) => note.id == id);
    await file.writeAsString(const JsonEncoder().convert(notes));
  }

  /// Retrieves all notes from the storage.
  @override
  Future<List<Note>> getAll() async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return [];
    }
    final data = file.readAsStringSync();
    final list = const JsonDecoder().convert(data) as List<dynamic>;
    return list
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
