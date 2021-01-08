import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../network/webrtc/signaling/signaling_room_impl.dart';
import '../../../../jokrey_utilities.dart';
import '../../../network/webrtc/calls/vcall_1to1_remote_observer.dart';
import '../../../network/webrtc/signaling/signaling_minimal_impl.dart';

import '../vcall_1to1_observer_widget.dart';


///TEST ONLY
class TestConnectAsObserverInRoomWidget extends StatefulWidget {
  _TestConnectAsObserverInRoomWidgetState createState() =>
      _TestConnectAsObserverInRoomWidgetState();
}

class _TestConnectAsObserverInRoomWidgetState
    extends State<TestConnectAsObserverInRoomWidget> {
  final _enterHost = TextEditingController()
    ..text = kIsWeb ? "localhost" : "jokrey-manj-lap.fritz.box";
  final _enterPort = TextEditingController()..text = "8086";
  final _enterRoomName = TextEditingController()..text = "testAndDebug56c238cd";
  final _ownName = TextEditingController()..text = "parent";
  final _enterRemoteName1 = TextEditingController()..text = "c";
  final _enterRemoteName2 = TextEditingController()..text = "s";
  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return VCall1to1AsObserverWidget(
            observedCall: VCall1to1RemoteObserver(
              [_enterRemoteName1.text, _enterRemoteName2.text],
              RoomSignalerImpl(
                  _enterRoomName.text, _ownName.text, true,
                  _enterHost.text, int.parse(_enterPort.text)
              )
            ),
          );
        }
      )
    );

    if(!initialConnectSuccessful) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Could not connect to Signaling-Server"),
            duration: Duration(seconds: 25)
          )
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if(kIsWeb) {
            return Text("CURRENTLY IMPOSSIBLE ON WEB - SEE BUG REPORT:\n"
                "https://github.com/flutter-webrtc/flutter-webrtc/issues/437");
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _enterHost,
                decoration: InputDecoration(hintText: 'Enter server address'),
              ),
              TextField(
                controller: _enterPort,
                decoration: InputDecoration(hintText: 'Enter server port'),
              ),
              TextField(
                controller: _enterRoomName,
                decoration: InputDecoration(hintText: 'Enter room name'),
              ),
              TextField(
                controller: _ownName,
                decoration: InputDecoration(hintText: 'Enter own name'),
              ),
              TextField(
                controller: _enterRemoteName1,
                decoration: InputDecoration(hintText:'Enter observed remote 1'),
              ),
              TextField(
                controller: _enterRemoteName2,
                decoration: InputDecoration(hintText:'Enter observed remote 2'),
              ),

              RaisedButton(
                onPressed: () => _sendLobby(context),
                color: Color(0xffFF1744),
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text('Connect'),
              )
            ],
          );
        }
      )
    );
  }
}
