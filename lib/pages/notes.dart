import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimal_notes_app/components/note_tile.dart';
import 'package:minimal_notes_app/models/note_database.dart';
import 'package:minimal_notes_app/pages/pin.dart';
import 'package:minimal_notes_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:minimal_notes_app/models/note.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'note_edit_page.dart';

class NotesPage extends StatefulWidget {
  final bool showHiddenNotes;

  const NotesPage({super.key, this.showHiddenNotes = false});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();
  final textController2 = TextEditingController();
  bool showHiddenNotes = false;

  @override
  void initState() {
    super.initState();
    readNotes();
  }

  void createNote() {
    textController.clear();
    textController2.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(
          titleController: textController,
          descriptionController: textController2,
          showHiddenNotes: widget.showHiddenNotes,
        ),
      ),
    );
  }

  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  void updateNote(Note note) {
    textController.text = note.title;
    textController2.text = note.description;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(
          titleController: textController,
          descriptionController: textController2,
          note: note,
          showHiddenNotes: widget.showHiddenNotes,
        ),
      ),
    );
  }

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
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNote();
        },
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
                GestureDetector(
                  onDoubleTap: () {
                    if (showHiddenNotes) {
                      // Already in hidden notes mode, toggle back to normal mode
                      setState(() {
                        showHiddenNotes = false;
                      });
                    } else {
                      // Show PIN page to access hidden notes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HiddenNotesPatternPage(),
                        ),
                      ).then((value) {
                        if (value == true) {
                          // PIN is correct, toggle to hidden notes mode
                          setState(() {
                            showHiddenNotes = true;
                          });
                        }
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Text("MinNotes ",
                          style: GoogleFonts.dmSerifText(
                            fontSize: 48,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          )),
                      if (showHiddenNotes) const Icon(Icons.lock, size: 30),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isPressed = !isPressed;
                    });
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                  icon: (isPressed)
                      ? const Icon(Icons.light_mode)
                      : const Icon(Icons.dark_mode),
                  color: Theme.of(context).colorScheme.inversePrimary,
                  iconSize: 30,
                ),
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              margin: const EdgeInsets.all(20.0),
              child: Divider(
                color: Theme.of(context).colorScheme.inversePrimary,
              )),
          //Notes
          Expanded(
            child: (isEmpty)
                ? Center(
                    child: Text(
                      "Add New Notes with the '+' Icon",
                      style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 0,
                      itemCount: showHiddenNotes
                          ? currentNotes.where((note) => note.isHidden).length
                          : currentNotes.where((note) => !note.isHidden).length,
                      itemBuilder: (context, index) {
                        final note = showHiddenNotes
                            ? currentNotes
                                .where((note) => note.isHidden)
                                .toList()[index]
                            : currentNotes
                                .where((note) => !note.isHidden)
                                .toList()[index];
                        return NoteTile(
                            title: note.title,
                            description: note.description,
                            onEditPressed: () => updateNote(note),
                            onDeletePressed: () => deleteNote(note.id),
                            onHidePressed: () {
                              note.isHidden = !note.isHidden;
                              setState(() {});
                            });
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
