import 'package:flutter/foundation.dart';

import '../provider/stream_provider_local.dart';
import '../provider/stream_provider_remote.dart';
import '../signaling/signaling_minimal.dart';

///The simplest, most common functionality.
///A simple p2p, direct video call
///  in which we already know all participants names
class VCall1to1 {
  ///The local provider, with the id(localName) given in constructor
  LocalVideoProviderInternal localProvider;

  ///The remote provider, with the id(remoteName) given in constructor
  RemoteVideoProviderInternal remoteProvider;

  ///The signaler the providers will use to negotiate their connections
  MinimalSignaler signaler;

  ///Constructor
  ///localName: the id of a created local provider
  ///  this instance shall be reachable by that name
  ///  over a connection to the same signaler
  ///remoteName: the id the remote instance to be connected
  ///The signaler the providers will use to negotiate their connections
  ///  if the signaler is already connected it will not be connected
  ///  otherwise it will be connected to on 'init'
  VCall1to1(
    String localName,
    String remoteName,
    this.signaler,
    iceServers,
  )   : localProvider = LocalVideoProviderInternal.create(localName),
        remoteProvider =
            RemoteVideoProviderInternal.createWith(remoteName, iceServers) {
    remoteProvider.setSignaler(signaler);
    remoteProvider.setLocal(localProvider);
    signaler.addRemoteProvider(remoteProvider);
  }

  ///Initialize the local provider stream
  ///Connect to the signaler, unless signaler is already connected
  ///Offers connection to remote provider
  ///  If the remote provider is not yet connected,
  ///  this call will remain in a ready state,
  ///  waiting for the remote to offer the connection
  Future<void> init() async {
    await localProvider.initStream();
    if (!signaler.isConnected()) {
      await signaler.connect();
    }
    await remoteProvider.offer();
  }

  ///Closes the signaler if so requested, closes the local and remote provider
  @mustCallSuper
  Future<void> close({bool closeSignalerConnection = false}) async {
    await localProvider.closeStream();
    await remoteProvider.closeStream();
    if (closeSignalerConnection) {
      await signaler.close();
    }
  }
}
