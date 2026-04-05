import 'package:flutter/material.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_flip_card.dart';

// ─── Stacked Cards Widget ─────────────────────────────────────
class SimStackedCards extends StatelessWidget {
  final List<SimulationEntry> sims;
  final AnimationController expandAnimation;
  final void Function(SimulationEntry sim) onToggleInclude;
  final void Function(String id) onDelete;
  final VoidCallback onExpandToggle;

  static const _peekH = 30.0; // visible hat peek per stacked card
  static const _cardSpacing = 16.0; // spacing when expanded
  static const _cardH = 210.0; // estimated card height for layout

  const SimStackedCards({
    super.key,
    required this.sims,
    required this.expandAnimation,
    required this.onToggleInclude,
    required this.onDelete,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: expandAnimation,
      builder: (context, _) {
        final t = expandAnimation.value; // 0 = stacked, 1 = expanded
        return GestureDetector(
          // Drag to expand/collapse
          onVerticalDragUpdate: (d) {
            final delta = d.primaryDelta ?? 0;
            expandAnimation.value =
                (expandAnimation.value + delta / 300).clamp(0.0, 1.0);
          },
          onVerticalDragEnd: (d) {
            final vel = d.primaryVelocity ?? 0;
            if (vel > 200) {
              // Swiped down → expand
              expandAnimation.forward();
            } else if (vel < -200) {
              // Swiped up → collapse
              expandAnimation.reverse();
            } else {
              // Snap to nearest
              if (expandAnimation.value > 0.5) {
                expandAnimation.forward();
              } else {
                expandAnimation.reverse();
              }
            }
          },
          child: _buildStack(context, t),
        );
      },
    );
  }

  Widget _buildStack(BuildContext context, double t) {
    final count = sims.length;
    if (count == 0) return const SizedBox.shrink();

    // ── Fully expanded (t ≈ 1): simple Column ──
    if (t > 0.95) {
      return Column(
        children: List.generate(count, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: _cardSpacing),
            child: SimFlipCard(
              sim: sims[i],
              onToggleInclude: () => onToggleInclude(sims[i]),
              onDelete: () => onDelete(sims[i].id),
            ),
          );
        }),
      );
    }

    // ── Collapsed (t ≈ 0) & mid-animation ──
    //
    // Layout (collapsed):
    //   top=0          : card[count-1] peek (clipped to _peekH)
    //   top=_peekH     : card[count-2] peek (clipped to _peekH)
    //   ...
    //   top=(count-2)*_peekH : card[1] peek (clipped to _peekH)
    //   top=(count-1)*_peekH : card[0] FULL (fully visible, on top)
    //
    // Drawing order: card[count-1] first (bottom z), card[0] last (top z).
    // During animation, peek cards grow to full height and spacing increases.

    final collapsedTotalH = _peekH * (count - 1) + _cardH;
    final expandedTotalH = count * (_cardH + _cardSpacing);
    final totalH = collapsedTotalH + (expandedTotalH - collapsedTotalH) * t;

    return SizedBox(
      height: totalH,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: List.generate(count, (drawIdx) {
          // Draw from back (last card) to front (card 0)
          final i = count - 1 - drawIdx;

          // Reversed index for positioning: card 0 is at the bottom
          // of the visual stack, card[count-1] is at the top
          final reversedI = count - 1 - i;

          // Collapsed position: peek cards stacked at top, card 0 at bottom
          final collapsedTop = reversedI * _peekH;
          // Expanded position: all cards evenly spaced
          final expandedTop = i * (_cardH + _cardSpacing);
          final top = collapsedTop + (expandedTop - collapsedTop) * t;

          // Card 0 is always fully visible. Other cards are clipped
          // to _peekH when collapsed and grow to full height when expanded.
          final isTopCard = i == 0;

          if (isTopCard) {
            // Card 0: always full, on top of z-order
            return Positioned(
              top: top,
              left: 0,
              right: 0,
              child: SimFlipCard(
                sim: sims[i],
                onToggleInclude: () => onToggleInclude(sims[i]),
                onDelete: () => onDelete(sims[i].id),
              ),
            );
          }

          // Peek cards: clipped height interpolates from _peekH to full
          final clipH = _peekH + (_cardH - _peekH) * t;

          return Positioned(
            top: top,
            left: 0,
            right: 0,
            height: clipH,
            child: IgnorePointer(
              ignoring: t < 0.5,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: _cardH,
                  minHeight: _cardH,
                  child: SimFlipCard(
                    sim: sims[i],
                    onToggleInclude: () => onToggleInclude(sims[i]),
                    onDelete: () => onDelete(sims[i].id),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

