import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:spotify/spotify.dart';

typedef OnMessageCallback = void Function(Map<String, dynamic> message);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  RTCDataChannel? dataChannel;
  String? roomId;
  String? currentRoomText;
  OnMessageCallback? onMessageReceived;

  Future<String> createRoom() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc();

    debugPrint('Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);
    registerPeerConnectionListeners();

    // Create DataChannel
    dataChannel =
        await peerConnection!.createDataChannel('data', RTCDataChannelInit());
    setupDataChannel();

    // Collect ICE candidates
    var callerCandidatesCollection = roomRef.collection('callerCandidates');
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };

    // Create and set the offer
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    debugPrint('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};
    await roomRef.set(roomWithOffer);

    var roomId = roomRef.id;
    debugPrint('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';

    // Listen for remote session description
    roomRef.snapshots().listen((snapshot) async {
      debugPrint('Got updated room: ${snapshot.data()}');
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (peerConnection?.getRemoteDescription() == null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        await peerConnection?.setRemoteDescription(answer);
      }
    });

    // Listen for remote ICE candidates
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          debugPrint('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });

    return roomId;
  }

  Future<void> joinRoom(String roomId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      debugPrint('Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);
      registerPeerConnectionListeners();

      // Listen for remote ICE candidates
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) {
          debugPrint('onIceCandidate: complete!');
          return;
        }
        debugPrint('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };

      // Handle DataChannel
      peerConnection!.onDataChannel = (RTCDataChannel channel) {
        dataChannel = channel;
        setupDataChannel();
      };

      // Set remote offer and create answer
      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      var answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };
      await roomRef.update(roomWithAnswer);
    }
  }

  void setupDataChannel() {
    dataChannel?.onMessage = (RTCDataChannelMessage message) {
      if (message.isBinary) {
        debugPrint('Received binary message');
      } else {
        final decodedMessage = jsonDecode(message.text);
        if (decodedMessage['type'] == 'player_joined') {
          User newUser = User.fromJson(decodedMessage['user']);
          onMessageReceived?.call({'type': 'player_joined', 'user': newUser});
        } else {
          onMessageReceived?.call(decodedMessage);
        }
      }
    };

    dataChannel?.onDataChannelState = (RTCDataChannelState state) {
      debugPrint('Data channel state: $state');
    };
  }

  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (dataChannel != null) {
      dataChannel!.send(RTCDataChannelMessage(jsonEncode(message)));
      debugPrint('Sent message: $message');
    } else {
      debugPrint('Data channel is not available');
    }
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE gathering state changed: $state');
    };

    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE connection state change: $state');
    };
  }
}
