// ignore_for_file: one_member_abstracts

import 'package:main/models/note.dart';
import 'package:main/utils/note_observer.dart';

/// Manages the state of [Note] instances and notifies registered observers.
class NoteProvider {
  List<Note> _notes = [];
  final List<NoteObserver> _observers = [];

  /// Adds an observer to be notified when the state changes.
  void addObserver(NoteObserver observer) {
    _observers.add(observer);
  }

  /// Updates the state and notifies all registered observers.
  void setState(List<Note> notes) {
    _notes = notes;
    _notifyObservers();
  }

  /// Gets the current state.
  List<Note> getState() {
    return _notes;
  }

  /// Notifies all registered observers with the current state.
  void _notifyObservers() {
    for (final observer in _observers) {
      observer.update(_notes);
    }
  }
}
