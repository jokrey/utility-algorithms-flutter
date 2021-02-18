import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import '../../../network/webrtc/calls/observable_vcall_1to1.dart';
import '../../../network/webrtc/signaling/signaling_room_impl.dart';
import '../../michelangelo/big_wide_button.dart';
import '../ice_server_config_widget.dart';
import '../observable_vcall1to1_widget.dart';

///TEST ONLY
class TestConnectTo1to1ObservableCallInRoomWidget extends StatefulWidget {
  final String _initialBaseUrl,
      _initialRoomName,
      _initialOwnName,
      _initialRemoteName,
      _initialAllowedObserverName;
  final DateTime _expectedMeetingEndTime;
  final List<Map<String, String>> _initialIceServers;

  ///Creates the widget with data set as default
  TestConnectTo1to1ObservableCallInRoomWidget.withDefaults(
      this._initialBaseUrl,
      this._initialRoomName,
      this._initialOwnName,
      this._initialRemoteName,
      this._initialAllowedObserverName,
      this._expectedMeetingEndTime,
      this._initialIceServers);

  _TestConnectTo1to1ObservableCallInRoomWidgetState createState() =>
      _TestConnectTo1to1ObservableCallInRoomWidgetState(
          _initialBaseUrl,
          _initialRoomName,
          _initialOwnName,
          _initialRemoteName,
          _initialAllowedObserverName,
          _expectedMeetingEndTime,
          _initialIceServers);
}

///TEST ONLY
class _TestConnectTo1to1ObservableCallInRoomWidgetState
    extends State<TestConnectTo1to1ObservableCallInRoomWidget> {
  final _enterIceServers,
      _enterBaseUrl,
      _enterRoomName,
      _enterOwnName,
      _enterRemoteName,
      _enterAllowedRemoteObserver;
  DateTime _enterExpectedMeetingEndTime;

  _TestConnectTo1to1ObservableCallInRoomWidgetState(baseUrl, roomName, ownName,
      remoteName, allowedObserverName, expectedMeetingEndTime, iceServers)
      : _enterIceServers = IceServersConfigurationController()
          ..iceServers = iceServers,
        _enterBaseUrl = TextEditingController()..text = baseUrl,
        _enterRoomName = TextEditingController()..text = roomName,
        _enterOwnName = TextEditingController()..text = ownName,
        _enterRemoteName = TextEditingController()..text = remoteName,
        _enterExpectedMeetingEndTime = expectedMeetingEndTime,
        _enterAllowedRemoteObserver = TextEditingController()
          ..text = allowedObserverName;

  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return createObservableVCall1to1Widget(
          ObservableVCall1to1(
            _enterOwnName.text,
            _enterRemoteName.text,
            _enterAllowedRemoteObserver.text,
            RoomSignalerImpl(
              _enterRoomName.text,
              _enterOwnName.text,
              _enterBaseUrl.text,
            ),
            _enterIceServers.iceServers,
          ),
          _enterExpectedMeetingEndTime);
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
              decoration: InputDecoration(hintText: 'Enter the room name'),
            ),
            TextField(
              controller: _enterOwnName,
              decoration: InputDecoration(hintText: 'Enter your name'),
            ),
            TextField(
              controller: _enterRemoteName,
              decoration: InputDecoration(hintText: 'Enter the remote name'),
            ),
            TextField(
              controller: _enterAllowedRemoteObserver,
              decoration: InputDecoration(
                hintText: 'Enter the allowed remote observer name',
              ),
            ),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              initialValue: _enterExpectedMeetingEndTime.toString(),
              icon: Icon(Icons.event),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              dateLabelText: 'Expected Meeting Date',
              timeHintText: 'End Time',
              onChanged: (val) =>
                  _enterExpectedMeetingEndTime = DateTime.tryParse(val),
              validator: (val) {
                return null;
              },
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
