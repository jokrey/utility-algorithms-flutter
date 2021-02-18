import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../network/webrtc/calls/vcall_1to1.dart';
import '../../../network/webrtc/provider/stream_provider_remote.dart';
import '../../../network/webrtc/signaling/signaling_room_impl.dart';
import '../../michelangelo/big_wide_button.dart';
import '../ice_server_config_widget.dart';
import '../vcall_1to1_widget.dart';

///TEST ONLY
class TestConnectTo1to1CallInRoomWidget extends StatefulWidget {
  _TestConnectTo1to1CallInRoomWidgetState createState() =>
      _TestConnectTo1to1CallInRoomWidgetState();
}

///TEST ONLY
class _TestConnectTo1to1CallInRoomWidgetState
    extends State<TestConnectTo1to1CallInRoomWidget> {
  final _enterIceServers = IceServersConfigurationController()
    ..iceServers = defaultIceServers;
  final _enterBaseUrl = TextEditingController()
    ..text = "https://mlabstayin.rocks/signaling";
  final _enterRoomName = TextEditingController()..text = "testAndDebug";
  final _enterOwnName = TextEditingController()..text = kIsWeb ? "c" : "s";
  final _enterRemoteName = TextEditingController()..text = kIsWeb ? "s" : "c";
  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VCall1to1Widget(
        call: VCall1to1(
          _enterOwnName.text,
          _enterRemoteName.text,
          RoomSignalerImpl(
            _enterRoomName.text,
            _enterOwnName.text,
            _enterBaseUrl.text,
          ),
          _enterIceServers.iceServers,
        ),
      );
    }));

    if (!initialConnectSuccessful) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text("Could not connect. Has the call started?"),
            duration: Duration(seconds: 25)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WidthFillingTextButton(
                "Configure Ice Servers(${_enterIceServers.iceServers.length})",
                onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      IceServersConfigurationWidget(_enterIceServers),
                ),
              );
              setState(() {}); //rebuild ice server count in text above
            }),
            TextField(
              controller: _enterBaseUrl,
              decoration: InputDecoration(
                hintText:
                    'Enter base server url {ex: http(s)://dns(:port)/route}',
              ),
            ),
            TextField(
              controller: _enterRoomName,
              decoration: InputDecoration(hintText: 'Enter room name'),
            ),
            TextField(
              controller: _enterOwnName,
              decoration: InputDecoration(hintText: 'Enter your name'),
            ),
            TextField(
              controller: _enterRemoteName,
              decoration: InputDecoration(hintText: 'Enter the remote name'),
            ),
            RaisedButton(
              onPressed: () => _sendLobby(context),
              color: Color(0xffFF1744),
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text('Connect'),
            )
          ],
        ),
      ),
    );
  }
}
