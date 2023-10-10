// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:main/bloc/note_bloc.dart';
import 'package:main/models/note.dart';
import 'package:main/providers/note_provider.dart';
import 'package:main/utils/noteObserver.dart';

/// Command-line service for interacting with the NoteBloc.
///
/// Implements the [NoteObserver] interface to listen for changes in the notes
/// state.
class CliService implements NoteObserver {
  /// Initializes a new instance of [CliService] with a given [NoteBloc].
  ///
  /// Subscribes this service as an observer to the [NoteBloc]'s NoteProvider.
  CliService(this.noteBloc) {
    noteBloc.noteProvider.addObserver(this);
  }

  /// Reference to the [NoteBloc] used to manipulate and fetch notes.
  final NoteBloc noteBloc;

  @override
  void update(List<Note> newState) {
    print('State updated! Current notes:');
    for (final note in newState) {
      print(note);
    }
  }

  /// Starts the CLI service, awaiting user input for commands.
  ///
  /// Listens for commands such as 'add', 'list', 'delete', and 'quit'
  /// to interact with the notes. This method runs asynchronously and
  /// will keep running until the user inputs 'quit'.
  Future<void> run() async {
    while (true) {
      print('What would you like to do? (add/list/delete/quit)');
      final command = stdin.readLineSync();

      await switch (command) {
        'add' => _addNote(),
        'list' => _listNotes(),
        'delete' => _deleteNote(),
        // ignore: avoid_redundant_argument_values
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
    for (final note in notes) {
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
