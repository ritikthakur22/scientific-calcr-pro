import 'package:scientific_calcr_pro/presentation/screens/matrix_screen.dart';
import 'package:scientific_calcr_pro/presentation/screens/vector_screen.dart';
import 'package:scientific_calcr_pro/presentation/screens/statistics_screen.dart';
import 'package:scientific_calcr_pro/presentation/screens/base_n_screen.dart';
import 'package:scientific_calcr_pro/core/math_engine/equation_solver.dart';
import 'package:scientific_calcr_pro/core/math_engine/math_parser.dart';
import 'dart:math';

void expect(dynamic actual, dynamic expected, {String? reason}) {
  if (actual is double && expected is double) {
    if ((actual - expected).abs() > 0.01) {
      throw Exception('Expected $expected but got $actual. Reason: $reason');
    }
  } else if (actual.toString() != expected.toString()) {
    throw Exception('Expected $expected but got $actual. Reason: $reason');
  }
}

void expectCloseTo(double actual, double expected, double tolerance) {
  if ((actual - expected).abs() > tolerance) {
    throw Exception('Expected $expected but got $actual (not within tolerance).');
  }
}

void main() {
  int passed = 0;
  int failed = 0;
  List<String> report = [];

  void runTest(String name, Function() testFn) {
    try {
      testFn();
      print('PASS: $name');
      passed++;
    } catch (e) {
      print('FAIL: $name - $e');
      report.add('FAIL: $name - $e');
      failed++;
    }
  }

  runTest('MATRIX: determinant 2x2', () {
    var m2 = [[1.0, 2.0], [3.0, 4.0]];
    expect(MatrixHelper.determinant(m2), -2.0);
  });

  runTest('MATRIX: inverse 3x3', () {
    var m3 = [
      [1.0, 2.0, 3.0],
      [0.0, 1.0, 4.0],
      [5.0, 6.0, 0.0]
    ];
    var inv = MatrixHelper.inverse(m3)!;
    expect(inv[0][0], -24.0);
    expect(inv[0][1], 18.0);
    expect(inv[0][2], 5.0);
  });

  runTest('MATRIX: transpose', () {
    var m2 = [[1.0, 2.0], [3.0, 4.0]];
    var mt = MatrixHelper.transpose(m2);
    expect(mt, [[1.0, 3.0], [2.0, 4.0]]);
  });

  runTest('MATRIX: multiplication', () {
    var m2 = [[1.0, 2.0], [3.0, 4.0]];
    var mul = MatrixHelper.mul(m2, [[2.0, 0.0], [1.0, 2.0]]);
    expect(mul, [[4.0, 4.0], [10.0, 8.0]]);
  });

  runTest('VECTOR: dot product', () {
    var v1 = [1.0, 2.0, 3.0];
    var v2 = [4.0, 5.0, 6.0];
    expect(VectorHelper.dot(v1, v2), 32.0);
  });

  runTest('VECTOR: cross product', () {
    var v1 = [1.0, 2.0, 3.0];
    var v2 = [4.0, 5.0, 6.0];
    var cross = VectorHelper.cross(v1, v2);
    expect(cross, [-3.0, 6.0, -3.0]);
  });

  runTest('VECTOR: magnitude', () {
    expect(VectorHelper.magnitude([3.0, 4.0, 0.0]), 5.0);
  });

  runTest('VECTOR: angle', () {
    expectCloseTo(VectorHelper.angle([1.0, 0.0, 0.0], [0.0, 1.0, 0.0]), 1.570796, 0.001);
  });

  runTest('STAT: mean', () {
    var xs = [1.0, 2.0, 3.0, 4.0, 5.0];
    expect(StatisticsHelper.mean(xs), 3.0);
  });

  runTest('STAT: standard deviation', () {
    var xs = [1.0, 2.0, 3.0, 4.0, 5.0];
    expectCloseTo(StatisticsHelper.sampleStdDev(xs), 1.581, 0.01);
  });

  runTest('STAT: linear regression', () {
    var xs = [1.0, 2.0, 3.0, 4.0, 5.0];
    var ys = [2.0, 4.0, 5.0, 4.0, 5.0];
    var lin = StatisticsHelper.linearRegression(xs, ys);
    expectCloseTo(lin.slope, 0.6, 0.01);
    expectCloseTo(lin.intercept, 2.2, 0.01);
  });

  runTest('EQN: quadratic roots', () {
    var quad = EquationSolver.solveQuadratic(1, -5, 6);
    expect(quad.map((c)=>c.real).toList().contains(2.0), true);
    expect(quad.map((c)=>c.real).toList().contains(3.0), true);
  });

  runTest('EQN: simultaneous equations', () {
    var sim = EquationSolver.solveLinearSystem([
      [2, 1], [1, -1]
    ], [5, 1]);
    expect(sim, [2.0, 1.0]);
  });

  runTest('BASE-N: decimal to binary', () {
    expect(BaseNHelper.toBase(10, 2), '1010');
  });

  runTest('BASE-N: binary to hex', () {
    expect(BaseNHelper.toBase(int.parse('11111111', radix: 2), 16), 'FF');
  });

  runTest('BASE-N: XOR', () {
    expect(10 ^ 3, 9);
  });

  runTest('BASE-N: shift operations', () {
    expect(10 << 1, 20);
  });

  runTest('TABLE: f(x)=x^2', () {
    expect(MathParser.evaluate('X^2', isDegree: false, variables: {'X': 3}), '9.0');
  });

  runTest('TABLE: g(x)=sin(x)', () {
    expect(MathParser.evaluate('sin(X)', isDegree: false, variables: {'X': 0}), '0.0');
  });

  print('\nSummary: $passed passed, $failed failed.');
  if (failed > 0) {
    print('Failures:');
    for (var r in report) print(r);
  }
}
