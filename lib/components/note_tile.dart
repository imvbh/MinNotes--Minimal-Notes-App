import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

import 'note_settings.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isHidden; // Track hidden state
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;
  final void Function(bool isHidden)? onHidePressed; // Accept bool

  const NoteTile({
    super.key,
    required this.title,
    required this.description,
    required this.isHidden,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onHidePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showPopover(
        width: 120,
        height: 120,
        backgroundColor: Theme.of(context).colorScheme.surface,
        context: context,
        bodyBuilder: (context) => NoteSettings(
          onEditTap: onEditPressed,
          onDeleteTap: onDeletePressed,
          onHideTap: (bool hidden) {
            if (onHidePressed != null) {
              onHidePressed!(hidden);
            }
          },
          initialHiddenState: isHidden, // Pass initial state
          hideButtonText: isHidden ? 'Unhide' : 'Hide',
        ),
      ),
      onTap: onEditPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 4),
          borderRadius: BorderRadius.circular(15),
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
                fontSize: 20,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
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
