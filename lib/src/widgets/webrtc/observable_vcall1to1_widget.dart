import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

import '../../general/observers.dart';
import '../../network/webrtc/calls/observable_vcall_1to1.dart';
import 'vcall_1to1_widget.dart';

///Creates observale 1 to 1 call widget with additional info displays
///endTime parameter can be null
VCall1to1Widget createObservableVCall1to1Widget(
    ObservableVCall1to1 call, DateTime endTime) {
  var vcallwidget = VCall1to1Widget(
    call: call,
    rebuildObservables: <Observable>[call.remoteObserverProvider],
    additionalBuilder: (context, orientation) {
      var statusBarHeight = MediaQuery.of(context).padding.top;
      return (endTime == null
              ? <Positioned>[]
              : [
                  Positioned(
                    right: padding,
                    top: padding + statusBarHeight,
                    //the following api is not good, but it works
                    child: CountdownTimer(
                      endTime: endTime.millisecondsSinceEpoch,
                      widgetBuilder: (_, time) {
                        var min = (time == null || time.days == null
                                    ? 0
                                    : time.days) *
                                24 *
                                60 +
                            (time == null || time.hours == null
                                    ? 0
                                    : time.hours) *
                                60 +
                            (time == null || time.min == null ? 0 : time.min);
                        var text = 'Noch ${min}m';
                        var color = Colors.black;
                        if (min <= 3) {
                          text = 'Der Anruf endet bald.';
                          color = Colors.redAccent;
                        }
                        return Text(
                          text,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              shadows: [
                                Shadow(
                                  blurRadius: 1.0,
                                  color: Colors.grey,
                                ),
                              ]),
                        );
                      },
                    ),
                  ),
                ]) +
          [
            Positioned(
                left: padding,
                top: padding + statusBarHeight,
                child: call.remoteObserverProvider.isConnected()
                    ? Icon(Icons.person_pin_outlined, color: Colors.red)
                    : Text("")),
          ];
    },
  );

  return vcallwidget;
}
