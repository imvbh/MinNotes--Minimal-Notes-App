import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:minimal_notes_app/models/note_database.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class NoteEditPage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Note? note;
  final bool showHiddenNotes;

  const NoteEditPage({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    this.note,
    required this.showHiddenNotes,
  }) : super(key: key);

  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  int _formattingStyle = 0;
  bool _isHidden = false;
  Note? _currentNote;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _isHidden = widget.note!.isHidden;
      widget.titleController.text = widget.note!.title;
      widget.descriptionController.text = widget.note!.description;
      _currentNote = widget.note;
    } else {
      _isHidden = widget.showHiddenNotes;
      _initializeBlankNote(); // Create a blank note asynchronously when no note exists
    }

    // Listen to title and description changes to auto-save
    widget.titleController.addListener(_autoSaveNote);
    widget.descriptionController.addListener(_autoSaveNote);
  }

  Future<void> _initializeBlankNote() async {
    _currentNote = await _createBlankNote();
  }

  Future<Note> _createBlankNote() async {
    return await context.read<NoteDatabase>().createBlankNote();
  }

  String formatTimestamp(DateTime timestamp) {
    DateTime now = DateTime.now();

    if (timestamp.year == now.year) {
      if (timestamp.day == now.day && timestamp.month == now.month) {
        return DateFormat('h:mm a').format(timestamp); // Same day
      } else {
        return DateFormat('d MMM, h:mm a')
            .format(timestamp); // Same year, different day
      }
    } else {
      return DateFormat('d MMM yyyy, h:mm a')
          .format(timestamp); // Different year
    }
  }

  String formatFullDate(DateTime timestamp) {
    return DateFormat('d MMM, yyyy  h:mm a').format(timestamp);
  }

  @override
  void dispose() {
    // Remove listeners when the widget is disposed
    widget.titleController.removeListener(_autoSaveNote);
    widget.descriptionController.removeListener(_autoSaveNote);
    super.dispose();
  }

  // Automatically save the note as the user types
  Future<void> _autoSaveNote() async {
    if (_currentNote != null) {
      await context.read<NoteDatabase>().updateNote(
            _currentNote!.id,
            widget.titleController.text,
            widget.descriptionController.text,
            isHidden: _isHidden,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.inversePrimary,
                size: 25,
              ),
              onPressed: () => Navigator.pop(context), // Just close the page
            ),
          )
        ],
        title: Text(
          widget.note == null
              ? 'New Note'
              : 'Edited ${formatTimestamp(_currentNote!.updatedAt)}',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.note == null
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).colorScheme.secondary),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                      child: TextField(
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                        controller: widget.titleController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).colorScheme.surface,
                            hintText: 'Title...',
                            hintStyle: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    ),
                    if (_currentNote != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                        child: Text(
                          '${formatFullDate(_currentNote!.createdAt)}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                      child: TextField(
                        controller: widget.descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).colorScheme.surface,
                            hintText: 'Description...',
                            hintStyle: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: BottomAppBar(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.list),
                      onPressed: () {
                        setState(() {
                          _formattingStyle = (_formattingStyle + 1) % 3;
                        });

                        String text = widget.descriptionController.text;

                        List<String> lines = text.split('\n');

                        switch (_formattingStyle) {
                          case 0: // plain text
                            text = lines
                                .map((line) =>
                                    line.replaceAll(RegExp(r'^- |^\d+\. '), ''))
                                .join('\n');
                            break;
                          case 1: // point list
                            text = lines
                                .map((line) =>
                                    '- ' +
                                    line.replaceAll(RegExp(r'^- |^\d+\. '), ''))
                                .join('\n');
                            break;
                          case 2: // numbered list
                            text = lines
                                .asMap()
                                .entries
                                .map((entry) =>
                                    '${entry.key + 1}. ' +
                                    entry.value
                                        .replaceAll(RegExp(r'^- |^\d+\. '), ''))
                                .join('\n');
                            break;
                        }

                        widget.descriptionController.text = text;
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _requestPermissionAndPickImage();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _requestPermissionAndRecordAudio();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _isHidden ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isHidden = !_isHidden;
                          if (_currentNote != null) {
                            context.read<NoteDatabase>().updateNote(
                                  _currentNote!.id,
                                  widget.titleController.text,
                                  widget.descriptionController.text,
                                  isHidden: _isHidden,
                                );
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissionAndPickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Handle the selected image
      }
    } else {
      // Handle permission denied
    }
  }

  Future<void> _requestPermissionAndRecordAudio() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      // Handle audio recording
    } else {
      // Handle permission denied
    }
  }
}
