import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeavingConfirmationDialog extends StatelessWidget {
  const LeavingConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text(
        'Are you sure you want to leave this game, it will close all connections?',
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Nevermind'),
          onPressed: () {
            context.pop(false);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Leave'),
          onPressed: () {
            context.pop(true);
          },
        ),
      ],
    );
  }
}
