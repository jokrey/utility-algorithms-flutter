import 'package:flutter/material.dart';

///this is a color
const defaultButtonBgColor = Color(0xff5000e6);

///this is a big wide button
class WidthFillingTextButton extends SizedBox {
  ///Constructor for a big wide button
  WidthFillingTextButton(String text,
      {VoidCallback onPressed, Color bg = defaultButtonBgColor})
      : super(
            width: double.infinity, // match_parent
            child: RaisedButton(
              child: Text(text),
              onPressed: onPressed,
              color: bg,
              textColor: Colors.white,
            ));
}
