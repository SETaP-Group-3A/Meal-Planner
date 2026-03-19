
import 'package:flutter/material.dart';

class AppStyles {

  static final double _baseFontSize = 16;

  static double get baseFontSize => _baseFontSize;

  static TextStyle get normalText => TextStyle(fontSize: _baseFontSize);
  static TextStyle get titleText => TextStyle(fontSize: _baseFontSize + 4, fontWeight: FontWeight.bold);
}