import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../provider/stream_provider_remote.dart';
import '../signaling/signaling_minimal.dart';

///Allows observing a 1 to 1 call, if the remotes agree
class VCall1to1RemoteObserver {
  ///The remote providers observed by this 1 way call
  final List<RemoteVideoProviderInternal> remoteProviders = [];
  ///The signaler the providers will use to negotiate their connections
  MinimalSignaler signaler;

  ///Constructor
  ///remoteNames: the ids the remote instances to be connected
  ///  remotes may reject silently
  ///The signaler the providers will use to negotiate their connections
  ///  if the signaler is already connected it will not be connected
  ///  otherwise it will be connected to on 'init'
  VCall1to1RemoteObserver(List<String> remoteNames, this.signaler) {
    for(var remoteName in remoteNames) {
      remoteProviders.add(RemoteVideoProviderInternal.create(remoteName));
    }
    for(var remoteProvider in remoteProviders) {
      remoteProvider.setSignaler(signaler);

      //RECEIVE ONLY TRANSCEIVER FOR THE REMOTE STREAM - Pretty dope
      remoteProvider.setTransceiverSpecificationCallback((peerConnection)async {
        if(kIsWeb) {
          throw ArgumentError("cannot add transceiver on web:::: "
              "BUG: see https://github.com/flutter-webrtc/flutter-webrtc/issues/437");
        } else {
          await peerConnection.addTransceiver(
              kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
              init: RTCRtpTransceiverInit(
                  direction: TransceiverDirection.RecvOnly
              )
          );
          await peerConnection.addTransceiver(
              kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
              init: RTCRtpTransceiverInit(
                  direction: TransceiverDirection.RecvOnly
              )
          );
        }
      });
      signaler.addRemoteProvider(remoteProvider);
    }


    //possibly replace this with a call from the signaling api,
    //  though that feels like overkill also
    Timer.periodic(Duration(seconds: 10), (timer) async {
      for(var remoteProvider in remoteProviders) {
        if(!remoteProvider.isConnected()) {
          await remoteProvider.offer();
        }
      }
    });
  }

  ///Connect to the signaler, unless signaler is already connected
  ///Offers connections to remote providers
  ///  If the remote provider cannot be connected to,
  ///   this will be retried every 30 seconds.
  Future<void> init() async {
    if(!signaler.isConnected()) {
      await signaler.connect();
    }
    for(var remoteProvider in remoteProviders) {
      await remoteProvider.offer();
    }
  }

  ///Closes the signaler if so requested, closes and remote providers
  Future<void> close({bool closeSignalerConnection = false}) async {
    if(closeSignalerConnection) {
      await signaler.close();
    }
    for(var remoteProvider in remoteProviders) {
      await remoteProvider.closeStream();
    }
  }
}