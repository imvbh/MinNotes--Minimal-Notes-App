import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static Isar? _isar;
  bool _showHiddenNotes = false;
  bool _isFetching = false; // To prevent redundant fetch operations

  // Initialize the Isar database
  static Future<void> initialise() async {
    if (_isar != null) return; // Check if _isar has already been initialized
    final dir = await getApplicationDocumentsDirectory();
    try {
      _isar = await Isar.open([NoteSchema], directory: dir.path);
    } catch (e) {
      print('Error initializing Isar database: $e');
    }
  }

  // Set the visibility of hidden notes
  void setShowHiddenNotes(bool showHiddenNotes) {
    _showHiddenNotes = showHiddenNotes;
    fetchNotes(debounce: true); // Debounced fetching to prevent UI lag
  }

  // List of notes
  final List<Note> currentNotes = [];

  // Create a new blank note with timestamps
  Future<Note> createBlankNote() async {
    await initialise(); // Ensure Isar is initialized
    final newNote = Note()
      ..title = ''
      ..description = ''
      ..isHidden = _showHiddenNotes
      ..createdAt = DateTime.now() // Set the creation time
      ..updatedAt = DateTime.now(); // Set the last updated time

    await _isar!.writeTxn(() async {
      await _isar!.notes.put(newNote);
    });

    return newNote;
  }

  // Update an existing note with new content and update the last edited time
  Future<void> updateNote(
    Id id,
    String title,
    String description, {
    bool? isHidden,
  }) async {
    await initialise();
    final note = await _isar!.notes.get(id);
    if (note != null) {
      note
        ..title = title
        ..description = description
        ..isHidden = isHidden ?? note.isHidden
        ..updatedAt = DateTime.now(); // Update the timestamp

      await _isar!.writeTxn(() async {
        await _isar!.notes.put(note);
      });
    }
    await fetchNotes(debounce: true);
  }

  // Fetch all notes based on visibility mode with debouncing
  Future<void> fetchNotes({bool debounce = false}) async {
    if (_isFetching) return; // Prevent redundant fetch calls

    if (debounce) {
      _isFetching = true;
      Future.delayed(Duration(milliseconds: 500), () async {
        await _fetchNotes();
        _isFetching = false;
      });
    } else {
      await _fetchNotes();
    }
  }

  Future<void> _fetchNotes() async {
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
