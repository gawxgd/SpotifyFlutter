import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/components/game_settings.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_view.dart';

class PrepareGameCubit extends Cubit<PrepareGameState> {
  PrepareGameCubit()
      : super(PrepareGameState(
          gameMode: 'Standard',
          rounds: '5',
          password: '',
          isPasswordVisible: false,
          questionTime: 30,
        ));

  void updateGameMode(String gameMode) =>
      emit(state.copyWith(gameMode: gameMode));

  void updateRounds(String rounds) => emit(state.copyWith(rounds: rounds));

  void updatePassword(String password) =>
      emit(state.copyWith(password: password));

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));

  void updateQuestionTime(int questionTime) =>
      emit(state.copyWith(questionTime: questionTime));

  void startGame(BuildContext context) {
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields correctly.')),
      );
      return;
    }
    final gameSettings = GameSettings(
      gameMode: state.gameMode,
      rounds: state.rounds,
      password: state.password,
      questionTime: state.questionTime,
    );
    if (getIt.isRegistered<GameSettings>()) {
      getIt.unregister<GameSettings>();
    }
    getIt.registerSingleton(gameSettings);
    context.go(GameLobbyView.routeName);
  }

  bool get isValid =>
      state.rounds.isNotEmpty &&
      int.tryParse(state.rounds) != null &&
      state.password.isNotEmpty;
}

class PrepareGameState {
  final String gameMode;
  final String rounds;
  final String password;
  final bool isPasswordVisible;
  final int questionTime;

  PrepareGameState({
    required this.gameMode,
    required this.rounds,
    required this.password,
    required this.isPasswordVisible,
    required this.questionTime,
  });

  PrepareGameState copyWith({
    String? gameMode,
    String? rounds,
    String? password,
    bool? isPasswordVisible,
    int? questionTime,
  }) {
    return PrepareGameState(
      gameMode: gameMode ?? this.gameMode,
      rounds: rounds ?? this.rounds,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      questionTime: questionTime ?? this.questionTime,
    );
  }
}
