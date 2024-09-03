import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static Isar? _isar;
  bool _showHiddenNotes = false; // Tracks whether hidden notes should be shown

  // Initialize the Isar database
  static Future<void> initialise() async {
    if (_isar != null) return; // Check if _isar has already been initialized
    final dir = await getApplicationDocumentsDirectory();
    try {
      _isar = await Isar.open([NoteSchema], directory: dir.path);
    } catch (e) {
      print('Error initializing Isar database: $e');
      // Handle the error as needed, possibly rethrow or log
    }
  }

  // Set the visibility of hidden notes
  void setShowHiddenNotes(bool showHiddenNotes) {
    _showHiddenNotes = showHiddenNotes;
    fetchNotes(); // Refresh the list of notes when visibility mode changes
    notifyListeners(); // Notify listeners to refresh the UI
  }

  // List of notes
  final List<Note> currentNotes = [];

  // Create a new note
  Future<void> addNote(String title, String description) async {
    await initialise(); // Ensure Isar is initialized
    try {
      final newNote = Note()
        ..title = title
        ..description = description
        ..isHidden = _showHiddenNotes; // Set isHidden based on app mode

      await _isar!.writeTxn(() async {
        await _isar!.notes.put(newNote);
      });
      await fetchNotes(); // Refresh the list of notes
    } catch (e) {
      print('Error adding note: $e');
      // Handle the error as needed
    }
  }

  // Fetch all notes based on visibility mode
  Future<void> fetchNotes() async {
    await initialise(); // Ensure Isar is initialized
    try {
      List<Note> fetchedNotes;
      if (_showHiddenNotes) {
        // Fetch all notes including hidden ones
        fetchedNotes = await _isar!.notes.where().findAll();
      } else {
        // Fetch only visible notes
        fetchedNotes = await _isar!.notes
            .where()
            .filter()
            .isHiddenEqualTo(false)
            .findAll();
      }
      currentNotes.clear();
      currentNotes.addAll(fetchedNotes);
      notifyListeners(); // Notify listeners to refresh the UI
    } catch (e) {
      print('Error fetching notes: $e');
      // Handle the error as needed
    }
  }

  // Update an existing note
  Future<void> updateNote(int id, String newTitle, String newDescription,
      {required bool isHidden}) async {
    await initialise(); // Ensure Isar is initialized
    try {
      final existingNote = await _isar!.notes.get(id);
      if (existingNote != null) {
        existingNote
          ..title = newTitle
          ..description = newDescription
          ..isHidden = isHidden; // Update isHidden based on provided parameter

        await _isar!.writeTxn(() async {
          await _isar!.notes.put(existingNote);
        });
        await fetchNotes(); // Refresh the list of notes
      }
    } catch (e) {
      print('Error updating note: $e');
      // Handle the error as needed
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    await initialise(); // Ensure Isar is initialized
    try {
      await _isar!.writeTxn(() async {
        await _isar!.notes.delete(id);
      });
      await fetchNotes(); // Refresh the list of notes
    } catch (e) {
      print('Error deleting note: $e');
      // Handle the error as needed
    }
  }
}
