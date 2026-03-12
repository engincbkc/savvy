import 'package:flutter/painting.dart';

/// Spacing tokens — 4px base grid system.
abstract class AppSpacing {
  static const double _base = 4.0;

  static const double xs = _base * 1; //  4px
  static const double sm = _base * 2; //  8px
  static const double md = _base * 3; // 12px
  static const double base = _base * 4; // 16px — standard padding
  static const double lg = _base * 5; // 20px — screen horizontal padding
  static const double xl = _base * 6; // 24px
  static const double xl2 = _base * 8; // 32px
  static const double xl3 = _base * 10; // 40px
  static const double xl4 = _base * 12; // 48px
  static const double xl5 = _base * 16; // 64px

  // Ready-made padding sets
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets screen =
      EdgeInsets.symmetric(horizontal: lg, vertical: base);
  static const EdgeInsets card = EdgeInsets.all(base);
  static const EdgeInsets cardLg = EdgeInsets.all(xl);
  static const EdgeInsets section =
      EdgeInsets.symmetric(horizontal: lg, vertical: xl);
  static const EdgeInsets listTile =
      EdgeInsets.symmetric(horizontal: base, vertical: md);

  // Touch target — min 48x48
  static const double minTouchTarget = 48.0;
  static const double cardMinHeight = 80.0;
  static const double bottomNavHeight = 64.0;
  static const double fabSize = 56.0;
  static const double fabSizeSm = 40.0;
}
