import 'package:flutter/material.dart';

import 'test_connect_observable_vcall1to1_widget.dart';
import 'test_connect_vcall1to1_as_observer_widget.dart';
import 'test_connect_vcall1to1_in_room_widget.dart';
import 'test_connect_vcall1to1_widget.dart';

///TEST ONLY
class TestChooseConnectTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea (
        child: Column(
          children: [
            RaisedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TestConnectTo1to1CallWidget()
              )),
              textColor: Colors.white,
              child: Text('Test connect to 1to1 video call'),
            ),
            RaisedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TestConnectAsObserverWidget()
              )),
              textColor: Colors.white,
              child: Text('Test connect as observer to 1to1 video call'),
            ),
            RaisedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TestConnectTo1to1ObservableCallWidget()
              )),
              textColor: Colors.white,
              child: Text('Test connect to observable 1to1 video call'),
            ),
            RaisedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TestConnectTo1to1CallInRoomWidget()
              )),
              textColor: Colors.white,
              child: Text('Test connect to 1to1 video call in room'),
            ),
          ],
        )
      ),
    );
  }
}