import 'dart:async';
import 'package:main/models/note.dart';

/// An abstract class representing a repository for managing [Note] objects.
///
/// This serves as the contract that any concrete implementation should follow.
/// The interface outlines the methods required for adding, deleting, and 
/// retrieving notes.
abstract class NoteRepository {
  /// Adds a new note to the repository.
  ///
  /// Takes a [Note] object and stores it. Concrete implementations
  /// determine the method of storage and any other logic necessary for adding 
  /// the note.
  ///
  /// Throws an [Exception] if the note could not be added.
  Future<void> add(Note note);

  /// Deletes a note from the repository by its ID.
  ///
  /// Given an ID string, deletes the corresponding note from the repository.
  /// Concrete implementations should handle the details of how the deletion is 
  /// performed.
  ///
  /// Throws an [Exception] if the note could not be deleted.
  Future<void> delete(String id);

  /// Retrieves all stored notes.
  ///
  /// Returns a [Future] that resolves to a list of [Note] objects.
  /// The list represents all notes currently stored in the repository.
  /// Concrete implementations should handle the details of how the notes are 
  /// retrieved.
  ///
  /// Throws an [Exception] if the notes could not be retrieved.
  Future<List<Note>> getAll();
}
