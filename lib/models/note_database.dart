import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static Isar? _isar;
  bool _showHiddenNotes = false;
  bool _isFetching = false;
  Timer? _fetchDebounceTimer;

  // Initialize the Isar database
  static Future<void> initialise() async {
    if (_isar != null) return;
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
    fetchNotes(); // Debounced fetching to prevent UI lag
  }

  // List of notes
  final List<Note> currentNotes = [];

  // Create a new blank note with timestamps
  Future<Note> createBlankNote() async {
    await initialise();
    final newNote = Note()
      ..title = ''
      ..description = ''
      ..isHidden = _showHiddenNotes
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    try {
      await _isar!.writeTxn(() async {
        await _isar!.notes.put(newNote);
      });
    } catch (e) {
      print('Error creating note: $e');
    }

    return newNote;
  }

  // Update an existing note with new content and update the last edited time
  Future<void> updateNote(
    Id id,
    String title,
    String description, {
    bool? isHidden,
    List<String>? imagePaths,
  }) async {
    await initialise();
    final note = await _isar!.notes.get(id);
    if (note != null) {
      note
        ..title = title
        ..description = description
        ..isHidden = isHidden ?? note.isHidden
        ..updatedAt = DateTime.now();
      if (imagePaths != null) {
        note.imagePaths = imagePaths;
      }

      try {
        await _isar!.writeTxn(() async {
          await _isar!.notes.put(note);
        });
        print('Saving note with imagePaths: ${note.imagePaths}');
      } catch (e) {
        print('Error updating note: $e');
      }
    }

    fetchNotes();
  }

  // Fetch all notes based on visibility mode with debouncing
  void fetchNotes() {
    if (_fetchDebounceTimer?.isActive ?? false) {
      _fetchDebounceTimer!.cancel();
    }
    _fetchDebounceTimer = Timer(Duration(milliseconds: 500), () async {
      await _fetchNotes();
    });
  }

  Future<void> _fetchNotes() async {
    if (_isFetching) return;

    _isFetching = true;
    try {
      await initialise();

      List<Note> fetchedNotes;
      if (_showHiddenNotes) {
        fetchedNotes = await _isar!.notes.where().findAll();
      } else {
        fetchedNotes = await _isar!.notes
            .where()
            .filter()
            .isHiddenEqualTo(false)
            .findAll();
      }

      for (var note in fetchedNotes) {
        note.imagePaths ??= [];
        print('Fetched note with imagePaths: ${note.imagePaths}');
      }

      currentNotes.clear();
      currentNotes.addAll(fetchedNotes);
      notifyListeners();
    } catch (e) {
      print('Error fetching notes: $e');
    } finally {
      _isFetching = false;
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    await initialise();
    try {
      await _isar!.writeTxn(() async {
        await _isar!.notes.delete(id);
      });
      fetchNotes();
    } catch (e) {
      print('Error deleting note: $e');
    }
  }
}
