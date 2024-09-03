import 'package:flutter/material.dart';

class NoteSettings extends StatefulWidget {
  final void Function()? onEditTap;
  final void Function()? onDeleteTap;
  final void Function(bool isHidden)? onHideTap; // Pass the hidden state
  final bool initialHiddenState; // Initial hidden state
  final String hideButtonText;

  const NoteSettings({
    super.key,
    required this.onDeleteTap,
    required this.onEditTap,
    required this.onHideTap,
    required this.initialHiddenState,
    required this.hideButtonText,
  });

  @override
  _NoteSettingsState createState() => _NoteSettingsState();
}

class _NoteSettingsState extends State<NoteSettings> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.initialHiddenState; // Initialize _hidden
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Edit
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            widget.onEditTap?.call();
          },
          child: Container(
            height: 40,
            color: Theme.of(context).colorScheme.surface,
            child: const Center(child: Text("Edit")),
          ),
        ),
        // Delete
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            widget.onDeleteTap?.call();
          },
          child: Container(
            height: 40,
            color: Theme.of(context).colorScheme.surface,
            child: const Center(
                child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            )),
          ),
        ),
        // Hide/Unhide
        GestureDetector(
          onTap: () {
            setState(() {
              _hidden = !_hidden;
            });
            Navigator.pop(context);
            widget.onHideTap?.call(_hidden); // Pass the updated hidden state
          },
          child: Container(
            height: 40,
            color: Theme.of(context).colorScheme.surface,
            child: Center(child: Text(_hidden ? "Unhide" : "Hide")),
          ),
        ),
      ],
    );
  }
}
