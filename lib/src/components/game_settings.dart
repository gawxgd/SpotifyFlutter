import 'dart:core';

class GameSettings {
  String gameMode;
  String rounds;
  String password;
  int questionTime;

  GameSettings({
    required this.gameMode,
    required this.rounds,
    required this.password,
    required this.questionTime,
  });
}
