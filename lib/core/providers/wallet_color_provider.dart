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

  // Kahverengi
  brown(
    label: 'Kahverengi',
    base: Color(0xFF5C3A1E),
    highlight: Color(0xFF7A5230),
    shadow: Color(0xFF3E2510),
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

  // Bordo / Koyu kırmızı (gider kırmızısından yeterince farklı)
  burgundy(
    label: 'Bordo',
    base: Color(0xFF5A1A2A),
    highlight: Color(0xFF7A2E3E),
    shadow: Color(0xFF3E0E1A),
  ),

  // Morlar
  plum(
    label: 'Mor',
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
