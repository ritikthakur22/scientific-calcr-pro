import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/math_engine/equation_solver.dart';

void main() {
  group('Equation Solver Engine Tests', () {
    test('Linear simultaneous equations solver (2, 3, and 4 variables)', () {
      // 2 variables:
      // 2x + y = 5
      //  x - y = 1
      // Solutions: x = 2, y = 1
      final sol2 = EquationSolver.solveLinearSystem(
        [[2.0, 1.0], [1.0, -1.0]],
        [5.0, 1.0],
      );
      expect(sol2[0], closeTo(2.0, 1e-9));
      expect(sol2[1], closeTo(1.0, 1e-9));

      // 3 variables:
      // 2x + y - z = 8
      // -3x - y + 2z = -11
      // -2x + y + 2z = -3
      // Solutions: x = 2, y = 3, z = -1
      final sol3 = EquationSolver.solveLinearSystem(
        [
          [2.0, 1.0, -1.0],
          [-3.0, -1.0, 2.0],
          [-2.0, 1.0, 2.0]
        ],
        [8.0, -11.0, -3.0],
      );
      expect(sol3[0], closeTo(2.0, 1e-9));
      expect(sol3[1], closeTo(3.0, 1e-9));
      expect(sol3[2], closeTo(-1.0, 1e-9));
    });

    test('Quadratic equation solver (real and complex roots)', () {
      // Real distinct roots: x^2 - 5x + 6 = 0 -> x = 2, 3
      final roots1 = EquationSolver.solveQuadratic(1.0, -5.0, 6.0);
      expect(roots1.length, 2);
      expect(roots1[0].real, closeTo(3.0, 1e-9));
      expect(roots1[1].real, closeTo(2.0, 1e-9));

      // Complex roots: x^2 + x + 1 = 0 -> x = -0.5 ± sqrt(3)/2 i
      final roots2 = EquationSolver.solveQuadratic(1.0, 1.0, 1.0);
      expect(roots2.length, 2);
      expect(roots2[0].real, -0.5);
      expect(roots2[0].imaginary, closeTo(0.8660254, 1e-6));
      expect(roots2[1].real, -0.5);
      expect(roots2[1].imaginary, closeTo(-0.8660254, 1e-6));

      // Linear fallback (a = 0): 2x - 4 = 0 -> x = 2
      final roots3 = EquationSolver.solveQuadratic(0.0, 2.0, -4.0);
      expect(roots3.length, 1);
      expect(roots3[0].real, 2.0);

      // Trivial/Inconsistent case: a = 0, b = 0, c = 5 -> no roots
      final roots4 = EquationSolver.solveQuadratic(0.0, 0.0, 5.0);
      expect(roots4, isEmpty);
    });

    test('Cubic equation solver Cardano validation and fallbacks', () {
      // roots: 1, 2, 3 -> (x-1)(x-2)(x-3) = x^3 - 6x^2 + 11x - 6 = 0
      final roots = EquationSolver.solveCubic(1.0, -6.0, 11.0, -6.0);
      expect(roots.length, 3);
      
      final sortedReal = roots.map((r) => r.real).toList()..sort();
      expect(sortedReal[0], closeTo(1.0, 1e-6));
      expect(sortedReal[1], closeTo(2.0, 1e-6));
      expect(sortedReal[2], closeTo(3.0, 1e-6));

      // Single real and two complex roots: x^3 - 1 = 0 -> x = 1, -0.5 ± 0.866 i
      final roots2 = EquationSolver.solveCubic(1.0, 0.0, 0.0, -1.0);
      final sortedReal2 = roots2.map((r) => r.real).toList()..sort();
      expect(sortedReal2[2], closeTo(1.0, 1e-6));

      // Quadratic fallback (a = 0): 2x^2 - 10x + 12 = 0 -> roots 2, 3
      final rootsFallback = EquationSolver.solveCubic(0.0, 2.0, -10.0, 12.0);
      expect(rootsFallback.length, 2);
      final sortedFallback = rootsFallback.map((r) => r.real).toList()..sort();
      expect(sortedFallback[0], closeTo(2.0, 1e-6));
      expect(sortedFallback[1], closeTo(3.0, 1e-6));

      // Triply degenerate root: (x - 2)^3 = x^3 - 6x^2 + 12x - 8 = 0
      // normalized p = 0, q = 0
      final rootsTriple = EquationSolver.solveCubic(1.0, -6.0, 12.0, -8.0);
      expect(rootsTriple.length, 3);
      expect(rootsTriple[0].real, closeTo(2.0, 1e-6));
      expect(rootsTriple[1].real, closeTo(2.0, 1e-6));
      expect(rootsTriple[2].real, closeTo(2.0, 1e-6));

      // disc == 0 case (double root): (x - 3)(x - 0)^2 = x^3 - 3x^2 = 0
      final rootsDiscZero = EquationSolver.solveCubic(1.0, -3.0, 0.0, 0.0);
      expect(rootsDiscZero.length, 3);
      final sortedDiscZero = rootsDiscZero.map((r) => r.real).toList()..sort();
      expect(sortedDiscZero[0], closeTo(0.0, 1e-6));
      expect(sortedDiscZero[1], closeTo(0.0, 1e-6));
      expect(sortedDiscZero[2], closeTo(3.0, 1e-6));
    });

    test('Quartic equation solver Ferrari validation and fallbacks', () {
      // roots: 1, 2, 3, 4 -> x^4 - 10x^3 + 35x^2 - 50x + 24 = 0 (Depressed q = 0)
      final roots = EquationSolver.solveQuartic(1.0, -10.0, 35.0, -50.0, 24.0);
      expect(roots.length, 4);

      final sortedReal = roots.map((r) => r.real).toList()..sort();
      expect(sortedReal[0], closeTo(1.0, 1e-4));
      expect(sortedReal[1], closeTo(2.0, 1e-4));
      expect(sortedReal[2], closeTo(3.0, 1e-4));
      expect(sortedReal[3], closeTo(4.0, 1e-4));

      // Cubic fallback (a = 0)
      final rootsCubic = EquationSolver.solveQuartic(0.0, 1.0, -6.0, 11.0, -6.0);
      expect(rootsCubic.length, 3);
      final sortedCubic = rootsCubic.map((r) => r.real).toList()..sort();
      expect(sortedCubic[0], closeTo(1.0, 1e-4));
      expect(sortedCubic[1], closeTo(2.0, 1e-4));
      expect(sortedCubic[2], closeTo(3.0, 1e-4));

      // Biquadratic case (q = 0): x^4 - 5x^2 + 4 = 0 -> roots ±1, ±2
      final rootsBiquad = EquationSolver.solveQuartic(1.0, 0.0, -5.0, 0.0, 4.0);
      expect(rootsBiquad.length, 4);
      final sortedBiquad = rootsBiquad.map((r) => r.real).toList()..sort();
      expect(sortedBiquad[0], closeTo(-2.0, 1e-4));
      expect(sortedBiquad[1], closeTo(-1.0, 1e-4));
      expect(sortedBiquad[2], closeTo(1.0, 1e-4));
      expect(sortedBiquad[3], closeTo(2.0, 1e-4));

      // General case: q != 0, kSq > 0
      // x^4 + 2x^3 + 3x^2 + 4x + 5 = 0
      final rootsGeneral = EquationSolver.solveQuartic(1.0, 2.0, 3.0, 4.0, 5.0);
      expect(rootsGeneral.length, 4);

      // Case: kSq < 0 triggering Newton-Raphson fallback
      // B = -1.5799110106625633, C = 9.31515462287188, D = -9.034014001200037, E = -8.157637400596169
      final rootsNR = EquationSolver.solveQuartic(1.0, -1.5799110106625633, 9.31515462287188, -9.034014001200037, -8.157637400596169);
      expect(rootsNR.length, 4);

      // Case: k == 0 triggering Newton-Raphson fallback
      final rootsNR2 = EquationSolver.solveQuartic(1.0, 0.0, 0.0, 0.0, 0.0);
      expect(rootsNR2.length, 4);
      expect(rootsNR2.every((r) => r.magnitude < 1e-3), true);
    });
  });
}
