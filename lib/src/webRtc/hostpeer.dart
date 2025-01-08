import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/webRtc/peersignalingbase.dart';

class HostPeerSignaling extends PeerSignalingBase {
  Map<String, (User, DataConnection)> userToDataConnectionMap =
      <String, (User, DataConnection)>{};
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _roomId;

  /// Create a new room and save the Peer ID to Firestore
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
      dataConnections.add(conn);
      setupDataConnection(conn, onOpen: () {
        debugPrint('Data connection with ${conn.peer} is open');
      });
    });

    _roomId = roomRef.id;
    return roomRef.id;
  }

  void addUserToDataConnectionMapping(User user, DataConnection connection) {
    if (user.id != null) {
      userToDataConnectionMap.putIfAbsent(user.id!, () => (user, connection));
    }
  }

  void closeConnectionWithPeer(DataConnection connection, User player) {
    debugPrint(
        'closing connection with ${player.id} and connection ${connection.peer} ');
    connection.close();
    connection.dispose();
    userToDataConnectionMap.remove(player.id);
    dataConnections.retainWhere((conn) {
      if (conn.peer == connection.peer) {
        conn.close();
        conn.dispose();
        return false;
      }
      return true;
    });
  }

  @override
  void close() {
    // clear the map here
    super.close();

    if (_roomId != null) {
      _db.collection('rooms').doc(_roomId).delete().then((_) {
        debugPrint('Room $_roomId deleted from Firestore.');
      }).catchError((error) {
        debugPrint('Failed to delete room $_roomId: $error');
      });
    }
  }
}
