import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/graph_engine/parsers/coordinate_sampler.dart';

void main() {
  test('Piecewise ternary condition evaluation', () {
    // X < 0 ? X^2 : sin(X)
    expect(CoordinateSampler.evaluateExpression("X < 0 ? X^2 : sin(X)", -2.0), 4.0);
    expect(CoordinateSampler.evaluateExpression("X < 0 ? X^2 : sin(X)", 0.0), 0.0);
  });

  test('Root finding on Cartesian function', () {
    // X^2 - 4 has roots at -2 and 2
    final roots = CoordinateSampler.findRoots(
      expression: "X^2 - 4",
      minX: -5.0,
      maxX: 5.0,
    );
    expect(roots.length, greaterThanOrEqualTo(2));
    expect(roots[0], closeTo(-2.0, 1e-3));
    expect(roots[1], closeTo(2.0, 1e-3));
  });

  test('Cartesian sampling with asymptotes and adaptive curvature', () {
    // 1/X has a vertical asymptote at X=0
    final points = CoordinateSampler.sampleCartesian(
      expression: "1 / X",
      minX: -5.0,
      maxX: 5.0,
      minY: -5.0,
      maxY: 5.0,
      screenWidth: 400.0,
      screenHeight: 400.0,
    );

    expect(points.isNotEmpty, true);
    // There should be undefined points or marked asymptotes near x=0
    final hasAsymptoteOrUndefined = points.any((p) => !p.isDefined || p.isAsymptote);
    expect(hasAsymptoteOrUndefined, true);
  });
}
