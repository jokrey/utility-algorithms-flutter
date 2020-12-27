import 'dart:async';

import '../../wsclientable/client.dart';

import 'signaling_minimal_impl.dart';
import 'signaling_rooms.dart';

///Minimal implementation of most stripped Signaler
/// Naturally requires specific server side implementation
/// Supports offer, answer, candidate... NOTHING ELSE
class RoomSignalerImpl extends MinimalSignalerImpl implements RoomSignaler {
  final String _roomName;
  
  ///Constructor
  RoomSignalerImpl(this._roomName, String claimedName,
      bool encryptedConnection, String serverAddress, int serverPort)
      : super(claimedName, encryptedConnection, serverAddress, serverPort);
  
  @override
  String getRoomId() {
    return _roomName;
  }


  ///Protected, used by overrides to connect to the correct url
  @override
  Future<ClientConnection> createConnectionToServer() async {
    var url = (this.encryptedConnection?"https":"http")+'://$serverAddress:$serverPort/signaling?room=$_roomName&user=$claimedName';
    return connectToWSClientableServer(url);
  }
}