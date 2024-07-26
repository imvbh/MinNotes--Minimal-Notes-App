import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimal_notes_app/components/note_tile.dart';
import 'package:minimal_notes_app/models/note_database.dart';
import 'package:minimal_notes_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  //text controller
  final textController = TextEditingController();
  final textController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    readNotes();
  }

  //create
  void createNote() {
    textController.clear();
    textController2.clear();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0,left: 10.0),
                child: Text(
                  'New Note',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textController,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  decoration: InputDecoration(
                    filled: true,

                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none
                    ),
                    fillColor: Theme.of(context).colorScheme.primary,
                    hintText: 'Enter Note Title',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textController2,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none
                    ),
                    fillColor: Theme.of(context).colorScheme.primary,
                    hintText: 'Enter Note Description',
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      context.read<NoteDatabase>().addNote(
                        textController.text,
                        textController2.text,
                      );
                      textController.clear();
                      textController2.clear();
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //read
  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  //update
  void updateNote(Note note) {
    textController.text = note.title;
    textController2.text = note.description;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Update Note',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textController,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none
                    ),
                    fillColor: Theme.of(context).colorScheme.primary,
                    hintText: 'Enter Note Title',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textController2,
                  cursorColor: Theme.of(context).colorScheme.inversePrimary,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none
                    ),
                    fillColor: Theme.of(context).colorScheme.primary,
                    hintText: 'Enter Note Description',
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      context.read<NoteDatabase>().updateNote(
                        note.id,
                        textController.text,
                        textController2.text,
                      );
                      textController.clear();
                      textController2.clear();
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //delete
  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    //db
    final noteDatabase = context.watch<NoteDatabase>();

    //Current Notes
    List<Note> currentNotes = noteDatabase.currentNotes;
    bool isEmpty = currentNotes.isEmpty;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //heading
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "MinNotes",
                    style: GoogleFonts.dmSerifText(
                      fontSize: 48,
                      color: Theme.of(context).colorScheme.inversePrimary,
              )),
              IconButton(onPressed: () {
                setState(() {
                  isPressed= !isPressed;
                });
                Provider.of<ThemeProvider>(context,listen: false).toggleTheme()
                ;
              }, icon:(isPressed) ? Icon(Icons.light_mode): Icon(Icons.dark_mode),
                color: Theme.of(context).colorScheme.inversePrimary,
                iconSize: 30,
                  ),
              ],

          ),

        ),
        Container(
            padding: const EdgeInsets.only(left: 25.0,right: 25.0),
            margin: const EdgeInsets.all(20.0),
            child: Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
        //Notes
        Expanded(
          child: (isEmpty)? Center(child: Text("Add New Notes with the '+' Icon",
            style:TextStyle(
              fontSize: 25,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),textAlign: TextAlign.center,)): Padding(
              padding: const EdgeInsets.only(left:10.0, right: 10.0),
              child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 0,
              itemCount: currentNotes.length,
              itemBuilder: (context,index) {
                final note =currentNotes[index];
                return NoteTile(

                title: note.title,
                description: note.description,
                onEditPressed: () => updateNote(note),
                onDeletePressed: () => deleteNote(note.id),
                );
              },
              ),
            ),

        ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Made with ❤️ by imvbh',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    ),
  );
  }
}