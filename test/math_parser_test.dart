import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/math_engine/math_parser.dart';

void main() {
  group('Math Parser Tests', () {
    test('Standard evaluations and operators', () {
      expect(MathParser.evaluate("2 + 3 * 4"), 14.0);
      expect(MathParser.evaluate("(2 + 3) * 4"), 20.0);
      expect(MathParser.evaluate("5^2 - 10"), 15.0);
      expect(MathParser.evaluate("sin(0) + cos(0)"), 1.0);
      expect(MathParser.evaluate("ln(e)"), 1.0);
    });

    test('Implicit multiplication preprocessing', () {
      // 2pi -> 2 * pi
      expect(MathParser.evaluate("2pi"), closeTo(6.283185, 1e-4));
      // 2(3+4) -> 2 * (3+4)
      expect(MathParser.evaluate("2(3+4)"), 14.0);
    });

    test('Variable storage and resolution', () {
      MathParser.setVariable('X', 5.0);
      expect(MathParser.getVariable('X'), 5.0);
      expect(MathParser.evaluate("2 * X + 3"), 13.0);
    });

    test('Numerical calculus evaluation (derivative & integral)', () {
      // Derivative of x^2 at x=3 is 2*x = 6
      double deriv = MathParser.numericalDerivative("X^2", "X", 3.0);
      expect(deriv, closeTo(6.0, 1e-4));

      // Integral of x from 0 to 2 is [x^2/2] from 0 to 2 = 2
      double integral = MathParser.numericalIntegral("X", "X", 0.0, 2.0);
      expect(integral, closeTo(2.0, 1e-4));
    });

    test('Mathematical error conditions', () {
      expect(() => MathParser.evaluate("1 / 0"), throwsA(isA<ArgumentError>()));
      expect(() => MathParser.evaluate("invalid expr"), throwsA(isA<FormatException>()));
    });
  });
}
