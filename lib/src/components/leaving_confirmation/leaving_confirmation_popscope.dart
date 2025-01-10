import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_dialog.dart';
import 'package:spotify_flutter/src/home/home_view.dart';

class LeavingConfirmationPopscope extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDispose;

  const LeavingConfirmationPopscope({
    super.key,
    required this.child,
    this.onDispose,
  });

  Future<bool?> _showBackDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const LeavingConfirmationDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          if (onDispose != null) {
            onDispose!();
          }
          context.go(HomeView.routeName);
        }
      },
      child: child,
    );
  }
}
