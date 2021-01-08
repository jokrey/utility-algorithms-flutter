import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../network/webrtc/calls/vcall_1to1.dart';
import '../michelangelo/circular_waiting_widget.dart';

///Widget to display a 1 to 1 call
class VCall1to1Widget extends StatefulWidget {
  final VCall1to1 _call;

  ///Constructor
  VCall1to1Widget({Key key, @required VCall1to1 call})
      : _call = call, super(key: key);

  @override
  _VCall1to1WidgetState createState() => _VCall1to1WidgetState(_call);
}

class _VCall1to1WidgetState extends State<VCall1to1Widget> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final VCall1to1 call;

  _VCall1to1WidgetState(this.call) {
    call.localProvider.addObserver((stream) async {
      _localRenderer.srcObject = stream;
      if(mounted && call.signaler != null && call.signaler.isConnected()) {
        setState(() {});
      }
    });
    call.remoteProvider.addObserver((stream) async {
      _remoteRenderer.srcObject = stream;
      if(mounted && call.signaler != null && call.signaler.isConnected()) {
        setState(() {});
      }
    });
    _localRenderer.onResize = () {
      if(mounted && call.signaler != null && call.signaler.isConnected()) {
        setState(() {});
      }
    };
    _remoteRenderer.onResize = () {
      if(mounted && call.signaler != null && call.signaler.isConnected()) {
        setState(() {});
      }
    };
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    try {
      call.signaler.addOnClosedObserver((code) async {
        if(mounted) {
          Navigator.pop(context, false);
        }
      });
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      await call.init();
    // ignore: avoid_catches_without_on_clauses
    } catch (e) {//required, because anything can be thrown, not just exceptions
      print("error in init: $e");
      if(mounted) {
        Navigator.pop(context, false);
      }
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await close();
  }

  Future<void> close() async {
    await call.close(closeSignalerConnection: true);
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
            width: 200.0,
            child: Row (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: null,
                    child: const Icon(Icons.switch_camera),
                    onPressed: call.localProvider.switchCamera,
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    tooltip: 'Hangup',
                    child: Icon(Icons.call_end),
                    backgroundColor: Colors.pink,
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    child: call.localProvider.isMicMuted() ?
                    const Icon(Icons.mic_off) : const Icon(Icons.mic),
                    onPressed: ()=> setState(call.localProvider.toggleMuteMic),
                  ),
                ]
            )
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          var statusBarHeight = MediaQuery.of(context).padding.top;
          var screenWidth = MediaQuery.of(context).size.width;
          var screenHeight = MediaQuery.of(context).size.height;
          var padding = 20.0;
          var maxLDw = min(screenWidth * 0.33, screenWidth-2*padding);
          var maxLDh = min(screenHeight * 0.33, screenHeight-2*padding);
          var localActive =
              _localRenderer.renderVideo && _localRenderer.videoHeight != 0;
          var remoteActive =
              _remoteRenderer.renderVideo && _remoteRenderer.videoHeight != 0;

          var vW = localActive? _localRenderer.videoWidth.toDouble() : 640;
          var vH = localActive? _localRenderer.videoHeight.toDouble() : 480;
          //todo - this is like a magic number, but missing func in webrtc:
          if(orientation == Orientation.landscape || kIsWeb) {
            var tvW = vW;vW=vH;vH=tvW;
          }
          var lDw = min(maxLDw, maxLDh) * (vH / (max(vW, vH)));
          var lDh = min(maxLDw, maxLDh) * (vW / (max(vW, vH)));

          return Container(
            decoration: BoxDecoration(color: Colors.black54),
            child: Stack(children: <Widget>[
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 0.0,
                bottom: 0.0,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: screenWidth,
                  height: screenHeight,
                  child: remoteActive ?
                      RTCVideoView(_remoteRenderer)
                    :
                      CircularWaitingWidget(
                        text: "Waiting...",
                        textSize: 44,
                        strokeWidth: 11,
                        size: min(screenWidth, screenHeight)-22
                      ),
                  decoration: BoxDecoration(color: Colors.black54),
                )
              ),
              Positioned(
                left: padding,
                top: padding + statusBarHeight,
                child: Container(
                  width: lDw,
                  height: lDh,
                  child: localActive ?
                    RTCVideoView(_localRenderer, mirror: true)
                      :
                    CircularWaitingWidget(
                      text: "Waiting...",
                      textSize: 22,
                      strokeWidth: 4,
                      size: min(lDw, lDh) - 8
                    ),
                  decoration: BoxDecoration(
                    color: localActive ? Colors.transparent : Colors.black87
                  ),
                ),
              )
            ]),
          );
        })
    );
  }
}



