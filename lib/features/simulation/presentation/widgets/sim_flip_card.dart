import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_card_front.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_card_back.dart';

// ─── Flip Simulation Card ─────────────────────────────────────
class SimFlipCard extends StatefulWidget {
  final SimulationEntry sim;
  final VoidCallback onToggleInclude;
  final VoidCallback onDelete;

  const SimFlipCard({
    super.key,
    required this.sim,
    required this.onToggleInclude,
    required this.onDelete,
  });

  @override
  State<SimFlipCard> createState() => _SimFlipCardState();
}

class _SimFlipCardState extends State<SimFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    if (_showBack) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    _showBack = !_showBack;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (context, _) {
        final angle = _flipAnim.value * math.pi;
        final isFront = angle < math.pi / 2;

        return GestureDetector(
          onTap: () => context.go('/simulate/${widget.sim.id}'),
          onLongPress: _flip,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? SimCardFront(
                    sim: widget.sim,
                    onToggleInclude: widget.onToggleInclude,
                    onDelete: widget.onDelete,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: SimCardBack(sim: widget.sim),
                  ),
          ),
        );
      },
    );
  }
}
