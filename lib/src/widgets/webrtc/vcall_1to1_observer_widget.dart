import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../network/webrtc/calls/vcall_1to1_remote_observer.dart';
import '../../network/webrtc/signaling/signaling_minimal_impl.dart';
import '../michelangelo/circular_waiting_widget.dart';

///Widget to display a 1 to 1 call
class VCall1to1AsObserverWidget extends StatefulWidget {
  final String _ownName;
  final List<String> _remoteNames;
  final String _host;
  final int _port;

  ///Constructor - will init a VCall1to1 and a minimal signaler impl
  ///Will initialize and properly connect a local and remote provider
  ///Will properly connect signaler to remote provider
  VCall1to1AsObserverWidget({Key key,
    @required String ownName,
    @required List<String> remoteNames,
    @required String host,
    @required int port}) :
        _ownName = ownName,_remoteNames = remoteNames,_host = host,_port = port,
        super(key: key);

  @override
  _VCall1to1ObserverWS createState() => _VCall1to1ObserverWS(
    _ownName, _remoteNames, _host, _port
  );
}

class _VCall1to1ObserverWS extends State<VCall1to1AsObserverWidget> {
  final List<RTCVideoRenderer> _remoteRenderers = [];
  final VCall1to1RemoteObserver _callObserver;

  _VCall1to1ObserverWS(String self,List<String>remoteNames,String host,int port)
    : _callObserver = VCall1to1RemoteObserver(
      remoteNames, MinimalSignalerImpl(self, host, port)
  ) {
    if(_callObserver.remoteProviders.length != 2) {
      throw ArgumentError("this widget can only display two remotes");
    }
    for(var remoteProvider in _callObserver.remoteProviders) {
      var remoteRenderer = RTCVideoRenderer();
      _remoteRenderers.add(remoteRenderer);
      remoteProvider.addObserver((stream) async {
        remoteRenderer.srcObject = stream;
        if(mounted &&
            _callObserver.signaler!=null &&
            _callObserver.signaler.isConnected()) {
          setState(() {});
        }
      });
      remoteRenderer.onResize = () {
        if(mounted) {
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
    _callObserver.signaler.addOnClosedObserver((code) async {
      if(code != WebSocketStatus.normalClosure) {//if so, we already popped it
        Navigator.pop(context, false);
      }
    });
    for(var renderer in _remoteRenderers) {
      await renderer.initialize();
    }
    await _callObserver.init();
  }

  @override
  void dispose() async {
    super.dispose();
    await close();
  }

  Future<void> close() async {
    await _callObserver.close(closeSignalerConnection: true);
    for(var renderer in _remoteRenderers) {
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
            var remoteActive = renderer.renderVideo && renderer.videoHeight!= 0;
            index += 1;
            return Positioned(
              left: screenWidth * (index/length),
              width: screenWidth / length,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: screenWidth,
                height: screenHeight,
                child: remoteActive ?
                RTCVideoView(renderer)
                    :
                CircularWaitingWidget(
                    text: "Waiting...",
                    textSize: 44,
                    strokeWidth: 11,
                    size: min(screenWidth, screenHeight) - 22
                ),
                decoration: BoxDecoration(color: Colors.black54),
              )
            );
          }).toList();


          return Container(
            decoration: BoxDecoration(color: Colors.black54),
            child: Stack(children: stackChildren),
          );
        })
    );
  }
}



