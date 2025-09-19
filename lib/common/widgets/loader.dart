import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class GridLoader extends StatefulWidget {
  const GridLoader({
    super.key,
    this.size = 48.0,
    this.color,
    this.duration = const Duration(milliseconds: 2000),
  });

  final double size;
  final Color? color;
  final Duration duration;

  @override
  State<GridLoader> createState() => _GridLoaderState();
}

class _GridLoaderState extends State<GridLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _GridPainter(animation: _ctrl.value, color: color),
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.animation, required this.color});

  final double animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const gridSize = 3;
    final cellSize = size.width / gridSize;
    final paint = Paint()..color = color;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final delay = (i + j) * 0.1;
        final progress = ((animation + delay) % 1.0);
        final scale = math.sin(progress * math.pi).abs();

        final rect = Rect.fromLTWH(
          i * cellSize + cellSize * 0.2,
          j * cellSize + cellSize * 0.2,
          cellSize * 0.6 * scale,
          cellSize * 0.6 * scale,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.1)),
          paint..color = color.withOpacity(scale),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
