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
  final searchController = TextEditingController();
  bool showHiddenNotes = false;
  bool isPressed = false;
  bool _isSearchExpanded = false;
  int crossAxisCount = 2; // Default crossAxisCount
  bool reverseOrder = false; // Reverse order initially
  String searchQuery = '';
  bool _isAutosaveEnabled = true; // Default is off

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showHiddenNotes = widget.showHiddenNotes;
        context.read<NoteDatabase>().setShowHiddenNotes(showHiddenNotes);
        readNotes();
      });
    });

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
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
          showHiddenNotes: showHiddenNotes,
          isAutosaveEnabled: _isAutosaveEnabled,
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
          showHiddenNotes: showHiddenNotes,
          isAutosaveEnabled: _isAutosaveEnabled,
        ),
      ),
    ).then((updatedNote) {
      if (updatedNote != null) {
        context.read<NoteDatabase>().updateNote(
              updatedNote.id,
              updatedNote.title,
              updatedNote.description,
              isHidden: updatedNote.isHidden,
            );
      }
    });
  }

  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  void toggleCrossAxisCount() {
    setState(() {
      crossAxisCount = (crossAxisCount == 2) ? 1 : 2;
    });
  }

  void toggleReverseOrder() {
    setState(() {
      reverseOrder = !reverseOrder;
    });
  }

  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<NoteDatabase>();

    List<Note> currentNotes = noteDatabase.currentNotes
        .where((note) =>
            note.title.toLowerCase().contains(searchQuery) ||
            note.description.toLowerCase().contains(searchQuery))
        .toList();

    bool isEmpty = currentNotes.isEmpty;

    // Reverse list if reverseOrder is true
    if (reverseOrder) {
      currentNotes = currentNotes.reversed.toList();
    }

    int noteCount = showHiddenNotes
        ? currentNotes.where((note) => note.isHidden).length
        : currentNotes.where((note) => !note.isHidden).length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isSearchExpanded
                    ? MediaQuery.of(context).size.width - 100
                    : 120,
                height: 60,
                child: _isSearchExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.bottom,
                          maxLines: 1,
                          controller: searchController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              alignment: const Alignment(-2, -2),
                              icon: const Icon(Icons.close),
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              onPressed: () {
                                setState(() {
                                  _isSearchExpanded = false;
                                  textController.clear();
                                });
                              },
                            ),
                            hintText: 'Search $noteCount notes...',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                          onChanged: (query) {
                            setState(() {
                              searchQuery = query.toLowerCase();
                            });
                          },
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchExpanded = true;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$noteCount Notes',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.search,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              size: 28,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
        ),
      ),
      drawer: Drawer(
        width: 275,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Center(
                      // Centers the content of the DrawerHeader
                      child: Text('MinNotes',
                          style: GoogleFonts.dmSerifText(
                            fontSize: 44,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          )),
                    ),
                  ),
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        isPressed ? Icons.dark_mode : Icons.light_mode,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    title: Text(isPressed ? 'Dark Mode' : 'Light Mode'),
                    onTap: () {
                      setState(() {
                        isPressed = !isPressed;
                      });
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        crossAxisCount == 2 ? Icons.list : Icons.grid_on,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    title:
                        Text(crossAxisCount == 2 ? 'List View' : 'Grid View'),
                    onTap: () {
                      toggleCrossAxisCount();
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        reverseOrder
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    title: Text(reverseOrder ? 'Oldest First' : 'Newest First'),
                    onTap: () {
                      toggleReverseOrder();
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      _isAutosaveEnabled ? Icons.save : Icons.save_alt,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    title: Text(_isAutosaveEnabled
                        ? 'Autosave Enabled'
                        : 'Autosave Disabled'),
                    trailing: Switch(
                      value: _isAutosaveEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isAutosaveEnabled = value;
                        });
                        Navigator.pop(context); // Close the drawer
                      },
                    ),
                  ),
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete_sweep_rounded,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    title: const Text("Recycle Bin"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    title: const Text("Settings"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Made with ❤️ by imvbh',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearchExpanded) {
            setState(() {
              _isSearchExpanded =
                  false; // Collapse search bar when clicking outside
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onDoubleTap: () {
                      if (showHiddenNotes) {
                        setState(() {
                          showHiddenNotes = false;
                          context
                              .read<NoteDatabase>()
                              .setShowHiddenNotes(false);
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HiddenNotesPatternPage(),
                          ),
                        ).then((value) {
                          if (value == true) {
                            setState(() {
                              showHiddenNotes = true;
                              context
                                  .read<NoteDatabase>()
                                  .setShowHiddenNotes(true);
                            });
                          }
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Center(
                          child: Text(
                            showHiddenNotes ? "Hidden Notes " : "MinNotes ",
                            style: GoogleFonts.dmSerifText(
                              fontSize: 44,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        if (showHiddenNotes)
                          const Icon(Icons.lock_outline, size: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding:
                    const EdgeInsets.only(left: 35.0, right: 35.0, bottom: 4.0),
                child: Divider(
                  color: Theme.of(context).colorScheme.inversePrimary,
                )),
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
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                        itemCount: showHiddenNotes
                            ? currentNotes.where((note) => note.isHidden).length
                            : currentNotes
                                .where((note) => !note.isHidden)
                                .length,
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
                              isHidden:
                                  note.isHidden, // Pass the isHidden state
                              onEditPressed: () => updateNote(note),
                              onDeletePressed: () => deleteNote(note.id),
                              onHidePressed: (bool hidden) {
                                setState(() {
                                  note.isHidden = hidden;
                                });
                                // Update note in the database
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  context.read<NoteDatabase>().updateNote(
                                        note.id,
                                        note.title,
                                        note.description,
                                        isHidden:
                                            hidden, // Pass the new hidden state
                                      );
                                });
                              });
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
