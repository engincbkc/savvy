import 'package:flutter/animation.dart';

/// Duration tokens for animations.
abstract class AppDuration {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration moderate = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 750);
  static const Duration countUp = Duration(milliseconds: 900);
}

/// Curve tokens for animations.
abstract class AppCurve {
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve overshoot = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;
  static const Curve linear = Curves.linear;
}
