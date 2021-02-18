import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../network/webrtc/calls/observable_vcall_1to1.dart';
import '../../../network/webrtc/provider/stream_provider_remote.dart';
import '../../../network/webrtc/signaling/signaling_minimal_impl.dart';
import '../../michelangelo/big_wide_button.dart';
import '../ice_server_config_widget.dart';
import '../observable_vcall1to1_widget.dart';

///TEST ONLY
class TestConnectTo1to1ObservableCallWidget extends StatefulWidget {
  _TestConnectTo1to1ObservableCallWidgetState createState() =>
      _TestConnectTo1to1ObservableCallWidgetState();
}

///TEST ONLY
class _TestConnectTo1to1ObservableCallWidgetState
    extends State<TestConnectTo1to1ObservableCallWidget> {
  final _enterIceServers = IceServersConfigurationController()
    ..iceServers = defaultIceServers;
  final _enterBaseUrl = TextEditingController();
  final _enterOwnName = TextEditingController()..text = kIsWeb ? "c" : "s";
  final _enterRemoteName = TextEditingController()..text = kIsWeb ? "s" : "c";
  final _enterAllowedRemoteObserver = TextEditingController()..text = "parent";

  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return createObservableVCall1to1Widget(
            ObservableVCall1to1(
              _enterOwnName.text,
              _enterRemoteName.text,
              _enterAllowedRemoteObserver.text,
              MinimalSignalerImpl(_enterOwnName.text, _enterBaseUrl.text),
              _enterIceServers.iceServers,
            ),
            null);
      }),
    );

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
              controller: _enterOwnName,
              autocorrect: true,
              decoration: InputDecoration(hintText: 'Enter your name'),
            ),
            TextField(
              controller: _enterRemoteName,
              autocorrect: true,
              decoration: InputDecoration(hintText: 'Enter the remote name'),
            ),
            TextField(
              controller: _enterAllowedRemoteObserver,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: 'Enter the allowed remote observer name',
              ),
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
