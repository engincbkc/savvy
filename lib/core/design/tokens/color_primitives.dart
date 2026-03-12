import 'dart:ui';

/// Primitive color palette - DO NOT use directly in widgets.
/// Use [AppColors] semantic tokens instead.
abstract class ColorPrimitives {
  // Blue
  static const blue900 = Color(0xFF1E3A5F);
  static const blue800 = Color(0xFF1E429F);
  static const blue700 = Color(0xFF1A56DB);
  static const blue600 = Color(0xFF1C64F2);
  static const blue500 = Color(0xFF3F83F8);
  static const blue400 = Color(0xFF76A9FA);
  static const blue100 = Color(0xFFE1EFFE);
  static const blue50 = Color(0xFFEBF5FF);

  // Green
  static const green900 = Color(0xFF014737);
  static const green800 = Color(0xFF03543F);
  static const green700 = Color(0xFF046C4E);
  static const green600 = Color(0xFF057A55);
  static const green500 = Color(0xFF0E9F6E);
  static const green400 = Color(0xFF31C48D);
  static const green200 = Color(0xFFBCF0DA);
  static const green100 = Color(0xFFDEF7EC);
  static const green50 = Color(0xFFF3FAF7);

  // Red
  static const red900 = Color(0xFF771D1D);
  static const red700 = Color(0xFF9B1C1C);
  static const red600 = Color(0xFFC81E1E);
  static const red500 = Color(0xFFE02424);
  static const red400 = Color(0xFFF05252);
  static const red100 = Color(0xFFFDE8E8);
  static const red50 = Color(0xFFFDF2F2);

  // Amber / Gold
  static const amber900 = Color(0xFF633112);
  static const amber700 = Color(0xFF8E4B10);
  static const amber600 = Color(0xFFD97706);
  static const amber500 = Color(0xFFF59E0B);
  static const amber400 = Color(0xFFFBBF24);
  static const amber100 = Color(0xFFFDE8C8);
  static const amber50 = Color(0xFFFFF8EE);

  // Neutral
  static const gray950 = Color(0xFF030712);
  static const gray900 = Color(0xFF111827);
  static const gray800 = Color(0xFF1F2937);
  static const gray700 = Color(0xFF374151);
  static const gray600 = Color(0xFF4B5563);
  static const gray500 = Color(0xFF6B7280);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray50 = Color(0xFFF9FAFB);
  static const white = Color(0xFFFFFFFF);

  // Dark surfaces
  static const dark950 = Color(0xFF0A0F1E);
  static const dark900 = Color(0xFF0F172A);
  static const dark800 = Color(0xFF1E293B);
  static const dark700 = Color(0xFF253347);
  static const dark600 = Color(0xFF334155);
  static const dark500 = Color(0xFF475569);
}
