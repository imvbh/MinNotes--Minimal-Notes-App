import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:pattern_lock/pattern_lock.dart';

class HiddenNotesPatternPage extends StatefulWidget {
  @override
  _HiddenNotesPatternPageState createState() => _HiddenNotesPatternPageState();
}

class _HiddenNotesPatternPageState extends State<HiddenNotesPatternPage> {
  List<int> _pattern = [];
  List<int> _confirmPattern = [];
  bool _isSettingPattern = true;
  bool _isConfirmingPattern = false;

  late Isar _isar;
  late IsarCollection<Note> _noteCollection;

  @override
  void initState() {
    super.initState();
    _initIsar();
  }

  _initIsar() async {
    _isar = await Isar.open([NoteSchema], directory: 'db'); // Specify the directory
    _noteCollection = _isar.collection<Note>();
    _loadPatternFromDatabase();
  }

  _loadPatternFromDatabase() async {
    final notes = await _noteCollection.where().findAll();
    if (notes.isNotEmpty) {
      final storedPattern = notes.first.pattern;
      _pattern = storedPattern.split('').map(int.parse).toList();
      setState(() {
        _isSettingPattern = false;
      });
    }
  }

  _savePatternToDatabase() async {
  final notes = await _noteCollection.where().findAll();
  if (notes.isNotEmpty) {
    final note = notes.first;
    note.pattern = _pattern.join();
    await _noteCollection.put(note);
  } else {
    final note = Note()..pattern = _pattern.join();
    await _noteCollection.put(note);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Access Hidden Notes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _isSettingPattern && _pattern.isEmpty
                  ? "Set a pattern to access hidden notes:"
                  : _isConfirmingPattern
                      ? "Confirm your pattern:"
                      : "Draw your pattern to access hidden notes:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300, // specify a height for the PatternLock widget
              child: PatternLock(
                notSelectedColor: Theme.of(context).colorScheme.inversePrimary,
                selectedColor: Theme.of(context).colorScheme.inversePrimary,
                pointRadius: 5,
                fillPoints: true,
                onInputComplete: (pattern) {
                  setState(() {
                    if (_isSettingPattern) {
                      _pattern = pattern;
                      _isSettingPattern = false;
                      _isConfirmingPattern = true;
                    } else if (_isConfirmingPattern) {
                      _confirmPattern = pattern;
                      if (_pattern.join() == _confirmPattern.join()) {
                        // Pattern confirmed, save it and navigate back
                        _savePatternToDatabase();
                        Navigator.pop(context, true);
                      } else {
                        // Pattern not confirmed, show error message
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Patterns do not match'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _isSettingPattern = true;
                                      _isConfirmingPattern = false;
                                    });
                                  },
                                  child: const Text('Try again'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      // Check if the pattern is correct
                      if (pattern.join() == _pattern.join()) {
                        Navigator.pop(context,
                            true); // Pass true to indicate pattern is correct
                      } else {
                        Navigator.pop(context);
                        // Pattern is incorrect, show error message
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Incorrect pattern'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
