import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../general/observers.dart';
import '../peer_id.dart';
import '../provider/stream_provider_remote.dart';
import 'connectable.dart';


///Most Basic Signaling Functionality Interface
abstract class MinimalSignaler implements Connectable {
  ///Returns the own id, which has been registered at the server
  PeerId getOwnId();

  ///Internal/expert use only
  void relayOffer(PeerId remoteId, RTCSessionDescription s);
  ///Internal/expert use only
  void relayAnswer(PeerId remoteId, RTCSessionDescription s);
  ///Internal/expert use only
  void relayIceCandidate(PeerId remoteId, RTCIceCandidate c);

  ///Internal/expert use only
  void addRemoteProvider(RemoteVideoProviderInternal provider);

  ///Add observer for the on Closed event of the underlying wsclientable client
  void addOnClosedObserver(Observer<int> onClosed);
}