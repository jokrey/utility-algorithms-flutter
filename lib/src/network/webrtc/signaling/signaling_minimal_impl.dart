import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../general/observers.dart';
import '../../wsclientable/client.dart';
import '../peer_id.dart';
import '../provider/stream_provider_remote.dart';
import 'signaling_minimal.dart';

///Minimal implementation of most stripped Signaler
/// Naturally requires specific server side implementation
/// Supports offer, answer, candidate... NOTHING ELSE
class MinimalSignalerImpl implements MinimalSignaler {
  ///see 'getOwnId()'
  @protected
  final String claimedName;

  ///The baseurl this client will attempt to reach the server at
  ///for example: https://mlabstayin.rocks/signaling
  @protected
  final String baseUrl;

  ///Constructor
  MinimalSignalerImpl(this.claimedName, this.baseUrl);

  final Map<PeerId, RemoteVideoProviderInternal> _remotes = {};
  @override
  void addRemoteProvider(RemoteVideoProviderInternal provider) {
    _remotes[provider.id] = provider;
  }

  PeerId getOwnId() {
    return PeerId(claimedName);
  }

  ///Protected, used by overrides to connect to the correct url
  @protected
  Future<ClientConnection> createConnectionToServer() async {
    return connectToWSClientableServer('$baseUrl?user=$claimedName');
  }

  ClientConnection _signalingClient;
  @override
  Future<bool> connect() async {
    try {
      _signalingClient = await createConnectionToServer();
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print("failed to connect to signaling server: $e");
      return false;
    }

    _signalingClient.addMessageHandler("candidate", (c, _, data) async {
      var peer = PeerId(data['from']);
      var candidateMap = data['candidate'];
      var candidate = RTCIceCandidate(candidateMap['candidate'],
          candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);
      await _remotes[peer].newIceCandidateReceived(candidate);
    });
    _signalingClient.addMessageHandler("answer", (c, _, data) async {
      var peer = PeerId(data['from']);
      var description = data['description'];
      var sessionDescription =
          RTCSessionDescription(description['sdp'], description['type']);
      await _remotes[peer].newRemoteDescription(sessionDescription);
    });
    _signalingClient.addMessageHandler("offer", (c, _, data) async {
      var peer = PeerId(data['from']);
      var description = data['description'];
      var sessionDescription =
          RTCSessionDescription(description['sdp'], description['type']);

      var remote = _remotes[peer];
      print('offer from $peer, remote: $remote');
      await remote.initStream();
      await remote.newRemoteDescription(sessionDescription);
      relayAnswer(peer, await remote.createAnswer());
    });
    _signalingClient.addMessageHandler("error", (c, _, data) {
      print("Received error: $data");
    });

    _signalingClient.onClosedHandler = (c, code, text) {
      _onClosedObservable.notifyAll(code);
    };

    return _signalingClient.isConnected();

    // if (_turnCredential == null) {
    //   try {
    //     _turnCredential = await getTurnCredential(_host, _port);
    //     /*{
    //         "username": "1584195784:mbzrxpgjys",
    //         "password": "isyl6FF6nqMTB9/ig5MrMRUXqZg",
    //         "ttl": 86400,
    //         "uris": ["turn:127.0.0.1:19302?transport=udp"]
    //       }
    //     */
    //     _iceServers = {
    //       'iceServers': [
    //         {
    //           'urls': _turnCredential['uris'][0],
    //           'username': _turnCredential['username'],
    //           'credential': _turnCredential['password']
    //         },
    //       ]
    //     };
    //   } catch (e) {}
    // }
  }

  final Observable<int> _onClosedObservable = Observable();
  @override
  void addOnClosedObserver(Observer<int> onClosed) {
    _onClosedObservable.addObserver(onClosed);
  }

  @override
  bool isConnected() =>
      _signalingClient != null && _signalingClient.isConnected();

  @override
  Future<void> close() async {
    _signalingClient.close();
  }

  void relayAnswer(PeerId id, RTCSessionDescription s) {
    _signalingClient.sendMap('answer', {
      'to': id.str,
      'description': {'sdp': s.sdp, 'type': s.type}
    });
  }

  @override
  void relayIceCandidate(PeerId id, RTCIceCandidate candidate) {
    _signalingClient.sendMap('candidate', {
      'to': id.str,
      'candidate': {
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      }
    });
  }

  @override
  void relayOffer(PeerId id, RTCSessionDescription s) {
    _signalingClient.sendMap('offer', {
      'to': id.str,
      'description': {'sdp': s.sdp, 'type': s.type}
    });
  }
}
