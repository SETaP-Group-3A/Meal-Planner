
import 'package:flutter/material.dart';

class AppStyles {

  static final double _baseFontSize = 16;

  static final (Color, Color) _textColour = (Colors.black, Colors.white);

  static double get baseFontSize => _baseFontSize;

  static TextStyle get normalText => TextStyle(fontSize: _baseFontSize, color: isDarkMode(_textColour));

  static dynamic isDarkMode((dynamic, dynamic) options) {

    //actually check preference
    bool darkMode = false;

    if (darkMode)
    {
      return options.$2;
    }

    return options.$1;
  }
}

TextStyle get normalText => AppStyles.normalText;