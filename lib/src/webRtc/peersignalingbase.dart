import 'dart:async';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

typedef OnMessageCallback = void Function(
    String message, DataConnection connection);

abstract class PeerSignalingBase {
  late Peer peer;
  String? localPeerId;
  List<DataConnection> dataConnections = [];
  OnMessageCallback? onMessageReceived;

  /// Initialize the Peer connection
  Future<void> initializePeer({OnMessageCallback? onMessage}) async {
    onMessageReceived = onMessage;
    peer = Peer();

    Completer<void> peerOpenCompleter = Completer<void>();

    peer.on('open').listen((id) {
      localPeerId = id;
      debugPrint('Local Peer ID: $localPeerId');
      peerOpenCompleter.complete();
    });

    peer.on('error').listen((error) {
      debugPrint('Peer error: $error');
    });

    // Wait until the peer connection is open before proceeding
    await peerOpenCompleter.future;
  }

  /// Set up a data connection
  void setupDataConnection(DataConnection connection,
      {required VoidCallback onOpen}) {
    connection.on('data').listen((data) {
      onMessageReceived?.call(data.toString(), connection);
      debugPrint('Received message: $data');
    });

    connection.on('open').listen((_) {
      debugPrint('Data connection with ${connection.peer} is open');
      onOpen();
    });

    connection.on('close').listen((_) {
      debugPrint('Data connection closed with ${connection.peer}');
      dataConnections.remove(connection);
    });

    connection.on('error').listen((error) {
      debugPrint('Data connection error: $error');
    });
  }

  /// Send a message to all peers
  void sendMessage(String message) {
    for (var connection in dataConnections) {
      if (connection.open) {
        connection.send(message);
        debugPrint('Sent message to ${connection.peer}: $message');
      } else {
        debugPrint('Connection to ${connection.peer} is not open.');
      }
    }
  }

  Future<bool> sendMessageAsync(String message) async {
    // false when one message has failed
    if (dataConnections.isEmpty) {
      return false;
    }
    for (var connection in dataConnections) {
      if (connection.open) {
        await connection.send(message);
        debugPrint('Sent message to ${connection.peer}: $message');
      } else {
        debugPrint('Connection to ${connection.peer} is not open.');
        return false;
      }
    }
    return true;
  }

  /// Close all connections and the peer
  void close() {
    for (var connection in dataConnections) {
      connection.close();
    }
    dataConnections.clear();
    peer.close();
    debugPrint('Peer connection closed');
  }
}
