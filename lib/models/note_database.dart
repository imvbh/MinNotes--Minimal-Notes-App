import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static Isar? _isar;

  // Initialise
  static Future<void> initialise() async {
    if (_isar != null) return; // Check if _isar has already been initialized
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([NoteSchema], directory: dir.path);
  }

  // List of notes
  final List<Note> currentNotes = [];

  // Create
  Future<void> addNote(String title, String description) async {
    await initialise(); // Ensure isar is initialized
    // Create
    final newNote = Note()
      ..title = title
      ..description = description;
    // Save to db
    await _isar!.writeTxn(() => _isar!.notes.put(newNote));
    // Re-read from db
    await fetchNotes();
  }

  // Read
  Future<void> fetchNotes() async {
    await initialise(); // Ensure isar is initialized
    List<Note> fetchedNotes = await _isar!.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

// Update
Future<void> updateNote(
    int id, String newTitle, String newDescription) async {
  await initialise(); // Ensure isar is initialized
  final existingNote = await _isar!.notes.get(id);
  if (existingNote != null) {
    // Directly modify the existing note object
    existingNote.title = newTitle;
    existingNote.description = newDescription;

    await _isar!.writeTxn(() => _isar!.notes.put(existingNote));
    await fetchNotes();
  }
}


  // Delete
  Future<void> deleteNote(int id) async {
    await initialise(); // Ensure isar is initialized
    await _isar!.writeTxn(() => _isar!.notes.delete(id));
    await fetchNotes();
  }
}
