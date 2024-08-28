import 'package:flutter/material.dart';

class NoteSettings extends StatefulWidget {
  final void Function()? onEditTap;
  final void Function()? onDeleteTap;
  final void Function()? onHideTap;
    final String hideButtonText;


  const NoteSettings(
      {super.key,
      required this.onDeleteTap,
      required this.onEditTap,
      required this.onHideTap, required this.hideButtonText});

  @override
  _NoteSettingsState createState() => _NoteSettingsState();
}

class _NoteSettingsState extends State<NoteSettings> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //edit
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            widget.onEditTap!();
          },
          child: Container(
            height: 40,
            color: Theme.of(context).colorScheme.surface,
            child: const Center(child: Text("Edit")),
          ),
        ),
        //delete
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            widget.onDeleteTap!();
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
        //hide
        GestureDetector(
          onTap: () {
            setState(() {
              _hidden = !_hidden;
            });
            Navigator.pop(context);
            widget.onHideTap!();
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
