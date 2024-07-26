import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar isar;

  // Initialise
  static Future<void> initialise() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([NoteSchema], directory: dir.path);
  }

  // List of notes
  final List<Note> currentNotes = [];

  // Create
  Future<void> addNote(String title, String description) async {
    // Create
    final newNote = Note()
      ..title = title
      ..description = description;
    // Save to db
    await isar.writeTxn(() => isar.notes.put(newNote));
    // Re-read from db
    await fetchNotes();
  }

  // Read
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  // Update
  Future<void> updateNote(int id, String newTitle, String newDescription) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      existingNote.title = newTitle;
      existingNote.description = newDescription;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  // Delete
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}
