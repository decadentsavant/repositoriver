import 'dart:async';

import 'package:main/models/note.dart';
import 'package:main/providers/note_provider.dart';
import 'package:main/repositories/note_repository.dart';

/// Business logic component for managing notes.
///
/// Orchestrates communication between the [NoteRepository] and [NoteProvider].
class NoteBloc {
  /// Private constructor to initialize the [NoteBloc] instance.
  ///
  /// Use [NoteBloc.createAsync] factory method to create an instance.
  NoteBloc._(this.noteRepository, this.noteProvider);

  /// The [NoteRepository] instance responsible for data persistence.
  final NoteRepository noteRepository;

  /// The [NoteProvider] instance responsible for maintaining and notifying 
  /// state changes.
  final NoteProvider noteProvider;

  /// Asynchronously creates a new instance of [NoteBloc].
  static Future<NoteBloc> createAsync({
    required NoteRepository noteRepository,
    required NoteProvider noteProvider,
  }) async {
    final bloc = NoteBloc._(noteRepository, noteProvider);
    await bloc._updateProviderState();
    return bloc;
  }

  /// Private method to update the state in [NoteProvider] from 
  /// [NoteRepository].
  Future<void> _updateProviderState() async {
    final notes = await noteRepository.getAll();
    noteProvider.setState(notes);
  }

  /// Adds a new note.
  Future<void> add(Note note) async {
    await noteRepository.add(note);
    await _updateProviderState();
  }

  /// Deletes a note by its `id`.
  Future<void> delete(String id) async {
    await noteRepository.delete(id);
    await _updateProviderState();
  }
}
