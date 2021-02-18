import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../network/webrtc/calls/vcall_1to1_remote_observer.dart';
import '../michelangelo/circular_waiting_widget.dart';

///Widget to display a 1 to 1 call
class VCall1to1AsObserverWidget extends StatefulWidget {
  final VCall1to1RemoteObserver _observedCall;

  ///Constructor - will init a VCall1to1 and a minimal signaler impl
  ///Will initialize and properly connect a local and remote provider
  ///Will properly connect signaler to remote provider
  VCall1to1AsObserverWidget(
      {Key key, @required VCall1to1RemoteObserver observedCall})
      : _observedCall = observedCall,
        super(key: key);

  @override
  _VCall1to1ObserverWS createState() => _VCall1to1ObserverWS(_observedCall);
}

class _VCall1to1ObserverWS extends State<VCall1to1AsObserverWidget> {
  final VCall1to1RemoteObserver _observedCall;
  final List<RTCVideoRenderer> _remoteRenderers = [];

  _VCall1to1ObserverWS(this._observedCall) {
    if (_observedCall.remoteProviders.length != 2) {
      throw ArgumentError("this widget can only display two remotes");
    }
    for (var remoteProvider in _observedCall.remoteProviders) {
      var remoteRenderer = RTCVideoRenderer();
      _remoteRenderers.add(remoteRenderer);
      remoteProvider.addObserver((stream) async {
        remoteRenderer.srcObject = stream;
        if (mounted &&
            _observedCall.signaler != null &&
            _observedCall.signaler.isConnected()) {
          setState(() {});
        }
      });
      remoteRenderer.onResize = () {
        if (mounted) {
          setState(() {});
        }
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    try {
      _observedCall.signaler.addOnClosedObserver((code) async {
        if (mounted) {
          Navigator.pop(context, false);
        }
      });
      for (var renderer in _remoteRenderers) {
        await renderer.initialize();
      }
      await _observedCall.init();
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      //required, because anything can be thrown, not just exceptions
      print("error in init: $e");
      if (mounted) {
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
    await _observedCall.close(closeSignalerConnection: true);
    for (var renderer in _remoteRenderers) {
      await renderer.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Navigator.pop(context, true);
          },
          tooltip: 'Hangup',
          child: Icon(Icons.call_end),
          backgroundColor: Colors.pink,
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          var screenWidth = MediaQuery.of(context).size.width;
          var screenHeight = MediaQuery.of(context).size.height;

          var index = -1;
          var length = _remoteRenderers.length.toDouble();
          var stackChildren = _remoteRenderers.map((renderer) {
            var remoteActive =
                renderer.renderVideo && renderer.videoHeight != 0;
            index += 1;
            return Positioned(
                left: screenWidth * (index / length),
                width: screenWidth / length,
                top: 0.0,
                bottom: 0.0,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: screenWidth,
                  height: screenHeight,
                  child: remoteActive
                      ? RTCVideoView(renderer)
                      : CircularWaitingWidget(
                          text: "Warte auf 📷...",
                          textSize: 44,
                          strokeWidth: 11,
                          size: min(screenWidth, screenHeight) - 22),
                  decoration: BoxDecoration(color: Colors.black54),
                ));
          }).toList();

          return Container(
            decoration: BoxDecoration(color: Colors.black54),
            child: Stack(children: stackChildren),
          );
        }));
  }
}
