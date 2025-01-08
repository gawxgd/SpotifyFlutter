import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_flutter/src/webRtc/peersignalingbase.dart';

class HostPeerSignaling extends PeerSignalingBase {
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

   @override
  void close() {
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
