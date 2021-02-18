import 'signaling_minimal.dart';

///Most Basic Signaling Functionality Interface
abstract class RoomSignaler implements MinimalSignaler {
  ///Returns the room id, in which this signaler was registered
  String getRoomId();
}
