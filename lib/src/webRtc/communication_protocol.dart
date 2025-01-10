import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:spotify/spotify.dart';

class CommunicationProtocol {
  static const startGameMessage = "start";
  static const newPlayerConnectedMessage = "player_connected";

  static const typeField = "type";
  static const userField = "user";

  static Map<String, dynamic> _decodeMessage(message) {
    return jsonDecode(message) as Map<String, dynamic>;
  }

  static void onMessageReceivedHost(message, DataConnection connection,
      Function(User user, DataConnection connection) addPlayerCallback) {
    final decodedMessage = _decodeMessage(message);
    final type = decodedMessage[typeField];

    switch (type) {
      case newPlayerConnectedMessage:
        {
          final playerMessage = decodedMessage[userField];
          _onNewPlayerConnected(playerMessage, connection, addPlayerCallback);
        }
    }
  }

  static void _onNewPlayerConnected(
      Map<String, dynamic> playerMessage,
      DataConnection connection,
      Function(User user, DataConnection connection) addPlayerCallback) {
    debugPrint("New player connected");
    debugPrint(playerMessage.toString());

    final user = User.fromJson(playerMessage);
    addPlayerCallback(user, connection);
  }

  static void onMessageReceivedPlayer(message, VoidCallback callback) {
    final decodedMessage = _decodeMessage(message);
    final type = decodedMessage[typeField];

    switch (type) {
      case startGameMessage:
        debugPrint('the host has started the game');
        callback();
        break;
    }
  }
}
