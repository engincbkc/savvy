import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_color_provider.g.dart';

/// Preset wallet colors users can choose from.
/// Excluded: greens (clashes with income), reds/oranges (clashes with expense),
/// yellows (clashes with savings).
enum WalletColor {
  // Klasikler
  black(
    label: 'Siyah',
    base: Color(0xFF1A1A1A),
    highlight: Color(0xFF3A3A3A),
    shadow: Color(0xFF0A0A0A),
  ),
  charcoal(
    label: 'Antrasit',
    base: Color(0xFF2D2D2D),
    highlight: Color(0xFF4A4A4A),
    shadow: Color(0xFF1A1A1A),
  ),
  grey(
    label: 'Gri',
    base: Color(0xFF6B7280),
    highlight: Color(0xFF8890A0),
    shadow: Color(0xFF4B5260),
  ),

  // Kahverengiler
  brown(
    label: 'Kahverengi',
    base: Color(0xFF5C3A1E),
    highlight: Color(0xFF7A5230),
    shadow: Color(0xFF3E2510),
  ),
  tan(
    label: 'Taba',
    base: Color(0xFF8B6914),
    highlight: Color(0xFFA88030),
    shadow: Color(0xFF6A500E),
  ),
  camel(
    label: 'Deve Tüyü',
    base: Color(0xFFA0784A),
    highlight: Color(0xFFBC9260),
    shadow: Color(0xFF7A5C36),
  ),
  cream(
    label: 'Krem',
    base: Color(0xFFD2C4A8),
    highlight: Color(0xFFE4D8C0),
    shadow: Color(0xFFB0A488),
  ),

  // Maviler
  navy(
    label: 'Lacivert',
    base: Color(0xFF1B2A4A),
    highlight: Color(0xFF2D3F62),
    shadow: Color(0xFF0F1A30),
  ),
  royalBlue(
    label: 'Mavi',
    base: Color(0xFF1E3A8A),
    highlight: Color(0xFF3050A8),
    shadow: Color(0xFF122460),
  ),
  teal(
    label: 'Petrol',
    base: Color(0xFF0F4C5C),
    highlight: Color(0xFF1A6678),
    shadow: Color(0xFF083440),
  ),
  skyBlue(
    label: 'Bebe Mavi',
    base: Color(0xFF4A90B8),
    highlight: Color(0xFF68A8D0),
    shadow: Color(0xFF36709A),
  ),

  // Bordo / Koyu kırmızı (gider kırmızısından yeterince farklı)
  burgundy(
    label: 'Bordo',
    base: Color(0xFF5A1A2A),
    highlight: Color(0xFF7A2E3E),
    shadow: Color(0xFF3E0E1A),
  ),
  wine(
    label: 'Koyu Bordo',
    base: Color(0xFF722F37),
    highlight: Color(0xFF904050),
    shadow: Color(0xFF4E1E24),
  ),

  // Pembeler
  blush(
    label: 'Pudra',
    base: Color(0xFFB87C8A),
    highlight: Color(0xFFD096A4),
    shadow: Color(0xFF9A6070),
  ),
  rosePink(
    label: 'Gül Kurusu',
    base: Color(0xFFC27088),
    highlight: Color(0xFFDA8AA0),
    shadow: Color(0xFFA05870),
  ),
  hotPink(
    label: 'Pembe',
    base: Color(0xFFD63384),
    highlight: Color(0xFFE8509A),
    shadow: Color(0xFFAA2068),
  ),
  babyPink(
    label: 'Bebe Pembe',
    base: Color(0xFFE8A0B0),
    highlight: Color(0xFFF0B8C6),
    shadow: Color(0xFFC88090),
  ),

  // Morlar
  plum(
    label: 'Erik',
    base: Color(0xFF4A1942),
    highlight: Color(0xFF663060),
    shadow: Color(0xFF30102A),
  ),
  lavender(
    label: 'Lavanta',
    base: Color(0xFF7B6B9E),
    highlight: Color(0xFF9585B8),
    shadow: Color(0xFF5C5080),
  );

  const WalletColor({
    required this.label,
    required this.base,
    required this.highlight,
    required this.shadow,
  });

  final String label;
  final Color base;
  final Color highlight;
  final Color shadow;
}

@Riverpod(keepAlive: true)
class WalletColorNotifier extends _$WalletColorNotifier {
  @override
  WalletColor build() => WalletColor.black;

  void set(WalletColor color) => state = color;
}
