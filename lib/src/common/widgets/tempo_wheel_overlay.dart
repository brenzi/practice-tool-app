import 'dart:math';

import 'package:flutter/material.dart';

class TempoWheelOverlay extends StatefulWidget {
  const TempoWheelOverlay({
    super.key,
    required this.initialBpm,
    required this.onBpmChanged,
    this.min = 40,
    this.max = 300,
  });

  final int initialBpm;
  final ValueChanged<int> onBpmChanged;
  final int min;
  final int max;

  @override
  State<TempoWheelOverlay> createState() => _TempoWheelOverlayState();
}

class _TempoWheelOverlayState extends State<TempoWheelOverlay> {
  late int _bpm;
  Offset? _lastPanPosition;

  @override
  void initState() {
    super.initState();
    _bpm = widget.initialBpm;
  }

  void _onPanUpdate(DragUpdateDetails details, Offset center) {
    final current = details.globalPosition;
    final prev = _lastPanPosition ?? current;
    _lastPanPosition = current;

    final prevAngle = atan2(prev.dy - center.dy, prev.dx - center.dx);
    final curAngle = atan2(current.dy - center.dy, current.dx - center.dx);
    var delta = curAngle - prevAngle;

    // Normalize to [-pi, pi]
    if (delta > pi) delta -= 2 * pi;
    if (delta < -pi) delta += 2 * pi;

    // Map angular delta to BPM change
    // Full circle = 360° → full range
    final bpmDelta = delta / (2 * pi) * (widget.max - widget.min);
    final newBpm = (_bpm + bpmDelta.round()).clamp(widget.min, widget.max);

    if (newBpm != _bpm) {
      setState(() => _bpm = newBpm);
      widget.onBpmChanged(newBpm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final wheelSize = min(screenSize.width, screenSize.height) * 0.85;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: GestureDetector(
          onTap: () {}, // absorb taps on wheel
          onPanStart: (_) => _lastPanPosition = null,
          onPanUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final center = box.localToGlobal(
              Offset(box.size.width / 2, box.size.height / 2),
            );
            _onPanUpdate(details, center);
          },
          child: SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: CustomPaint(
              painter: _WheelPainter(
                bpm: _bpm,
                min: widget.min,
                max: widget.max,
                color: Theme.of(context).colorScheme.primary,
                trackColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                textColor: Theme.of(context).colorScheme.onSurface,
              ),
              child: Center(
                child: Text(
                  '$_bpm',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.bpm,
    required this.min,
    required this.max,
    required this.color,
    required this.trackColor,
    required this.textColor,
  });

  final int bpm;
  final int min;
  final int max;
  final Color color;
  final Color trackColor;
  final Color textColor;

  static const _startAngle = 2 * pi * 0.4167; // 150° from top = bottom-left
  static const _sweepAngle = 2 * pi * 0.8333; // 300° arc

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 24;

    // Track arc
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepAngle,
      false,
      trackPaint,
    );

    // Value arc
    final fraction = (bpm - min) / (max - min);
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepAngle * fraction,
      false,
      valuePaint,
    );

    // Tick marks every 10 BPM
    final tickPaint = Paint()
      ..color = textColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (var t = min; t <= max; t += 10) {
      final f = (t - min) / (max - min);
      final angle = _startAngle + _sweepAngle * f;
      final innerR = radius - 12;
      final outerR = radius - 4;
      canvas.drawLine(
        Offset(
          center.dx + innerR * cos(angle),
          center.dy + innerR * sin(angle),
        ),
        Offset(
          center.dx + outerR * cos(angle),
          center.dy + outerR * sin(angle),
        ),
        tickPaint,
      );
    }

    // Thumb indicator
    final thumbAngle = _startAngle + _sweepAngle * fraction;
    final thumbPaint = Paint()..color = color;
    canvas.drawCircle(
      Offset(
        center.dx + radius * cos(thumbAngle),
        center.dy + radius * sin(thumbAngle),
      ),
      10,
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter old) => bpm != old.bpm || color != old.color;
}

Future<void> showTempoWheel(
  BuildContext context, {
  required int currentBpm,
  required ValueChanged<int> onBpmChanged,
  int min = 40,
  int max = 300,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => TempoWheelOverlay(
      initialBpm: currentBpm,
      onBpmChanged: onBpmChanged,
      min: min,
      max: max,
    ),
  );
}
