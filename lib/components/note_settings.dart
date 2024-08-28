import 'package:flutter/material.dart';

class NoteSettings extends StatelessWidget {
  final void Function()? onEditTap;
  final void Function()? onDeleteTap;

  const NoteSettings({super.key, required this.onDeleteTap, required this.onEditTap });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //edit
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onEditTap!();
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
            onDeleteTap!();
          },
          child: Container(
            height: 40,
            color: Theme.of(context).colorScheme.surface,
            child: const Center(child: Text("Delete",style: TextStyle(color: Colors.red),)),
          ),
        ),
      ],
    );
  }
}
