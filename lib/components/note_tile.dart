import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

import 'note_settings.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String description;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;

  const NoteTile({
    super.key,
    required this.title,
    required this.description,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showPopover(
        width: 120,
        height: 80,
        backgroundColor: Theme.of(context).colorScheme.background,
        context: context,
        bodyBuilder: (context) => NoteSettings(
          onEditTap: onEditPressed,
          onDeleteTap: onDeletePressed,
        ),
      ),
      onTap: onEditPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(top: 15, right: 10, left: 10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 200
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }
}
