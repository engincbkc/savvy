import 'package:flutter/material.dart';

/// Each CustomClipper creates a rectangle with a category-specific
/// silhouette along its bottom edge. The top stays flat (rounded by
/// the parent ClipRRect).

// ─── Car: side profile — roof curve + hood ──────────────────────
class CarSilhouetteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.55) // right side drops to hood level
      // Hood (right)
      ..lineTo(w * 0.72, h * 0.55)
      // Windshield angle up
      ..lineTo(w * 0.62, h * 0.30)
      // Roof
      ..lineTo(w * 0.28, h * 0.30)
      // Rear window angle down
      ..lineTo(w * 0.20, h * 0.50)
      // Trunk
      ..lineTo(w * 0.12, h * 0.50)
      // Rear drop
      ..lineTo(w * 0.08, h * 0.65)
      ..lineTo(0, h * 0.65)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─── Housing: triangle roof + chimney ───────────────────────────
class HouseSilhouetteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.60)
      // Right eave
      ..lineTo(w * 0.85, h * 0.60)
      // Right roof slope up to chimney
      ..lineTo(w * 0.65, h * 0.28)
      // Chimney right side up
      ..lineTo(w * 0.65, h * 0.15)
      // Chimney top
      ..lineTo(w * 0.58, h * 0.15)
      // Chimney left side back to roof
      ..lineTo(w * 0.58, h * 0.25)
      // Roof peak
      ..lineTo(w * 0.50, h * 0.20)
      // Left roof slope down
      ..lineTo(w * 0.15, h * 0.60)
      // Left eave
      ..lineTo(0, h * 0.60)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─── Credit: card shape — rounded top, gentle curve bottom ──────
class CreditSilhouetteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.45)
      // Magnetic strip line
      ..lineTo(w * 0.92, h * 0.45)
      ..quadraticBezierTo(w * 0.50, h * 0.72, w * 0.08, h * 0.45)
      ..lineTo(0, h * 0.45)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─── Vacation: plane silhouette — fuselage + wing ───────────────
class PlaneSilhouetteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      // Nose cone (right)
      ..lineTo(w, h * 0.35)
      ..lineTo(w * 0.88, h * 0.40)
      // Fuselage
      ..lineTo(w * 0.75, h * 0.42)
      // Right wing down
      ..lineTo(w * 0.65, h * 0.75)
      ..lineTo(w * 0.58, h * 0.75)
      // Wing back to fuselage
      ..lineTo(w * 0.52, h * 0.45)
      // Fuselage continues
      ..lineTo(w * 0.40, h * 0.45)
      // Left wing down
      ..lineTo(w * 0.35, h * 0.70)
      ..lineTo(w * 0.28, h * 0.70)
      // Wing back to fuselage
      ..lineTo(w * 0.25, h * 0.42)
      // Tail
      ..lineTo(w * 0.12, h * 0.38)
      // Tail fin up
      ..lineTo(w * 0.08, h * 0.18)
      ..lineTo(w * 0.04, h * 0.22)
      // Down to tail base
      ..lineTo(w * 0.04, h * 0.40)
      ..lineTo(0, h * 0.42)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─── Tech: phone/laptop screen frame ────────────────────────────
class TechSilhouetteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.03; // corner radius for the screen

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.50)
      // Right side of phone
      ..lineTo(w * 0.78, h * 0.50)
      // Bottom right corner of screen
      ..quadraticBezierTo(w * 0.78, h * 0.42, w * 0.78 - r, h * 0.42)
      // Bottom edge of screen
      ..lineTo(w * 0.22 + r, h * 0.42)
      // Bottom left corner of screen
      ..quadraticBezierTo(w * 0.22, h * 0.42, w * 0.22, h * 0.50)
      // Left side of phone
      ..lineTo(0, h * 0.50)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─── Custom / Default: gentle wave ──────────────────────────────
class DefaultSilhouetteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.50)
      ..quadraticBezierTo(w * 0.75, h * 0.65, w * 0.50, h * 0.50)
      ..quadraticBezierTo(w * 0.25, h * 0.35, 0, h * 0.50)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Returns the appropriate clipper for a SimulationType/Template name.
CustomClipper<Path> getSimulationClipper(String typeName) {
  return switch (typeName) {
    'car' => CarSilhouetteClipper(),
    'housing' => HouseSilhouetteClipper(),
    'credit' => CreditSilhouetteClipper(),
    'vacation' => PlaneSilhouetteClipper(),
    'tech' => TechSilhouetteClipper(),
    'rentChange' => HouseSilhouetteClipper(),
    'salaryChange' => CreditSilhouetteClipper(),
    'investment' => TechSilhouetteClipper(),
    _ => DefaultSilhouetteClipper(),
  };
}

/// Category-specific gradient colors for the hat section.
List<Color> getHatGradientColors(String typeName) {
  return switch (typeName) {
    'car' => [const Color(0xFF1E3A5F), const Color(0xFF3B82F6)],
    'housing' => [const Color(0xFF064E3B), const Color(0xFF10B981)],
    'credit' => [const Color(0xFF4C1D95), const Color(0xFF8B5CF6)],
    'vacation' => [const Color(0xFFEA580C), const Color(0xFFFBBF24)],
    'tech' => [const Color(0xFF374151), const Color(0xFF6B7280)],
    _ => [const Color(0xFF0D9488), const Color(0xFF5EEAD4)],
  };
}
