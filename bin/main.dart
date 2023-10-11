import 'package:main/bloc/note_bloc.dart';
import 'package:main/cli/cli_service.dart';
import 'package:main/providers/note_provider.dart';
import 'package:main/repositories/implementations/file_note_repository.dart';

void main() async {
  // Dependencies
  final noteRepository = FileNoteRepository(filePath: 'notes_data.json');
  final noteProvider = NoteProvider();
  final noteBloc = await NoteBloc.createAsync(
      noteRepository: noteRepository, noteProvider: noteProvider,);

  // CLI Service
  final cliService = CliService(noteBloc);
  await cliService.run();
}
