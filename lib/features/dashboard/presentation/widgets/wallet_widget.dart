import 'dart:math' as math;
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/wallet_color_provider.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class WalletWidget extends ConsumerStatefulWidget {
  final double cumulativeNet;
  final MonthSummary? currentMonth;
  final ValueChanged<bool>? onOpenChanged;

  const WalletWidget({
    super.key,
    required this.cumulativeNet,
    this.currentMonth,
    this.onOpenChanged,
  });

  @override
  ConsumerState<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends ConsumerState<WalletWidget>
    with TickerProviderStateMixin {
  late final AnimationController _flapController;
  late final AnimationController _cardsController;
  late final AnimationController _pulseController;
  late final AnimationController _hintController;
  late final AnimationController _peekController;

  late final Animation<double> _flapAnim;
  late final Animation<double> _cardsSlide;
  late final Animation<double> _balanceOpacity;
  late final Animation<double> _hintAnim;
  late final Animation<double> _peekAnim;

  bool _isOpen = false;
  bool _isExpanded = false;
  bool _hasOpened = false; // Track if user ever opened the wallet
  bool _showHint = true;
  double _flapDragOffset = 0;
  double _cardsDragOffset = 0;

  static const double _flapHeight = 90.0;
  static const double _bodyMinHeight = 60.0;

  @override
  void initState() {
    super.initState();

    _flapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _flapAnim = CurvedAnimation(
      parent: _flapController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _balanceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flapController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardsSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: AppCurve.overshoot),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Hint arrow bounce animation (repeating)
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _hintAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeInOut),
    );

    // Peek demo animation — runs once after 1.5s delay
    _peekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _peekAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
    ]).animate(_peekController);

    // Start peek demo after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_hasOpened) {
        _peekController.forward();
      }
    });
  }

  @override
  void dispose() {
    _flapController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
    _hintController.dispose();
    _peekController.dispose();
    super.dispose();
  }

  void _openWallet() {
    if (_isOpen) return;
    HapticFeedback.mediumImpact();
    _hasOpened = true;
    _showHint = false;
    _hintController.stop();
    _peekController.stop();
    setState(() => _isOpen = true);
    _flapController.forward();
    _pulseController.stop();
    widget.onOpenChanged?.call(true);
  }

  void _closeWallet() {
    if (!_isOpen) return;
    HapticFeedback.mediumImpact();
    if (_isExpanded) {
      _cardsController.reverse().then((_) {
        setState(() => _isExpanded = false);
        _flapController.reverse().then((_) {
          setState(() => _isOpen = false);
          _pulseController.repeat(reverse: true);
          widget.onOpenChanged?.call(false);
        });
      });
    } else {
      _flapController.reverse().then((_) {
        setState(() => _isOpen = false);
        _pulseController.repeat(reverse: true);
        widget.onOpenChanged?.call(false);
      });
    }
  }

  void _expandCards() {
    if (!_isOpen || _isExpanded) return;
    HapticFeedback.lightImpact();
    setState(() => _isExpanded = true);
    _cardsController.forward();
  }

  void _collapseCards() {
    if (!_isExpanded) return;
    HapticFeedback.lightImpact();
    _cardsController.reverse().then((_) {
      setState(() => _isExpanded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletColor = ref.watch(walletColorProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _flapController,
        _cardsController,
        _pulseController,
        _hintController,
        _peekController,
      ]),
      builder: (context, _) => _buildContent(walletColor),
    );
  }

  Widget _buildContent(WalletColor walletColor) {
    final t = _flapAnim.value; // 0 = closed, 1 = open

    // When open, wrap everything in a master gesture detector for closing
    Widget walletStack = AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(top: _isOpen ? 44 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_isOpen) _buildRoof(walletColor),
          _buildBody(walletColor, t),
          if (!_isOpen) _buildFlap(walletColor, t),
        ],
      ),
    );

    // Master close gesture when wallet is open
    if (_isOpen) {
      walletStack = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (d) =>
            setState(() => _flapDragOffset += d.delta.dy),
        onVerticalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (_flapDragOffset > 30 || v > 150) {
            if (_isExpanded) {
              _collapseCards();
            } else {
              _closeWallet();
            }
          } else if (_flapDragOffset < -30 || v < -150) {
            if (!_isExpanded) _expandCards();
          }
          setState(() => _flapDragOffset = 0);
        },
        child: walletStack,
      );
    }

    return Column(
      children: [
        walletStack,
        _buildExpandedCards(walletColor),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // WALLET BODY — always visible, content revealed when flap opens
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBody(WalletColor walletColor, double t) {
    return GestureDetector(
      onVerticalDragUpdate: (d) =>
          setState(() => _flapDragOffset += d.delta.dy),
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (!_isOpen && (_flapDragOffset < -25 || v < -150)) {
          _openWallet();
        } else if (_isOpen && !_isExpanded && (_flapDragOffset > 25 || v > 150)) {
          _closeWallet();
        }
        setState(() => _flapDragOffset = 0);
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: _bodyMinHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: walletColor.shadow.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: CustomPaint(
            painter: _LeatherPainter(
              baseColor: walletColor.base,
              highlightColor: walletColor.highlight,
            ),
            child: Column(
              children: [
                // Top spacing (under the flap)
                SizedBox(height: _flapHeight - 10 + (t * 10)),

                // Balance content (fades in when open)
                AnimatedSize(
                  duration: AppDuration.normal,
                  curve: AppCurve.standard,
                  child: _isOpen
                      ? Opacity(
                          opacity: _balanceOpacity.value,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xl, 0, AppSpacing.xl, 0,
                            ),
                            child: _buildBalanceContent(),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),

                // SAVVY branding (when closed)
                if (!_isOpen)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.lg,
                      top: AppSpacing.sm,
                    ),
                    child: Text(
                      'SAVVY',
                      style: AppTypography.headlineLarge.copyWith(
                        color: walletColor.highlight.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 8,
                        fontSize: 18,
                      ),
                    ),
                  ),

                // Ghost card previews (when open)
                if (_isOpen) _buildGhostCardArea(walletColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ─── ROOF — folded-back flap behind wallet (open state) ─────
  Widget _buildRoof(WalletColor walletColor) {
    return Positioned(
      top: -46,
      left: 0,
      right: 0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _closeWallet,
        onVerticalDragUpdate: (d) =>
            setState(() => _flapDragOffset += d.delta.dy),
        onVerticalDragEnd: (d) {
          if (_flapDragOffset > 25 || (d.primaryVelocity ?? 0) > 150) {
            _closeWallet();
          }
          setState(() => _flapDragOffset = 0);
        },
        child: ClipPath(
          clipper: _RoofClipper(),
          child: SizedBox(
            height: 56,
            child: CustomPaint(
              painter: _LeatherPainter(
                baseColor:
                    Color.lerp(walletColor.base, walletColor.shadow, 0.15)!,
                highlightColor: walletColor.highlight,
                isFlap: true,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: _closeWallet,
                    child: _buildClasp(walletColor, 0.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FLAP — envelope shape with V-bottom and clasp lock
  // ─────────────────────────────────────────────────────────────────
  Widget _buildFlap(WalletColor walletColor, double t) {
    // When open, flap moves up and folds behind (translate upward)
    final peekOffset = !_hasOpened ? _peekAnim.value * -18 : 0.0;
    final flapY = -t * (_flapHeight + 10) + peekOffset;

    return Positioned(
      top: flapY,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _isOpen ? _closeWallet : _openWallet,
        onVerticalDragUpdate: (d) =>
            setState(() => _flapDragOffset += d.delta.dy),
        onVerticalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (!_isOpen && (_flapDragOffset < -25 || v < -150)) {
            _openWallet();
          } else if (_isOpen && (_flapDragOffset > 25 || v > 150)) {
            _closeWallet();
          }
          setState(() => _flapDragOffset = 0);
        },
        child: ClipPath(
          clipper: _WalletFlapClipper(),
          child: Container(
            height: _flapHeight,
            decoration: BoxDecoration(
              boxShadow: t < 0.5
                  ? [
                      BoxShadow(
                        color: walletColor.shadow.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: CustomPaint(
              painter: _LeatherPainter(
                baseColor: t > 0.5
                    ? Color.lerp(
                        walletColor.base, walletColor.shadow, 0.15)!
                    : walletColor.base,
                highlightColor: walletColor.highlight,
                isFlap: true,
              ),
              child: Stack(
                children: [
                  // Clasp / lock at center-bottom of flap
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildClasp(walletColor, t),
                    ),
                  ),
                  // Hint arrow + text (only before first open)
                  if (_showHint && !_isOpen)
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: Transform.translate(
                        offset: Offset(0, _hintAnim.value),
                        child: Column(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 18,
                              color: walletColor.highlight
                                  .withValues(alpha: 0.5),
                            ),
                            Text(
                              'aç',
                              style: TextStyle(
                                fontSize: 9,
                                color: walletColor.highlight
                                    .withValues(alpha: 0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Stitching line near bottom
                  Positioned(
                    bottom: 28,
                    left: 20,
                    right: 20,
                    child: Opacity(
                      opacity: 0.08,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: walletColor.highlight,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Clasp / Lock (rectangular, like the reference wallet) ─────
  Widget _buildClasp(WalletColor walletColor, double t) {
    final pulse = _pulseController.value;
    final isVisible = t < 0.6;

    if (!isVisible) return const SizedBox.shrink();

    return Opacity(
      opacity: (1 - t * 1.6).clamp(0.0, 1.0),
      child: Container(
        width: 16,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              walletColor.highlight.withValues(alpha: 0.5),
              walletColor.highlight.withValues(alpha: 0.25),
            ],
          ),
          border: Border.all(
            color: walletColor.highlight.withValues(alpha: 0.4),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: walletColor.highlight
                  .withValues(alpha: 0.06 + pulse * 0.06),
              blurRadius: 4 + pulse * 2,
              spreadRadius: pulse,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock hole
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: walletColor.shadow.withValues(alpha: 0.5),
                border: Border.all(
                  color: walletColor.highlight.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Ghost card previews ──────────────────────────────────────
  Widget _buildGhostCardArea(WalletColor walletColor) {
    if (widget.currentMonth == null) return const SizedBox.shrink();

    final c = AppColors.of(context);
    final ghostOpacity =
        _isExpanded ? (1 - _cardsSlide.value).clamp(0.0, 1.0) : 1.0;

    if (ghostOpacity <= 0) return const SizedBox(height: AppSpacing.md);

    return GestureDetector(
      onVerticalDragUpdate: (d) =>
          setState(() => _cardsDragOffset += d.delta.dy),
      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (_cardsDragOffset > 25 || v > 150) _expandCards();
        if (_cardsDragOffset < -25 || v < -150) {
          if (_isExpanded) _collapseCards();
        }
        setState(() => _cardsDragOffset = 0);
      },
      onTap: _isExpanded ? _collapseCards : _expandCards,
      child: Opacity(
        opacity: ghostOpacity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.md,
          ),
          child: Transform.translate(
            // Gentle bounce when open and not yet expanded
            offset: Offset(0, !_isExpanded ? _hintAnim.value * -0.5 : 0),
            child: Column(
              children: [
                // Pull handle + hint
                Column(
                  children: [
                    if (!_isExpanded)
                      Transform.translate(
                        offset: Offset(0, _hintAnim.value * 0.6),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    Container(
                      width: 32,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.pill,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  _buildGhostCard('Gelir', c.income, AppIcons.income),
                  const SizedBox(width: 6),
                  _buildGhostCard('Gider', c.expense, AppIcons.expense),
                  const SizedBox(width: 6),
                  _buildGhostCard('Birikim', c.savings, AppIcons.savings),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildGhostCard(String label, Color accent, IconData icon) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, size: 10, color: accent),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Expanded cards — YAN YANA ────────────────────────────────
  Widget _buildExpandedCards(WalletColor walletColor) {
    final summary = widget.currentMonth;
    if (summary == null) return const SizedBox.shrink();

    final slideValue = _cardsSlide.value;
    if (slideValue <= 0 && !_isExpanded) return const SizedBox.shrink();

    final c = AppColors.of(context);

    return GestureDetector(
      onVerticalDragUpdate: (d) =>
          setState(() => _cardsDragOffset += d.delta.dy),
      onVerticalDragEnd: (d) {
        if (_cardsDragOffset < -25 || (d.primaryVelocity ?? 0) < -150) {
          _collapseCards();
        }
        setState(() => _cardsDragOffset = 0);
      },
      child: Transform.translate(
        offset: Offset(0, -6 * slideValue),
        child: Opacity(
          opacity: slideValue.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - slideValue)),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: [
                  _buildGlassCard(
                    label: 'Gelir',
                    amount: summary.totalIncome,
                    accentColor: c.income,
                    icon: AppIcons.income,
                    walletColor: walletColor,
                    delay: 0,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildGlassCard(
                    label: 'Gider',
                    amount: summary.totalExpense,
                    accentColor: c.expense,
                    icon: AppIcons.expense,
                    walletColor: walletColor,
                    delay: 1,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildGlassCard(
                    label: 'Birikim',
                    amount: summary.totalSavings,
                    accentColor: c.savings,
                    icon: AppIcons.savings,
                    walletColor: walletColor,
                    delay: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required String label,
    required double amount,
    required Color accentColor,
    required IconData icon,
    required WalletColor walletColor,
    required int delay,
  }) {
    final slideValue = _cardsSlide.value;
    final staggered =
        ((slideValue - delay * 0.06).clamp(0.0, 1.0) / 0.82).clamp(0.0, 1.0);
    return Expanded(
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - staggered)),
        child: Opacity(
          opacity: staggered,
          child: ClipRRect(
            borderRadius: AppRadius.card,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: walletColor.base,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: walletColor.highlight.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 14, color: accentColor),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: amount),
                        duration: AppDuration.countUp,
                        curve: AppCurve.decelerate,
                        builder: (context, value, _) => Text(
                          CurrencyFormatter.formatNoDecimal(value),
                          style: AppTypography.numericMedium.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Balance Content ──────────────────────────────────────────
  Widget _buildBalanceContent() {
    final summary = widget.currentMonth;
    final monthNet = summary != null
        ? summary.totalIncome - summary.totalExpense
        : null;

    final income = summary?.totalIncome ?? 0;
    final expense = summary?.totalExpense ?? 0;
    final savings = summary?.totalSavings ?? 0;
    final grandTotal = income + expense + savings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.cumulativeNet >= 0
                    ? const Color(0xFF34D399)
                    : const Color(0xFFFCA5A5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.cumulativeNet >= 0
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFCA5A5))
                        .withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Toplam Bakiye',
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Balance + Donut chart row
        Row(
          children: [
            // Left: balance amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: widget.cumulativeNet),
                    duration: AppDuration.countUp,
                    curve: AppCurve.decelerate,
                    builder: (context, value, _) => Text(
                      CurrencyFormatter.formatNoDecimal(value),
                      style: AppTypography.numericHero.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (monthNet != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            monthNet >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 13,
                            color: monthNet >= 0
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFFFCA5A5),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Bu ay ${monthNet >= 0 ? '+' : ''}${CurrencyFormatter.formatNoDecimal(monthNet)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFFCBD5E1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Right: Donut chart
            if (grandTotal > 0)
              SizedBox(
                width: 90,
                height: 90,
                child: _WalletDonutChart(
                  income: income,
                  expense: expense,
                  savings: savings,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Wallet Flap Clipper ─────────────────────────────────────────
// Creates the envelope-style flap shape: flat top with rounded corners,
// V-shaped bottom edge pointing down center.
// Roof shape: V-peak pointing UP (folded-back flap behind wallet)
class _RoofClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Flat bottom, gentle wide V-peak pointing up at center
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.6);
    // Gentle curve to center peak
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.18,
      size.width / 2, 0,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.18,
      size.width, size.height * 0.6,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _WalletFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const r = 18.0;

    // Start top-left (with rounded corner)
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);

    // Right side going down
    path.lineTo(size.width, size.height * 0.55);

    // V-shaped bottom: gentle curve to center point
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.75,
      size.width / 2,
      size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.75,
      0,
      size.height * 0.55,
    );

    // Left side going up
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─── Leather Texture Painter ─────────────────────────────────────
class _LeatherPainter extends CustomPainter {
  final Color baseColor;
  final Color highlightColor;
  final bool isFlap;

  _LeatherPainter({
    required this.baseColor,
    required this.highlightColor,
    this.isFlap = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = baseColor;
    canvas.drawRect(Offset.zero & size, basePaint);

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: isFlap ? Alignment.bottomCenter : Alignment.topCenter,
        end: isFlap ? Alignment.topCenter : Alignment.bottomCenter,
        colors: [
          highlightColor.withValues(alpha: 0.15),
          Colors.transparent,
          baseColor.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gradientPaint);

    // Leather grain texture
    final grainPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.3 + random.nextDouble() * 0.8;
      canvas.drawCircle(Offset(x, y), radius, grainPaint);
    }

    // Top edge highlight
    final edgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          highlightColor.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.15],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, edgePaint);
  }

  @override
  bool shouldRepaint(covariant _LeatherPainter old) =>
      old.baseColor != baseColor || old.highlightColor != highlightColor;
}

// ─── Wallet Donut Chart ─────────────────────────────────────────
class _WalletDonutChart extends StatelessWidget {
  final double income;
  final double expense;
  final double savings;

  const _WalletDonutChart({
    required this.income,
    required this.expense,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense + savings;
    if (total <= 0) return const SizedBox.shrink();

    const incomeColor = Color(0xFF34D399);
    const expenseColor = Color(0xFFFCA5A5);
    const savingsColor = Color(0xFFFBBF24);

    final sections = <PieChartSectionData>[
      PieChartSectionData(
        value: income,
        color: incomeColor,
        radius: 10,
        showTitle: false,
      ),
      PieChartSectionData(
        value: expense,
        color: expenseColor,
        radius: 10,
        showTitle: false,
      ),
      if (savings > 0)
        PieChartSectionData(
          value: savings,
          color: savingsColor,
          radius: 10,
          showTitle: false,
        ),
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sections: sections,
            sectionsSpace: 2,
            centerSpaceRadius: 28,
            startDegreeOffset: -90,
            borderData: FlBorderData(show: false),
          ),
        ),
        // Center legend
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LegendDot(color: incomeColor, label: 'G'),
            const SizedBox(height: 2),
            _LegendDot(color: expenseColor, label: 'Gd'),
            if (savings > 0) ...[
              const SizedBox(height: 2),
              _LegendDot(color: savingsColor, label: 'B'),
            ],
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
