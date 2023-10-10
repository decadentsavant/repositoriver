import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Note model
class Note {
  final String id;
  final String content;

  Note(this.id, this.content);

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
    List<Note> notes = await getAll();

    notes.add(note);
    await file.writeAsString(JsonEncoder().convert(notes));
  }

  @override
  Future<void> delete(String id) async {
    final file = File(filePath);
    List<Note> notes = await getAll();

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

// Custom Provider class similar to Riverpod
class Provider<T> {
  Provider(this.state);
  T state;

  void setState(T newState) {
    state = newState;
  }
}

// CliService class with state management
class CliService {
  final Provider<List<Note>> notesProvider;
  final NoteRepository noteRepository;

  CliService(this.notesProvider, this.noteRepository);

  Future<void> run() async {
    while (true) {
      print('What would you like to do? (add/list/delete/quit)');
      var command = stdin.readLineSync();

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
    var id = stdin.readLineSync();
    print('Enter the note content:');
    var content = stdin.readLineSync();

    await noteRepository.add(Note(id ?? '', content ?? ''));

    // Update local state
    notesProvider.setState(await noteRepository.getAll());

    print('Note added.');
  }

  Future<void> _listNotes() async {
    print('Your notes:');
    for (var note in notesProvider.state) {
      print(note);
    }
  }

  Future<void> _deleteNote() async {
    print('Enter the id of the note to delete:');
    var id = stdin.readLineSync();

    await noteRepository.delete(id ?? '');

    // Update local state
    notesProvider.setState(await noteRepository.getAll());

    print('Note deleted.');
  }

  // Update state on initialization
  Future<void> initialize() async {
    notesProvider.setState(await noteRepository.getAll());
  }
}

void main() async {
  // File Dependency Injection
  final noteRepository = FileNoteRepository(filePath: 'notes_data.json');

  // Initialize notes state
  final notesProvider = Provider<List<Note>>([]);

  // Initialize CLI service with provider and repository
  final cliService = CliService(notesProvider, noteRepository);

  // Fetch initial state
  await cliService.initialize();

  // Run the CLI service
  await cliService.run();
}
