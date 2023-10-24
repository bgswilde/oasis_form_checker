import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

Map<String, Color> flatUIColors = {
  "darkBackground": Color(0xFF2A363B),
  "primaryLightBackground":
      Color(0xFFFECEAB),
  "secondaryLightBackground":
      Color(0xFFFF847C),
  "alt1": Color(0xFF99B898),
  "alt2": Color(0xFFE84A5F),
};

Color getTextColorForBackground(Color backgroundColor) {
  // Calculate the contrast between the background color and white (or black).
  // You can use a formula like this:
  // (Luma = 0.299 * R + 0.587 * G + 0.114 * B)
  // If the luma is greater than 128, use black text; otherwise, use white text.
  double luma = 0.299 * backgroundColor.red +
      0.587 * backgroundColor.green +
      0.114 * backgroundColor.blue;

  return luma > 128 ? Colors.black : Colors.white;
}
