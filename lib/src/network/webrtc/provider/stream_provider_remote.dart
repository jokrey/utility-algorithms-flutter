import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../peer_id.dart';
import '../signaling/signaling_minimal.dart';
import 'stream_provider.dart';
import 'stream_provider_local.dart';

///Callback for the transceiver specification by RemoteVideoProvider user.
///See 'setTransceiverSpecificationCallback'
typedef TransceiverSpecificationCallback =
  Future<void> Function(RTCPeerConnection);

///Public Remote Provider Interface
// ignore: one_member_abstracts
abstract class RemoteVideoProvider {
  ///requests a connection to remote over the internally set signaling interface
  Future<void> offer();
}

///Internal Remote Provider Interface - can be exposed for own, foreign signaler
abstract class RemoteVideoProviderInternal
    extends StreamProvider implements RemoteVideoProvider {
  ///Constructor, calls super
  RemoteVideoProviderInternal(PeerId id) : super(id);

  ///Shall be called by the signaler
  ///Implementation shall add the candidate to the peer connection or
  ///   store the candidate until the connection becomes available
  ///     (to support ice candidate trickling)
  Future<void> newIceCandidateReceived(RTCIceCandidate candidate);
  ///Shall be called by the signaler
  ///Implementation shall add the description to the peer connection
  ///May throw an error if the peer connection is not initialized
  Future<void> newRemoteDescription(RTCSessionDescription description);
  ///Shall be queried by the signaler, creates an answer to an offer
  ///Simply relays the call to the peer connection
  ///May throw an error if the peer connection is not initialized
  Future<RTCSessionDescription> createAnswer();

  ///Shall be set by the call implementation
  ///Any functionality that requires signaling will be handled by given signaler
  void setSignaler(MinimalSignaler signaling);
  ///Shall be set by the using implementation
  ///Will be called right after the peer connection is created,
  ///   the ice candidates callback is initialized right after and expects this.
  ///   If no transceivers(or tracks) are added, no ice candidate callbacks will
  ///     be received and no data is sent.
  ///MUST be set, otherwise any method may throw an error.
  void setTransceiverSpecificationCallback(TransceiverSpecificationCallback cb);
  ///'setTransceiverSpecificationCallback' can be called with:
  /// 'createDefaultLocalSendAndRecvTransceiverSpecificationCallback'
  /// to create the default sending and receiving transceivers.
  /// Will initialize the providers so they can provide bidirectional call.
  static TransceiverSpecificationCallback
    createDefaultLocalSendAndRecvTransceiverSpecificationCallback
      (LocalVideoProviderInternal lP) =>
      (peerConnection) async => await lP.addTracksTo(peerConnection);

  ///Creates an implementation of this interface
  static RemoteVideoProviderInternal create(String id) =>
      _RemoteVideoProviderImpl(PeerId(id));

  ///Will stream the provided provider to the remote peer.
  ///Will negotiate ice candidates automatically.
  /// Will initialize the providers so they can provide bidirectional call.
  void setLocal(LocalVideoProviderInternal localProvider) {
    setTransceiverSpecificationCallback(
        createDefaultLocalSendAndRecvTransceiverSpecificationCallback(
          localProvider
        )
    );
  }
}

class _RemoteVideoProviderImpl extends RemoteVideoProviderInternal {
  _RemoteVideoProviderImpl(id) : super(id);

  RTCPeerConnection peerConnection;

  Function(RTCPeerConnection) transceiverSpecificationCallback;
  @override
  void setTransceiverSpecificationCallback(TransceiverSpecificationCallback cb){
    transceiverSpecificationCallback = cb;
  }
  MinimalSignaler signalingInterface;
  @override void setSignaler(MinimalSignaler signaling) {
    signalingInterface = signaling;
  }

  final List<RTCIceCandidate> prematurelyReceivedCandidates = [];

  @override
  Future<MediaStream> initStream() async {
    peerConnection = await createPeerConnection({
      ...iceServers,
      ...{'sdpSemantics': 'unified-plan'}
    }, config);

    await transceiverSpecificationCallback(peerConnection);

    peerConnection.onIceCandidate = (candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      signalingInterface.relayIceCandidate(id, candidate);
    };
    peerConnection.onIceConnectionState = (state) {
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          stream = null;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        case RTCIceConnectionState.RTCIceConnectionStateNew:
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCount:
          break; //do nothing
      }
    };

    // Unified-Plan - only called when not sendOnly transceiver specified
    peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        stream = event.streams[0];
      }
    };

    peerConnection.onRemoveStream = (removedStream) {
      stream = null;
    };

    for(var prc in prematurelyReceivedCandidates) {
      await peerConnection.addCandidate(prc);
    }
    prematurelyReceivedCandidates.clear();

    return stream;
  }

  @override
  Future<void> newIceCandidateReceived(RTCIceCandidate candidate) async {
    if(peerConnection != null) {
      print('adding new ice candidate - to peer connection');
      await peerConnection.addCandidate(candidate);
    } else {
      print('adding new ice candidate - queued');
      prematurelyReceivedCandidates.add(candidate);
    }
  }
  @override
  Future<void> newRemoteDescription(RTCSessionDescription description) =>
    peerConnection.setRemoteDescription(description);
  @override Future<RTCSessionDescription> createAnswer() async {
    var s = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(s);
    return s;
  }

  @override
  Future<void> closeStream() async {
    await super.closeStream();
    await peerConnection?.close();
    prematurelyReceivedCandidates.clear();
  }

  @override
  Future<void> offer() async {
    await initStream();
    var s = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(s);
    signalingInterface.relayOffer(id, s);
  }
}



///Peer connection config
///customize according to webrtc doc directly.
Map<String, dynamic> config = {
  'mandatory': [
    {}
  ],
  'optional': [
    {'DtlsSrtpKeyAgreement': true},
  ]
};

///Ice servers config. Add stun or turn servers.
///customize according to webrtc doc directly.
Map<String, dynamic> iceServers = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
    /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
      */
  ]
};
