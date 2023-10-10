// ignore_for_file: one_member_abstracts

import 'package:main/models/note.dart';

/// Defines a contract for objects that wish to be notified of state changes.
///
/// Classes implementing this abstract class must provide an implementation for
/// [update].
abstract class NoteObserver {
  /// Called to notify the implementing object that the state has been updated.
  ///
  /// The [newState] parameter contains the updated list of [Note] objects.
  void update(List<Note> newState);
}
