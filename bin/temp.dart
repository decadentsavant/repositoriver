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

// NoteRepository interface
abstract class NoteRepository {
  Future<void> add(Note note);
  Future<void> delete(String id);
  Future<List<Note>> getAll();
}

// FileNoteRepository implementation
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

// NoteEvent definitions
abstract class NoteEvent {}

class AddNoteEvent extends NoteEvent {
  final Note note;
  AddNoteEvent(this.note);
}

class DeleteNoteEvent extends NoteEvent {
  final String id;
  DeleteNoteEvent(this.id);
}

class ListNotesEvent extends NoteEvent {}

// NoteState definitions
abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteList extends NoteState {
  final List<Note> notes;
  NoteList(this.notes);
}

// NoteBloc
class NoteBloc {
  final NoteRepository noteRepository;

  final StreamController<NoteEvent> _eventController =
      StreamController<NoteEvent>();
  final StreamController<NoteState> _stateController =
      StreamController<NoteState>.broadcast();

  Stream<NoteState> get stateStream => _stateController.stream;

  NoteBloc(this.noteRepository) {
    _eventController.stream.listen(_eventToState);
  }

  void _eventToState(NoteEvent event) async {
    if (event is AddNoteEvent) {
      await noteRepository.add(event.note);
      final notes = await noteRepository.getAll();
      _stateController.sink.add(NoteList(notes));
    } else if (event is DeleteNoteEvent) {
      await noteRepository.delete(event.id);
      final notes = await noteRepository.getAll();
      _stateController.sink.add(NoteList(notes));
    } else if (event is ListNotesEvent) {
      final notes = await noteRepository.getAll();
      _stateController.sink.add(NoteList(notes));
    }
  }

  void addEvent(NoteEvent event) => _eventController.sink.add(event);

  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}

// CliService
class CliService {
  CliService(this.noteBloc);
  final NoteBloc noteBloc;

  Future<void> run() async {
    noteBloc.stateStream.listen((state) {
      if (state is NoteList) {
        print('Your notes:');
        for (var note in state.notes) {
          print(note);
        }
      }
    });

    while (true) {
      print('What would you like to do? (add/list/delete/quit)');
      var command = stdin.readLineSync();

      switch (command) {
        case 'add':
          print('Enter the note id:');
          var id = stdin.readLineSync();
          print('Enter the note content:');
          var content = stdin.readLineSync();
          noteBloc.addEvent(AddNoteEvent(Note(id ?? '', content ?? '')));
          break;
        case 'list':
          noteBloc.addEvent(ListNotesEvent());
          break;
        case 'delete':
          print('Enter the id of the note to delete:');
          var id = stdin.readLineSync();
          noteBloc.addEvent(DeleteNoteEvent(id ?? ''));
          break;
        case 'quit':
          noteBloc.dispose();
          return;
        default:
          print('Unknown command');
      }
    }
  }
}

// main function
void main() async {
  final noteRepository = FileNoteRepository(filePath: 'notes_data.json');
  final noteBloc = NoteBloc(noteRepository);
  final cliService = CliService(noteBloc);

  await cliService.run();
}
