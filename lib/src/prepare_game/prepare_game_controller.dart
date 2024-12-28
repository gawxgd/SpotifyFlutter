import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_controller.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_view.dart';
import 'package:spotify_flutter/src/prepare_game/prepare_game_view_model.dart';

class PrepareGameController {
  final PrepareGameViewModel viewModel;

  PrepareGameController(this.viewModel);

  void startGame(BuildContext context) {
    debugPrint(viewModel.password + viewModel.rounds);
    if (!viewModel.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields correctly.')),
      );
      return;
    }
    context.pop();
    context.push(GameLobbyView.routeName); //, pathParameters: {
    //   'rounds': viewModel.rounds,
    //   'gameMode': viewModel.gameMode,
    //   'password': viewModel.password,
    // });
  }
}
