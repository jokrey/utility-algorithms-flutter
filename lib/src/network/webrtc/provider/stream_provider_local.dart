import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../peer_id.dart';
import 'stream_provider.dart';

///Public Remote Provider Interface
abstract class LocalVideoProvider {
  ///true: mutes the mic, false: unmutes the mic
  // ignore: avoid_positional_boolean_parameters
  void muteMic(bool muted);
  ///return whether the mic is currently muted
  bool isMicMuted();
  ///toggles the Microphone mute state
  //default doesn't work for implements (in 2020?!?!?) => muteMic(!isMicMuted())
  void toggleMuteMic();
  ///switches the current camera, throws error otherwise
  Future<void> switchCamera();
}

///Internal Remote Provider Interface - can be exposed for own, foreign signaler
abstract class LocalVideoProviderInternal
    extends StreamProvider implements LocalVideoProvider {
  ///Constructor, calls super
  LocalVideoProviderInternal(PeerId id) : super(id);

  ///Shall add the local media stream tracks to the peer connection
  ///  The peer connection is tasked with relaying that data to the peer
  Future<void> addTracksTo(RTCPeerConnection peerConnection);

  ///Creates an implementation of this interface
  static LocalVideoProviderInternal create(String id) =>
      _LocalVideoProviderImpl(PeerId(id));
}

///Private Impl
class _LocalVideoProviderImpl extends LocalVideoProviderInternal {
  _LocalVideoProviderImpl(id) : super(id);

  @override
  Future<MediaStream> initStream() async {
    final mediaConstraints = <String, dynamic> {
      'audio': true,
      'video': {
        'mandatory': {
          // Provide your own width, height and frame rate here
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }


  @override
  Future<void> addTracksTo(RTCPeerConnection peerConnection) async {
    for(var t in stream.getTracks()) {
      await peerConnection.addTrack(t, stream);
    }
  }

  @override
  void muteMic(bool muted) {
    stream?.getAudioTracks()[0].enabled = !muted;
  }

  @override
  bool isMicMuted() =>
      stream != null &&
      stream.getAudioTracks().isNotEmpty &&
      !stream.getAudioTracks()[0].enabled;

  @override
  void toggleMuteMic() => muteMic(!isMicMuted());

  @override
  Future<void> switchCamera() async {
    await stream?.getVideoTracks()[0].switchCamera();
  }
}