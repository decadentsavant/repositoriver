import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Note model
class Note {
  Note(this.id, this.content);
  final String id;
  final String content;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }

  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      json['id'] as String,
      json['content'] as String,
    );
  }

  @override
  String toString() => '$id: $content';
}

// Note repository interface
abstract class NoteRepository {
  Future<void> add(Note note);
  Future<void> delete(String id);
  Future<List<Note>> getAll();
}

// File-based implementation of NoteRepository
class FileNoteRepository implements NoteRepository {
  FileNoteRepository({required this.filePath});
  final String filePath;

  @override
  Future<void> add(Note note) async {
    final file = File(filePath);
    final notes = await getAll();
    notes.add(note);
    await file.writeAsString(JsonEncoder().convert(notes));
  }

  @override
  Future<void> delete(String id) async {
    final file = File(filePath);
    final notes = await getAll();
    notes.removeWhere((note) => note.id == id);
    await file.writeAsString(JsonEncoder().convert(notes));
  }

  @override
  Future<List<Note>> getAll() async {
    final file = File(filePath);
    if (!await file.exists()) {
      return [];
    }
    final data = await file.readAsString();
    final List<dynamic> list = JsonDecoder().convert(data);
    return list.map((json) => Note.fromJson(json)).toList();
  }
}

// Provider-like class to manage state
class NoteProvider {
  List<Note> _notes = [];

  void setState(List<Note> notes) {
    _notes = notes;
  }

  List<Note> getState() {
    return _notes;
  }
}

// BLoC-like class to manage business logic
class NoteBloc {
  NoteBloc({required this.noteRepository, required this.noteProvider});
  final NoteRepository noteRepository;
  final NoteProvider noteProvider;

  Future<void> add(Note note) async {
    await noteRepository.add(note);
    await _updateProviderState();
  }

  Future<void> delete(String id) async {
    await noteRepository.delete(id);
    await _updateProviderState();
  }

  Future<void> _updateProviderState() async {
    final notes = await noteRepository.getAll();
    noteProvider.setState(notes);
  }
}

class CliService {
  CliService(this.noteBloc);

  final NoteBloc noteBloc;

  Future<void> run() async {
    while (true) {
      print('What would you like to do? (add/list/delete/quit)');
      final command = stdin.readLineSync();

      await switch (command) {
        'add' => _addNote(),
        'list' => _listNotes(),
        'delete' => _deleteNote(),
        'quit' => Future.value(null),
        _ => Future(() {
            print('Unknown command');
          }),
      };

      if (command == 'quit') {
        break;
      }
    }
  }

  Future<void> _addNote() async {
    print('Enter the note id:');
    final id = stdin.readLineSync();
    print('Enter the note content:');
    final content = stdin.readLineSync();
    await noteBloc.add(Note(id ?? '', content ?? ''));
    print('Note added.');
  }

  Future<void> _listNotes() async {
    final notes = noteBloc.noteProvider.getState();
    print('Your notes:');
    for (var note in notes) {
      print(note);
    }
  }

  Future<void> _deleteNote() async {
    print('Enter the id of the note to delete:');
    final id = stdin.readLineSync();
    await noteBloc.delete(id ?? '');
    print('Note deleted.');
  }
}

void main() async {
  // Dependencies
  final noteRepository = FileNoteRepository(filePath: 'notes_data.json');
  final noteProvider = NoteProvider();
  final noteBloc =
      NoteBloc(noteRepository: noteRepository, noteProvider: noteProvider);

  // CLI Service
  final cliService = CliService(noteBloc);
  await cliService.run();
}
