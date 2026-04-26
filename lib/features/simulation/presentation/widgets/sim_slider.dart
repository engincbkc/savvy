import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

/// Supplementary slider widget for quick numeric exploration.
/// Tap on the value badge to edit manually.
class SimSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;

  /// Format the current value for display (e.g. (v) => '%${v.toInt()}')
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  final Color color;

  /// Whether this slider is for percentage values (affects input parsing)
  final bool isPercent;

  /// Whether this slider is for integer values (like months)
  final bool isInteger;

  const SimSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.format,
    required this.onChanged,
    required this.color,
    this.isPercent = false,
    this.isInteger = false,
  });

  @override
  State<SimSlider> createState() => _SimSliderState();
}

class _SimSliderState extends State<SimSlider> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  int get _divisions =>
      widget.step > 0 ? ((widget.max - widget.min) / widget.step).round() : 100;

  double get _clampedValue => widget.value.clamp(widget.min, widget.max);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _submitValue();
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      if (widget.isInteger) {
        _controller.text = _clampedValue.toInt().toString();
      } else {
        _controller.text = _clampedValue.toStringAsFixed(2);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _submitValue() {
    final text = _controller.text.replaceAll(',', '.').replaceAll('%', '').trim();
    final parsed = double.tryParse(text);

    if (parsed != null) {
      double newValue = parsed.clamp(widget.min, widget.max);
      if (widget.isInteger) {
        newValue = newValue.roundToDouble();
      }
      widget.onChanged(newValue);
    }

    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTypography.labelSmall.copyWith(
                color: c.textSecondary,
              ),
            ),
            _isEditing ? _buildEditInput() : _buildValueBadge(),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.color,
            inactiveTrackColor: widget.color.withValues(alpha: 0.15),
            thumbColor: widget.color,
            overlayColor: widget.color.withValues(alpha: 0.12),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: _clampedValue,
            min: widget.min,
            max: widget.max,
            divisions: _divisions,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              widget.onChanged(v);
            },
          ),
        ),
        // Min / max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.format(widget.min),
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary,
                  fontSize: 10,
                ),
              ),
              Text(
                widget.format(widget.max),
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueBadge() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _startEditing();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          border: Border.all(color: widget.color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.format(_clampedValue),
              style: AppTypography.labelSmall.copyWith(
                color: widget.color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 10, color: widget.color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditInput() {
    return SizedBox(
      width: 70,
      height: 28,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTypography.labelSmall.copyWith(
          color: widget.color,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          filled: true,
          fillColor: widget.color.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: AppRadius.chip,
            borderSide: BorderSide(color: widget.color, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.chip,
            borderSide: BorderSide(color: widget.color, width: 1.5),
          ),
          suffixText: widget.isPercent ? '%' : null,
          suffixStyle: AppTypography.caption.copyWith(
            color: widget.color.withValues(alpha: 0.7),
          ),
        ),
        // Hem nokta hem virgül kabul et (ikisi de ondalık ayracı)
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ],
        onSubmitted: (_) => _submitValue(),
      ),
    );
  }
}

