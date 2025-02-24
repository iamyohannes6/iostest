import 'package:flutter/material.dart';
import '../models/portfolio_history.dart';
import 'dart:math' as math;

class PriceChart extends StatefulWidget {
  final List<PortfolioSnapshot> snapshots;
  final double height;
  final Color lineColor;
  final Color fillColor;
  final Function(PortfolioSnapshot)? onPointSelected;

  const PriceChart({
    super.key,
    required this.snapshots,
    required this.height,
    required this.lineColor,
    required this.fillColor,
    this.onPointSelected,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  Offset? touchPoint;
  PortfolioSnapshot? selectedSnapshot;

  void _updateTouchPoint(Offset? localPosition, Size size) {
    if (localPosition == null || widget.snapshots.isEmpty) {
      setState(() {
        touchPoint = null;
        selectedSnapshot = null;
      });
      widget.onPointSelected?.call(widget.snapshots.last);
      return;
    }

    // Get the path points
    final painter = _ChartPainter(
      snapshots: widget.snapshots,
      lineColor: widget.lineColor,
      touchPoint: null,
    );

    final pathPoints = painter.getPathPoints(size);

    // Find the closest point on the actual path
    Offset? closestPoint;
    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < pathPoints.length; i++) {
      final point = pathPoints[i];
      final distance = (point - localPosition).distance;

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
        // Map the path point index back to snapshot index
        closestIndex = ((i / pathPoints.length) * (widget.snapshots.length - 1)).round();
      }
    }

    if (closestPoint != null) {
      setState(() {
        touchPoint = closestPoint;
        selectedSnapshot = widget.snapshots[closestIndex];
      });

      widget.onPointSelected?.call(selectedSnapshot ?? widget.snapshots.last);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snapshots.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _updateTouchPoint(details.localPosition, Size(constraints.maxWidth, widget.height)),
          onHorizontalDragStart: (details) => _updateTouchPoint(details.localPosition, Size(constraints.maxWidth, widget.height)),
          onHorizontalDragUpdate: (details) => _updateTouchPoint(details.localPosition, Size(constraints.maxWidth, widget.height)),
          onHorizontalDragEnd: (_) => _updateTouchPoint(null, Size(constraints.maxWidth, widget.height)),
          child: SizedBox(
            height: widget.height,
            child: CustomPaint(
              size: Size(constraints.maxWidth, widget.height),
              painter: _ChartPainter(
                snapshots: widget.snapshots,
                lineColor: widget.lineColor,
                touchPoint: touchPoint,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<PortfolioSnapshot> snapshots;
  final Color lineColor;
  final Offset? touchPoint;
  List<Offset>? _cachedPathPoints;

  _ChartPainter({
    required this.snapshots,
    required this.lineColor,
    this.touchPoint,
  });

  List<Offset> getPathPoints(Size size) {
    if (_cachedPathPoints != null) return _cachedPathPoints!;

    if (snapshots.isEmpty) return [];

    final normalizedData = _normalizeData(snapshots);
    final points = <Offset>[];

    // Create base points
    for (int i = 0; i < normalizedData.length; i++) {
      final double x = i / (normalizedData.length - 1) * size.width;
      final double y = size.height - (normalizedData[i] * size.height);
      points.add(Offset(x, y));
    }

    // Double smoothing pass
    _cachedPathPoints = _smoothPoints(_smoothPoints(points));
    return _cachedPathPoints!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (snapshots.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final smoothedPoints = getPathPoints(size);
    final interpolatedPoints = <Offset>[];

    // Interpolate additional points between each pair of smoothed base points
    for (int i = 0; i < smoothedPoints.length - 1; i++) {
      final current = smoothedPoints[i];
      final next = smoothedPoints[i + 1];

      interpolatedPoints.add(current);

      final steps = 15;
      for (int step = 1; step < steps; step++) {
        final t = step / steps;
        final x = _bezierInterpolate(current.dx, next.dx, t);
        final y = _bezierInterpolate(current.dy, next.dy, t);
        interpolatedPoints.add(Offset(x, y));
      }
    }
    interpolatedPoints.add(smoothedPoints.last);

    // Apply final smoothing to interpolated points
    final finalPoints = _smoothPoints(interpolatedPoints);

    // Draw smooth curve
    final path = Path();
    if (finalPoints.length > 1) {
      path.moveTo(finalPoints[0].dx, finalPoints[0].dy);

      for (int i = 1; i < finalPoints.length - 1; i++) {
        final p0 = i > 0 ? finalPoints[i - 1] : finalPoints[i];
        final p1 = finalPoints[i];
        final p2 = finalPoints[i + 1];
        final p3 = i < finalPoints.length - 2 ? finalPoints[i + 2] : p2;

        final tension = 0.25;
        final controlPoint1 = Offset(
          p1.dx + (p2.dx - p0.dx) * tension,
          p1.dy + (p2.dy - p0.dy) * tension,
        );
        final controlPoint2 = Offset(
          p2.dx - (p3.dx - p1.dx) * tension,
          p2.dy - (p3.dy - p1.dy) * tension,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p2.dx,
          p2.dy,
        );
      }
    }

    canvas.drawPath(path, paint);

    // Draw touch point indicator
    if (touchPoint != null) {
      final indicatorPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      // Draw outer circle
      canvas.drawCircle(touchPoint!, 5, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill);

      // Draw inner circle
      canvas.drawCircle(touchPoint!, 3, indicatorPaint);
    }
  }

  // Normalize data points between 0 and 1 with enhanced moving average smoothing
  List<double> _normalizeData(List<PortfolioSnapshot> data) {
    if (data.isEmpty) return [];

    // Extract values
    final values = data.map((s) => s.value).toList();

    // Apply enhanced moving average smoothing
    final windowSize = 5;
    final smoothedValues = List<double>.filled(values.length, 0);

    for (int i = 0; i < values.length; i++) {
      double weightedSum = 0;
      double weightSum = 0;

      for (int j = math.max(0, i - windowSize + 1); j <= math.min(values.length - 1, i + windowSize - 1); j++) {
        final weight = 1.0 / (1 + (i - j).abs());
        weightedSum += values[j] * weight;
        weightSum += weight;
      }

      smoothedValues[i] = weightedSum / weightSum;
    }

    // Find min and max of smoothed values
    double minValue = smoothedValues.reduce(math.min);
    double maxValue = smoothedValues.reduce(math.max);

    // Add padding to prevent edge cases
    final padding = (maxValue - minValue) * 0.15;
    minValue -= padding;
    maxValue += padding;

    // Normalize values between 0 and 1
    return smoothedValues.map((value) => (value - minValue) / (maxValue - minValue)).toList();
  }

  // Linear interpolation
  double _bezierInterpolate(double start, double end, double t) {
    return start + (end - start) * t;
  }

  // Additional smoothing pass on points
  List<Offset> _smoothPoints(List<Offset> points) {
    if (points.length <= 2) return points;

    final smoothed = List<Offset>.filled(points.length, Offset.zero);
    smoothed[0] = points[0];
    smoothed[points.length - 1] = points[points.length - 1];

    for (int i = 1; i < points.length - 1; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final next = points[i + 1];

      smoothed[i] = Offset(
        (prev.dx + 2 * curr.dx + next.dx) / 4,
        (prev.dy + 2 * curr.dy + next.dy) / 4,
      );
    }

    return smoothed;
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return snapshots != oldDelegate.snapshots ||
        lineColor != oldDelegate.lineColor ||
        touchPoint != oldDelegate.touchPoint;
  }
}