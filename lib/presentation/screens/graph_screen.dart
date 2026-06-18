import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/graph_engine/models/graph_viewport.dart';
import '../../core/graph_engine/models/graph_function.dart';
import '../../core/graph_engine/parsers/coordinate_sampler.dart';
import '../../core/theme/calc_theme.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late List<GraphFunction> _functions;
  late double _minX;
  late double _maxX;
  late double _minY;
  late double _maxY;
  
  bool _isTraceEnabled = false;
  double? _traceX; // in mathematical X coordinate

  final TextEditingController _exprController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minX = -10.0;
    _maxX = 10.0;
    _minY = -10.0;
    _maxY = 10.0;

    _functions = [
      GraphFunction(id: '1', expression: 'sin(X)', color: Colors.blue),
      GraphFunction(id: '2', expression: 'X^2 - 4', color: Colors.red),
    ];
  }

  @override
  void dispose() {
    _exprController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Standard sleek dark theme
    final theme = CalcTheme.getTheme(CalcThemeType.dark);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Graphing Engine'),
        backgroundColor: theme.displayBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(_isTraceEnabled ? Icons.insights : Icons.gesture),
            tooltip: _isTraceEnabled ? 'Disable Trace' : 'Enable Trace',
            onPressed: () {
              setState(() {
                _isTraceEnabled = !_isTraceEnabled;
                if (!_isTraceEnabled) _traceX = null;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Function',
            onPressed: () => _showAddFunctionDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Viewport',
            onPressed: () {
              setState(() {
                _minX = -10.0;
                _maxX = 10.0;
                _minY = -10.0;
                _maxY = 10.0;
                _traceX = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Functions List
          Container(
            color: theme.displayBackgroundColor.withOpacity(0.5),
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _functions.length,
              itemBuilder: (context, idx) {
                final f = _functions[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Chip(
                    avatar: CircleAvatar(
                      backgroundColor: f.color,
                      radius: 8,
                    ),
                    label: Text(
                      'y = ${f.expression}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _functions.removeAt(idx);
                        _traceX = null;
                      });
                    },
                    backgroundColor: Colors.grey[900],
                  ),
                );
              },
            ),
          ),
          // Main Graph Viewport
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final viewport = GraphViewport(
                  minX: _minX,
                  maxX: _maxX,
                  minY: _minY,
                  maxY: _maxY,
                  size: size,
                );

                // Compute points for all functions
                final Map<GraphFunction, List<GraphSamplePoint>> pointsMap = {};
                final Map<GraphFunction, List<double>> rootsMap = {};
                for (var f in _functions) {
                  if (f.isVisible) {
                    pointsMap[f] = CoordinateSampler.sampleCartesian(
                      expression: f.expression,
                      minX: _minX,
                      maxX: _maxX,
                      minY: _minY,
                      maxY: _maxY,
                      screenWidth: size.width,
                      screenHeight: size.height,
                    );
                    rootsMap[f] = CoordinateSampler.findRoots(
                      expression: f.expression,
                      minX: _minX,
                      maxX: _maxX,
                    );
                  }
                }

                return GestureDetector(
                  onPanUpdate: (details) {
                    if (_isTraceEnabled) {
                      // Move trace cursor
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final localOffset = box.globalToLocal(details.globalPosition);
                      setState(() {
                        _traceX = viewport.toMathX(localOffset.dx);
                      });
                    } else {
                      // Pan viewport
                      setState(() {
                        viewport.pan(details.delta.dx, details.delta.dy);
                        _minX = viewport.minX;
                        _maxX = viewport.maxX;
                        _minY = viewport.minY;
                        _maxY = viewport.maxY;
                      });
                    }
                  },
                  onTapDown: (details) {
                    if (_isTraceEnabled) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final localOffset = box.globalToLocal(details.globalPosition);
                      setState(() {
                        _traceX = viewport.toMathX(localOffset.dx);
                      });
                    }
                  },
                  onScaleUpdate: (details) {
                    if (details.scale != 1.0) {
                      setState(() {
                        double factor = 1.0 / details.scale;
                        viewport.zoom(factor, details.localFocalPoint);
                        _minX = viewport.minX;
                        _maxX = viewport.maxX;
                        _minY = viewport.minY;
                        _maxY = viewport.maxY;
                      });
                    }
                  },
                  child: CustomPaint(
                    size: size,
                    painter: GraphPainter(
                      viewport: viewport,
                      pointsMap: pointsMap,
                      rootsMap: rootsMap,
                      traceX: _traceX,
                      isTraceEnabled: _isTraceEnabled,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFunctionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Cartesian Function'),
          content: TextField(
            controller: _exprController,
            decoration: const InputDecoration(
              hintText: 'e.g. X^3 - 3*X',
              prefixText: 'y = ',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _exprController.text.trim();
                if (text.isNotEmpty) {
                  final randomColor = Colors.primaries[math.Random().nextInt(Colors.primaries.length)];
                  setState(() {
                    _functions.add(
                      GraphFunction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        expression: text,
                        color: randomColor,
                      ),
                    );
                    _exprController.clear();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Plot'),
            ),
          ],
        );
      },
    );
  }
}

class GraphPainter extends CustomPainter {
  final GraphViewport viewport;
  final Map<GraphFunction, List<GraphSamplePoint>> pointsMap;
  final Map<GraphFunction, List<double>> rootsMap;
  final double? traceX;
  final bool isTraceEnabled;

  GraphPainter({
    required this.viewport,
    required this.pointsMap,
    required this.rootsMap,
    this.traceX,
    required this.isTraceEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawCurves(canvas, size);
    _drawOverlays(canvas, size);
    if (isTraceEnabled && traceX != null) {
      _drawTraceCursor(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[850]!
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Calculate dynamic grid spacing based on domain range
    double rangeX = viewport.maxX - viewport.minX;
    double log = (math.log(rangeX / 5.0) / math.ln10).floorToDouble();
    double spacing = math.pow(10, log).toDouble();
    if (rangeX / spacing < 4) spacing /= 2;
    if (rangeX / spacing > 10) spacing *= 2;

    // Draw vertical grid lines
    double startX = (viewport.minX / spacing).floorToDouble() * spacing;
    for (double x = startX; x <= viewport.maxX; x += spacing) {
      double px = viewport.toPixelX(x);
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint);

      // Label
      if (x.abs() > 1e-9) {
        textPainter.text = TextSpan(
          text: x.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
          style: TextStyle(color: Colors.grey[500], fontSize: 10),
        );
        textPainter.layout();
        double py = viewport.toPixelY(0.0).clamp(10.0, size.height - 20.0);
        textPainter.paint(canvas, Offset(px + 4, py + 2));
      }
    }

    // Draw horizontal grid lines
    double startY = (viewport.minY / spacing).floorToDouble() * spacing;
    for (double y = startY; y <= viewport.maxY; y += spacing) {
      double py = viewport.toPixelY(y);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint);

      // Label
      if (y.abs() > 1e-9) {
        textPainter.text = TextSpan(
          text: y.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
          style: TextStyle(color: Colors.grey[500], fontSize: 10),
        );
        textPainter.layout();
        double px = viewport.toPixelX(0.0).clamp(10.0, size.width - 35.0);
        textPainter.paint(canvas, Offset(px + 4, py - 12));
      }
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 1.5;

    // Draw X axis (y = 0)
    double py0 = viewport.toPixelY(0);
    if (py0 >= 0 && py0 <= size.height) {
      canvas.drawLine(Offset(0, py0), Offset(size.width, py0), axisPaint);
    }

    // Draw Y axis (x = 0)
    double px0 = viewport.toPixelX(0);
    if (px0 >= 0 && px0 <= size.width) {
      canvas.drawLine(Offset(px0, 0), Offset(px0, size.height), axisPaint);
    }
  }

  void _drawCurves(Canvas canvas, Size size) {
    for (var entry in pointsMap.entries) {
      final f = entry.key;
      final points = entry.value;

      final paint = Paint()
        ..color = f.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      Path path = Path();
      bool isFirst = true;

      for (var p in points) {
        if (!p.isDefined) {
          isFirst = true;
          if (p.isAsymptote) {
            // Draw vertical asymptote line
            _drawVerticalAsymptote(canvas, p.x, size);
          }
          continue;
        }

        double px = viewport.toPixelX(p.x);
        double py = viewport.toPixelY(p.y);

        if (isFirst) {
          path.moveTo(px, py);
          isFirst = false;
        } else {
          path.lineTo(px, py);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawVerticalAsymptote(Canvas canvas, double x, Size size) {
    final paint = Paint()
      ..color = Colors.grey[600]!.withOpacity(0.5)
      ..strokeWidth = 1.0;
    
    double px = viewport.toPixelX(x);
    if (px >= 0 && px <= size.width) {
      const double dashHeight = 5.0;
      const double dashSpace = 5.0;
      double startY = 0.0;
      while (startY < size.height) {
        canvas.drawLine(Offset(px, startY), Offset(px, startY + dashHeight), paint);
        startY += dashHeight + dashSpace;
      }
    }
  }

  void _drawOverlays(Canvas canvas, Size size) {
    final rootPaint = Paint()..color = Colors.red;
    final yInterceptPaint = Paint()..color = Colors.green;

    // 1. Draw Y-Intercepts
    if (viewport.minX <= 0.0 && viewport.maxX >= 0.0) {
      double px0 = viewport.toPixelX(0.0);
      for (var f in pointsMap.keys) {
        try {
          double y0 = CoordinateSampler.evaluateExpression(f.expression, 0.0);
          if (y0.isFinite && !y0.isNaN) {
            double py0 = viewport.toPixelY(y0);
            if (py0 >= 0 && py0 <= size.height) {
              canvas.drawCircle(Offset(px0, py0), 5.0, yInterceptPaint);
            }
          }
        } catch (_) {}
      }
    }

    // 2. Draw Roots
    for (var entry in rootsMap.entries) {
      final roots = entry.value;
      for (var r in roots) {
        double px = viewport.toPixelX(r);
        double py = viewport.toPixelY(0.0);
        if (px >= 0 && px <= size.width && py >= 0 && py <= size.height) {
          canvas.drawCircle(Offset(px, py), 5.0, rootPaint);
        }
      }
    }
  }

  void _drawTraceCursor(Canvas canvas, Size size) {
    final cursorPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.0;
    
    double tx = traceX!;
    double px = viewport.toPixelX(tx);

    // Draw vertical trace cursor line
    if (px >= 0 && px <= size.width) {
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), cursorPaint);
    }

    // Highlight values for all curves
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    int tooltipOffsetIndex = 0;
    for (var f in pointsMap.keys) {
      try {
        double ty = CoordinateSampler.evaluateExpression(f.expression, tx);
        if (ty.isNaN || ty.isInfinite) continue;

        double py = viewport.toPixelY(ty);
        if (px >= 0 && px <= size.width && py >= 0 && py <= size.height) {
          // Circle on the curve
          canvas.drawCircle(Offset(px, py), 6.0, highlightPaint..color = f.color);
          canvas.drawCircle(Offset(px, py), 4.0, highlightPaint..color = Colors.white);

          // Render Glassmorphic Tooltip coordinate display in top corner
          final text = 'y = ${f.expression}: (${tx.toStringAsFixed(3)}, ${ty.toStringAsFixed(3)})';
          textPainter.text = TextSpan(
            text: text,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          );
          textPainter.layout();

          // Tooltip container
          final rect = Rect.fromLTWH(10, 10.0 + (tooltipOffsetIndex * 26.0), textPainter.width + 12, 22);
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
          canvas.drawRRect(rrect, Paint()..color = Colors.black87);
          canvas.drawRRect(rrect, Paint()..color = f.color..style = PaintingStyle.stroke..strokeWidth = 1);

          textPainter.paint(canvas, Offset(16, 14.0 + (tooltipOffsetIndex * 26.0)));
          tooltipOffsetIndex++;
        }
      } catch (_) {}
    }
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
        oldDelegate.pointsMap != pointsMap ||
        oldDelegate.rootsMap != rootsMap ||
        oldDelegate.traceX != traceX ||
        oldDelegate.isTraceEnabled != isTraceEnabled;
  }
}
