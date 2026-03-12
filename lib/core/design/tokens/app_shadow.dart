import 'package:flutter/painting.dart';

/// Shadow & elevation tokens.
abstract class AppShadow {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x18000000), blurRadius: 32, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x1E000000), blurRadius: 48, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  // Financial card colored shadows
  static const List<BoxShadow> income = [
    BoxShadow(color: Color(0x330E9F6E), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x150E9F6E), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> expense = [
    BoxShadow(color: Color(0x33E02424), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x15E02424), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> savings = [
    BoxShadow(color: Color(0x33D97706), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x15D97706), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> hero = [
    BoxShadow(color: Color(0x1A1A56DB), blurRadius: 40, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> overlay = [
    BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, -4)),
  ];
}
