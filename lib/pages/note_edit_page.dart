import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_notes_app/models/note_database.dart';
import 'package:minimal_notes_app/models/note.dart';

class NoteEditPage extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Note? note;

  NoteEditPage({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        actions: [ Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
            onPressed: () {
              if (note == null) {
                context.read<NoteDatabase>().addNote(
                  titleController.text,
                  descriptionController.text,
                );
              } else {
                context.read<NoteDatabase>().updateNote(
                  note!.id,
                  titleController.text,
                  descriptionController.text,
                );
              }
              Navigator.pop(context);
            },
            child: Text( note == null ? 'Save' : 'Update', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.bold),),
          ),
        )],
        title: Text(note == null ? 'New Note' : 'Update Note'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).colorScheme.primary,
                    hintText: 'Enter Note Title',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 20,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).colorScheme.primary,
                    hintText: 'Enter Note Description',
                  ),
                ),
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
