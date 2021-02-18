import 'package:flutter/material.dart';

///A wrapper around the CircularProgressIndicator, with text inside
class CircularWaitingWidget extends StatelessWidget {
  ///width and height in pixels
  final double size;

  ///Text, length of text not checked to fit
  final String text;

  ///Size of text
  final double textSize;

  ///Width of circular indicator
  final double strokeWidth;

  ///Constructor
  const CircularWaitingWidget(
      {Key key,
      this.size,
      this.text,
      this.textSize = 30,
      this.strokeWidth = 11})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white12)),
            ),
          ),
          Center(
              child: Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              color: Colors.white24,
            ),
          )),
        ],
      ),
    );
  }
}
