import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/math_engine/math_parser.dart';
import 'package:scientific_calcr_pro/core/math_engine/matrix_engine.dart';
import 'package:scientific_calcr_pro/core/math_engine/equation_solver.dart';

void main() {
  test('Engine Performance Benchmark', () {
    // 1. Math Parser Evaluation Benchmark
    final parserWatch = Stopwatch()..start();
    const int parserIterations = 1000;
    for (int i = 0; i < parserIterations; i++) {
      MathParser.evaluate("2 * sin(pi / 4) + ln(e^3) - 5^2");
    }
    parserWatch.stop();
    final double avgParserNs = (parserWatch.elapsedMicroseconds / parserIterations) * 1000;

    // 2. Matrix operations Benchmark (Det, Inv, Multiply on 4x4)
    final matrixWatch = Stopwatch()..start();
    const int matrixIterations = 1000;
    final m1 = Matrix(4, 4, [
      [4.0, 7.0, 2.0, 3.0],
      [1.0, 3.0, 1.0, 2.0],
      [2.0, 0.0, 4.0, 1.0],
      [0.0, 1.0, 3.0, 5.0]
    ]);
    for (int i = 0; i < matrixIterations; i++) {
      m1.determinant();
      m1.inverse();
      m1.multiply(m1);
    }
    matrixWatch.stop();
    final double avgMatrixNs = (matrixWatch.elapsedMicroseconds / matrixIterations) * 1000;

    // 3. Equation Solver Benchmark (Cubic analytical Cardano)
    final equationWatch = Stopwatch()..start();
    const int equationIterations = 1000;
    for (int i = 0; i < equationIterations; i++) {
      EquationSolver.solveCubic(2.0, -3.0, 0.0, 5.0);
    }
    equationWatch.stop();
    final double avgEquationNs = (equationWatch.elapsedMicroseconds / equationIterations) * 1000;

    // Print values in test output
    print("BENCHMARK_RESULT: MathParser Evaluation = ${avgParserNs.toStringAsFixed(2)} ns (avg over $parserIterations runs)");
    print("BENCHMARK_RESULT: Matrix operations = ${avgMatrixNs.toStringAsFixed(2)} ns (avg over $matrixIterations runs)");
    print("BENCHMARK_RESULT: Equation Solver = ${avgEquationNs.toStringAsFixed(2)} ns (avg over $equationIterations runs)");
  });
}
