import 'dart:math' as math;
import '../../math_engine/math_parser.dart';

class GraphSamplePoint {
  final double x;
  final double y;
  final bool isDefined;
  final bool isAsymptote;

  GraphSamplePoint({
    required this.x,
    required this.y,
    this.isDefined = true,
    this.isAsymptote = false,
  });
}

class CoordinateSampler {
  /// Evaluates an expression for a given X, supporting piecewise ternary expressions.
  /// E.g. "X < 0 ? X^2 : sin(X)"
  static double evaluateExpression(String expr, double x) {
    final cleanExpr = expr.trim();
    if (cleanExpr.contains('?')) {
      final parts = cleanExpr.split('?');
      if (parts.length == 2) {
        final condStr = parts[0].trim();
        final branches = parts[1].split(':');
        if (branches.length == 2) {
          final trueBranch = branches[0].trim();
          final falseBranch = branches[1].trim();

          if (_evaluateCondition(condStr, x)) {
            return _evaluateStandard(trueBranch, x);
          } else {
            return _evaluateStandard(falseBranch, x);
          }
        }
      }
    }
    return _evaluateStandard(cleanExpr, x);
  }

  static bool _evaluateCondition(String cond, double x) {
    // Basic condition parsing for X e.g. "X < 0", "X >= 2.5"
    final cleanCond = cond.replaceAll(' ', '');
    final operators = ['>=', '<=', '>', '<', '=='];
    for (var op in operators) {
      if (cleanCond.contains(op)) {
        final sides = cleanCond.split(op);
        if (sides.length == 2 && sides[0] == 'X') {
          final val = double.tryParse(sides[1]) ?? 0.0;
          switch (op) {
            case '>=': return x >= val;
            case '<=': return x <= val;
            case '>': return x > val;
            case '<': return x < val;
            case '==': return (x - val).abs() < 1e-9;
          }
        }
      }
    }
    return true; // Default fallback
  }

  static double _evaluateStandard(String expr, double x) {
    MathParser.setVariable('X', x);
    return MathParser.evaluate(expr);
  }

  /// Generates the sample points using adaptive sampling and discontinuity detection.
  static List<GraphSamplePoint> sampleCartesian({
    required String expression,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
    required double screenWidth,
    required double screenHeight,
  }) {
    final List<GraphSamplePoint> points = [];
    const int baseIntervals = 100;
    final double step = (maxX - minX) / baseIntervals;

    // Viewport-relative vertical threshold to detect asymptotes
    final double vertLimit = (maxY - minY) * 3.0;

    // Helper to check if a point is defined
    GraphSamplePoint getPoint(double x) {
      try {
        double y = evaluateExpression(expression, x);
        if (y.isNaN || y.isInfinite) {
          return GraphSamplePoint(x: x, y: 0.0, isDefined: false);
        }
        return GraphSamplePoint(x: x, y: y, isDefined: true);
      } catch (_) {
        return GraphSamplePoint(x: x, y: 0.0, isDefined: false);
      }
    }

    // Recursive adaptive refinement function
    void refine(GraphSamplePoint p1, GraphSamplePoint p2, int depth) {
      if (depth >= 5) {
        points.add(p2);
        return;
      }

      double xm = (p1.x + p2.x) / 2.0;
      GraphSamplePoint pm = getPoint(xm);

      if (!p1.isDefined || !p2.isDefined) {
        // Find boundary of domain using bisection
        if (p1.isDefined != p2.isDefined) {
          GraphSamplePoint b1 = p1;
          GraphSamplePoint b2 = p2;
          for (int i = 0; i < 8; i++) {
            double xb = (b1.x + b2.x) / 2.0;
            GraphSamplePoint pb = getPoint(xb);
            if (pb.isDefined == b1.isDefined) {
              b1 = pb;
            } else {
              b2 = pb;
            }
          }
          points.add(b1.isDefined ? b1 : b2);
        }
        points.add(pm);
        points.add(p2);
        return;
      }

      if (pm.isDefined) {
        // Discontinuity / Asymptote check
        // Check if there is a massive slope change and sign change
        bool isAsymptote = false;
        if ((p1.y * p2.y < 0 || p1.y * pm.y < 0 || pm.y * p2.y < 0) &&
            ((p1.y - p2.y).abs() > vertLimit)) {
          isAsymptote = true;
        }

        if (isAsymptote) {
          // Mark as asymptote and do not refine further to split paths
          points.add(GraphSamplePoint(x: xm, y: 0.0, isDefined: false, isAsymptote: true));
          points.add(p2);
          return;
        }

        // Distance from midpoint to straight line connecting p1 and p2 in pixel coordinates
        double px1 = ((p1.x - minX) / (maxX - minX)) * screenWidth;
        double py1 = screenHeight - (((p1.y - minY) / (maxY - minY)) * screenHeight);
        double px2 = ((p2.x - minX) / (maxX - minX)) * screenWidth;
        double py2 = screenHeight - (((p2.y - minY) / (maxY - minY)) * screenHeight);
        double pxm = ((pm.x - minX) / (maxX - minX)) * screenWidth;
        double pym = screenHeight - (((pm.y - minY) / (maxY - minY)) * screenHeight);

        // Distance formula from point (pxm, pym) to line (px1, py1) -> (px2, py2)
        double num = ((py2 - py1) * pxm - (px2 - px1) * pym + px2 * py1 - py2 * px1).abs();
        double den = math.sqrt((px2 - px1) * (px2 - px1) + (py2 - py1) * (py2 - py1));
        double dist = den > 0.0 ? num / den : 0.0;

        if (dist > 0.5) {
          refine(p1, pm, depth + 1);
          refine(pm, p2, depth + 1);
          return;
        }
      }

      points.add(pm);
      points.add(p2);
    }

    // Initial uniform sampling
    GraphSamplePoint prev = getPoint(minX);
    points.add(prev);

    for (int i = 1; i <= baseIntervals; i++) {
      double x = minX + i * step;
      GraphSamplePoint curr = getPoint(x);
      refine(prev, curr, 0);
      prev = curr;
    }

    return points;
  }

  /// Finds roots (X-intercepts) in the visible viewport range
  static List<double> findRoots({
    required String expression,
    required double minX,
    required double maxX,
  }) {
    final List<double> roots = [];
    const int searchSteps = 50;
    final double step = (maxX - minX) / searchSteps;

    double f(double x) {
      try {
        double y = evaluateExpression(expression, x);
        return y.isNaN || y.isInfinite ? 0.0 : y;
      } catch (_) {
        return 0.0;
      }
    }

    for (int i = 0; i < searchSteps; i++) {
      double x1 = minX + i * step;
      double x2 = x1 + step;
      double y1 = f(x1);
      double y2 = f(x2);

      if (y1 * y2 < 0) {
        // Sign change detected: use bisection solver to find root
        double a = x1;
        double b = x2;
        for (int k = 0; k < 15; k++) {
          double m = (a + b) / 2.0;
          double ym = f(m);
          if (ym.abs() < 1e-7) {
            a = m;
            break;
          }
          if (f(a) * ym < 0) {
            b = m;
          } else {
            a = m;
          }
        }
        if (a >= minX && a <= maxX) {
          roots.add(a);
        }
      } else if (y1.abs() < 1e-7) {
        roots.add(x1);
      }
    }

    // De-duplicate roots within a tolerance of 1e-4
    final List<double> uniqueRoots = [];
    for (var r in roots) {
      if (!uniqueRoots.any((ur) => (ur - r).abs() < 1e-4)) {
        uniqueRoots.add(r);
      }
    }
    uniqueRoots.sort();
    return uniqueRoots;
  }
}
