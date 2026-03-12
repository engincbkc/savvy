import 'package:flutter/painting.dart';

/// Border radius tokens.
abstract class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double full = 9999.0;

  // Ready-made BorderRadius
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardLg = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
  static const BorderRadius bottomSheet =
      BorderRadius.vertical(top: Radius.circular(xl2));
  static const BorderRadius modal = BorderRadius.all(Radius.circular(xl3));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius topOnly =
      BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius bottomOnly =
      BorderRadius.vertical(bottom: Radius.circular(lg));
}
