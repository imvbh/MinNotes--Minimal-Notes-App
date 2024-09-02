import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:minimal_notes_app/models/note_database.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                if (widget.note == null) {
                  context.read<NoteDatabase>().addNote(
                        widget.titleController.text,
                        widget.descriptionController.text,
                      );
                } else {
                  context.read<NoteDatabase>().updateNote(
                        widget.note!.id,
                        widget.titleController.text,
                        widget.descriptionController.text,
                      );
                }
                Navigator.pop(context);
              },
              child: Text(
                widget.note == null ? 'Save' : 'Update',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
        title: Text(
          widget.note == null ? 'New Note' : 'Update Note',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Theme.of(context).colorScheme.surface,
                      hintText: 'Title...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: TextField(
                  controller: widget.descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Theme.of(context).colorScheme.surface,
                      hintText: 'Description...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ),
              ),
              const SizedBox(height: 20),
              // Add formatting options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // IconButton(
                  //   icon: Icon(Icons.format_bold),
                  //   onPressed: () {
                  //     final text = widget.descriptionController.text;
                  //     final selection = widget.descriptionController.selection;

                  //     if (text
                  //             .substring(selection.start, selection.end)
                  //             .startsWith('**') &&
                  //         text
                  //             .substring(selection.start, selection.end)
                  //             .endsWith('**')) {
                  //       final newText = text.substring(0, selection.start) +
                  //           text.substring(
                  //               selection.start + 2, selection.end - 2) +
                  //           text.substring(selection.end);
                  //       widget.descriptionController.text = newText;
                  //       widget.descriptionController.selection = TextSelection(
                  //           baseOffset: selection.start,
                  //           extentOffset: selection.end - 4);
                  //     } else {
                  //       final newText = text.substring(0, selection.start) +
                  //           '**' +
                  //           text.substring(selection.start, selection.end) +
                  //           '**' +
                  //           text.substring(selection.end);
                  //       widget.descriptionController.text = newText;
                  //       widget.descriptionController.selection = TextSelection(
                  //           baseOffset: selection.start + 2,
                  //           extentOffset: selection.end + 2);
                  //     }
                  //   },
                  // ),
                  // IconButton(
                  //   icon: Icon(Icons.format_italic),
                  //   onPressed: () {
                  //     final text = widget.descriptionController.text;
                  //     final selection = widget.descriptionController.selection;

                  //     if (text
                  //             .substring(selection.start, selection.end)
                  //             .startsWith('*') &&
                  //         text
                  //             .substring(selection.start, selection.end)
                  //             .endsWith('*')) {
                  //       final newText = text.substring(0, selection.start) +
                  //           text.substring(
                  //               selection.start + 1, selection.end - 1) +
                  //           text.substring(selection.end);
                  //       widget.descriptionController.text = newText;
                  //       widget.descriptionController.selection = TextSelection(
                  //           baseOffset: selection.start,
                  //           extentOffset: selection.end - 2);
                  //     } else {
                  //       final newText = text.substring(0, selection.start) +
                  //           '*' +
                  //           text.substring(selection.start, selection.end) +
                  //           '*' +
                  //           text.substring(selection.end);
                  //       widget.descriptionController.text = newText;
                  //       widget.descriptionController.selection = TextSelection(
                  //           baseOffset: selection.start + 1,
                  //           extentOffset: selection.end + 1);
                  //     }
                  //   },
                  // ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissionAndPickImage() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
      status = await Permission.storage.status;
    }
    if (status.isGranted) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File file = File(image.path);
        // Store the image with the description text
        widget.descriptionController.text += '\n[Image: ${file.path}]';
      }
    } else {
      print('Storage permission denied');
    }
  }

  Future<void> _requestPermissionAndRecordAudio() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone.request();
      status = await Permission.microphone.status;
    }
    if (status.isGranted) {
      print('Microphone permission');
    }
  }
}