
import 'package:flutter/material.dart';

class AppStyles {

  static final double _baseFontSize = 16;

  static double get baseFontSize => _baseFontSize;

  static TextStyle get normalText => TextStyle(fontSize: _baseFontSize);
  static TextStyle get titleText => TextStyle(fontSize: _baseFontSize + 16, fontWeight: FontWeight.bold);
  static TextStyle get subtitleText => TextStyle(fontSize: _baseFontSize + 8, fontWeight: FontWeight.w600);

  static TextStyle hightlightSwitch(int value) {
    return value >= 0 ? highlightGood : highlightBad;
  }

  static TextStyle get highlightGood => TextStyle(fontSize: _baseFontSize, color: Colors.green, fontWeight: FontWeight.bold);
  static TextStyle get highlightBad => TextStyle(fontSize: _baseFontSize, color: Colors.red, fontWeight: FontWeight.bold);
}