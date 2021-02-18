import 'package:flutter/material.dart';

import '../../../network/webrtc/calls/vcall_1to1_remote_observer.dart';
import '../../../network/webrtc/provider/stream_provider_remote.dart';
import '../../../network/webrtc/signaling/signaling_minimal_impl.dart';
import '../../michelangelo/big_wide_button.dart';
import '../ice_server_config_widget.dart';
import '../vcall_1to1_observer_widget.dart';

///TEST ONLY
class TestConnectAsObserverWidget extends StatefulWidget {
  _TestConnectAsObserverWidgetState createState() =>
      _TestConnectAsObserverWidgetState();
}

class _TestConnectAsObserverWidgetState
    extends State<TestConnectAsObserverWidget> {
  final _enterIceServers = IceServersConfigurationController()
    ..iceServers = defaultIceServers;
  final _enterBaseUrl = TextEditingController()
    ..text = "https://mlabstayin.rocks/signaling";
  final _ownName = TextEditingController()..text = "parent";
  final _enterRemoteName1 = TextEditingController()..text = "c";
  final _enterRemoteName2 = TextEditingController()..text = "s";
  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VCall1to1AsObserverWidget(
        observedCall: VCall1to1RemoteObserver(
          [_enterRemoteName1.text, _enterRemoteName2.text],
          MinimalSignalerImpl(_ownName.text, _enterBaseUrl.text),
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
              controller: _ownName,
              autocorrect: true,
              decoration: InputDecoration(hintText: 'Enter own name'),
            ),
            TextField(
              controller: _enterRemoteName1,
              autocorrect: true,
              decoration: InputDecoration(hintText: 'Enter observed remote 1'),
            ),
            TextField(
              controller: _enterRemoteName2,
              autocorrect: true,
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
