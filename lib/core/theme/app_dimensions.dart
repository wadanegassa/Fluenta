import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing scale (multiples of 4)
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s48 = 48.0;
  static const s64 = 64.0;

  // Border radius
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusXL = 24.0;
  static const radiusRound = 100.0;

  // Screen padding
  static const screenPadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const screenPaddingV = EdgeInsets.symmetric(vertical: 16.0);

  // Card elevation
  static const cardElevation = 0.0; // Use border + shadow, not Flutter elevation
}
