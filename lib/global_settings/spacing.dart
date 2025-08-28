import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
}

extension Spacing on num {
  SizedBox get vSpace => SizedBox(height: toDouble());
  SizedBox get hSpace => SizedBox(width: toDouble());
}
