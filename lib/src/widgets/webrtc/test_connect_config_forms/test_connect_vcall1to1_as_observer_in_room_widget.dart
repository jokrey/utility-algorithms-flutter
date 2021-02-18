import 'package:flutter/material.dart';

import '../../../network/webrtc/calls/vcall_1to1_remote_observer.dart';
import '../../../network/webrtc/signaling/signaling_room_impl.dart';
import '../../michelangelo/big_wide_button.dart';
import '../ice_server_config_widget.dart';
import '../vcall_1to1_observer_widget.dart';

///TEST ONLY
class TestConnectAsObserverInRoomWidget extends StatefulWidget {
  final String _initialBaseUrl,
      _initialRoomName,
      _initialOwnName,
      _initialRemote1Name,
      _initialRemote2Name;
  final List<Map<String, String>> _initialIceServers;

  ///Creates the widget with data set as default
  TestConnectAsObserverInRoomWidget.withDefaults(
      this._initialBaseUrl,
      this._initialRoomName,
      this._initialOwnName,
      this._initialRemote1Name,
      this._initialRemote2Name,
      this._initialIceServers);

  _TestConnectAsObserverInRoomWidgetState createState() =>
      _TestConnectAsObserverInRoomWidgetState(
          _initialBaseUrl,
          _initialRoomName,
          _initialOwnName,
          _initialRemote1Name,
          _initialRemote2Name,
          _initialIceServers);
}

class _TestConnectAsObserverInRoomWidgetState
    extends State<TestConnectAsObserverInRoomWidget> {
  final _enterIceServers,
      _enterBaseUrl,
      _enterRoomName,
      _enterOwnName,
      _enterRemote1Name,
      _enterRemote2Name;

  _TestConnectAsObserverInRoomWidgetState(
      baseUrl, roomName, ownName, remote1Name, remote2Name, iceServers)
      : _enterIceServers = IceServersConfigurationController()
          ..iceServers = iceServers,
        _enterBaseUrl = TextEditingController()..text = baseUrl,
        _enterRoomName = TextEditingController()..text = roomName,
        _enterOwnName = TextEditingController()..text = ownName,
        _enterRemote1Name = TextEditingController()..text = remote1Name,
        _enterRemote2Name = TextEditingController()..text = remote2Name;

  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VCall1to1AsObserverWidget(
        observedCall: VCall1to1RemoteObserver(
          [_enterRemote1Name.text, _enterRemote2Name.text],
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
          duration: Duration(seconds: 25),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        return Column(
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
                  ));
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
              decoration: InputDecoration(hintText: 'Enter own name'),
            ),
            TextField(
              controller: _enterRemote1Name,
              decoration: InputDecoration(hintText: 'Enter observed remote 1'),
            ),
            TextField(
              controller: _enterRemote2Name,
              decoration: InputDecoration(hintText: 'Enter observed remote 2'),
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
      }),
    );
  }
}
