// ignore_for_file: one_member_abstracts

import 'package:main/models/note.dart';

/// Defines a contract for objects that wish to be notified of state changes.
///
/// Classes implementing this abstract class must provide an implementation for 
/// [update].
abstract class Observer {
  /// Called to notify the implementing object that the state has been updated.
  ///
  /// The [newState] parameter contains the updated list of [Note] objects.
  void update(List<Note> newState);
}


/// Manages the state of [Note] instances and notifies registered observers.
class NoteProvider {
  List<Note> _notes = [];
  final List<Observer> _observers = [];

  /// Adds an observer to be notified when the state changes.
  void addObserver(Observer observer) {
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
