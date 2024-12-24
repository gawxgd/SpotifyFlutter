import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

class GameLobbyViewModel extends ChangeNotifier {
  String _deepLink = 'https://groovecheck-6bbf7.web.app/joingame';
  String get deepLink => _deepLink;

  final List<User> _players = [];
  List<User> get players => List.unmodifiable(_players);

  void updateDeepLink(String newDeepLink) {
    _deepLink = newDeepLink;
    debugPrint(_deepLink);
    notifyListeners();
  }

  void addPlayer(User playerName) {
    _players.add(playerName);
    notifyListeners();
  }

  void removePlayerById(String userId) {
    _players.removeWhere((player) => player.id == userId);
    notifyListeners();
  }
}
