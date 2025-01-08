import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peerdart/peerdart.dart';

typedef OnMessageCallback = void Function(String message);

class PeerSignaling {
  late Peer peer;
  String? localPeerId;
  String? remotePeerId;
  DataConnection? dataConnection; // make a list
  OnMessageCallback? onMessageReceived;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Initialize the Peer connection
  Future<void> initializePeer({OnMessageCallback? onMessage}) async {
    onMessageReceived = onMessage;
    peer = Peer();

    Completer<void> peerOpenCompleter = Completer<void>();

    peer.on('open').listen((id) {
      localPeerId = id;
      debugPrint('Local Peer ID: $localPeerId');
      peerOpenCompleter.complete(); // Complete the future when peer is open
    });

    peer.on('error').listen((error) {
      debugPrint('Peer error: $error');
    });

    // Wait until the peer connection is open before proceeding
    await peerOpenCompleter.future;
  }

  /// Create a new room and save Peer ID to Firestore
  Future<String> createRoom() async {
    await initializePeer(); // Ensure peer is initialized and opened
    if (localPeerId == null) {
      throw Exception('Peer ID is not initialized.');
    }

    DocumentReference roomRef = _db.collection('rooms').doc();
    await roomRef.set({
      'hostPeerId': localPeerId,
    });

    debugPrint('Room created with Peer ID: $localPeerId');
    peer.on('connection').listen((conn) {
        debugPrint('Incoming connection from: ${conn.peer}');
      dataConnection = conn;
// make dataConnection a list
    // Set up listeners for the new connection
    _setupDataConnection(onOpen: () {
      debugPrint('Data connection with ${conn.peer} is open');
    });
    });

    return roomRef.id;
  }

  /// Join a room using room ID
  Future<void> joinRoom(String roomId,{required VoidCallback onOpen}) async {
    await initializePeer(); // Ensure peer is initialized and opened

    DocumentSnapshot snapshot = await _db.collection('rooms').doc(roomId).get();

    if (!snapshot.exists) {
      debugPrint('Room does not exist');
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    remotePeerId = data['hostPeerId'];

    debugPrint('Connecting to remote peer: $remotePeerId');

    dataConnection = peer.connect(remotePeerId!);
    _setupDataConnection(onOpen: onOpen);
  }

  /// Send a message through the DataChannel
  void sendMessage(String message) {
    if (dataConnection != null && dataConnection!.open) {
      dataConnection!.send(message);
      debugPrint('Sent message: $message');
    } else {
      debugPrint('Data connection is not open.');
    }
  }

  /// Handle incoming messages and connection state
  void _setupDataConnection({required VoidCallback onOpen}) {
    dataConnection?.on('data').listen((data) {
      if (onMessageReceived != null) {
        onMessageReceived!(data.toString());
      }
      debugPrint('Received message: $data');
    });

    dataConnection?.on('open').listen((_) {
      debugPrint('Data connection is open');
      onOpen();
    });

    dataConnection?.on('close').listen((_) {
      debugPrint('Data connection closed');
    });

    dataConnection?.on('error').listen((error) {
      debugPrint('Data connection error: $error');
    });
  }

  /// Close the Peer connection
  void close() {
    dataConnection?.close();
    peer.close();
    debugPrint('Peer connection closed');
  }
}
