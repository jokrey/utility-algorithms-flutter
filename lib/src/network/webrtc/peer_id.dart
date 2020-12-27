import 'package:flutter/foundation.dart';

///Un-stringify peer id type
@immutable
class PeerId {
  ///The actual string id of the peer as used by most signaling apis
  final String str;
  ///Constructor
  PeerId(this.str);


  //what the hell, dart?!::: In 2020???!
  @override String toString() => 'PeerId{str: $str}';
  @override bool operator ==(Object other) => identical(this, other) ||
      other is PeerId && runtimeType == other.runtimeType && str == other.str;
  @override int get hashCode => str.hashCode;
}