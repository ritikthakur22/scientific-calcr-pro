import 'dart:math' as math;
import 'complex_number.dart';
import 'matrix_engine.dart';

class EquationSolver {
  /// Solves systems of linear equations: A * X = B
  /// [coefficients] represents the A matrix (size N x N)
  /// [constants] represents the B vector (size N)
  /// Returns List<double> representing the solutions for x, y, z...
  static List<double> solveLinearSystem(List<List<double>> coefficients, List<double> constants) {
    int n = constants.length;
    var a = Matrix(n, n, coefficients);
    var b = Matrix(n, 1, constants.map((val) => [val]).toList());
    
    // X = A^-1 * B
    var x = a.inverse().multiply(b);
    return x.data.map((row) => row[0]).toList();
  }

  /// Solves quadratic equation: a*x^2 + b*x + c = 0
  /// Returns a list of Complex roots
  static List<Complex> solveQuadratic(double a, double b, double c) {
    if (a == 0) {
      if (b == 0) return []; // Inconsistent or trivial
      return [Complex(-c / b, 0.0)]; // Linear fallback
    }
    double discriminant = b * b - 4 * a * c;
    if (discriminant >= 0) {
      double r1 = (-b + math.sqrt(discriminant)) / (2 * a);
      double r2 = (-b - math.sqrt(discriminant)) / (2 * a);
      return [Complex(r1, 0.0), Complex(r2, 0.0)];
    } else {
      double realPart = -b / (2 * a);
      double imagPart = math.sqrt(-discriminant) / (2 * a);
      return [
        Complex(realPart, imagPart),
        Complex(realPart, -imagPart),
      ];
    }
  }

  /// Solves cubic equation: a*x^3 + b*x^2 + c*x + d = 0
  /// Uses Cardano's formula. Returns 3 Complex roots.
  static List<Complex> solveCubic(double a, double b, double c, double d) {
    if (a == 0) return solveQuadratic(b, c, d);

    // Normalize coefficients
    double p = (3 * a * c - b * b) / (3 * a * a);
    double q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (27 * a * a * a);

    if (p == 0 && q == 0) {
      double root = -b / (3 * a);
      return [Complex(root, 0.0), Complex(root, 0.0), Complex(root, 0.0)];
    }

    double disc = (q * q) / 4 + (p * p * p) / 27;

    Complex u, v;
    if (disc > 0) {
      double sqrtDisc = math.sqrt(disc);
      double u3 = -q / 2 + sqrtDisc;
      double v3 = -q / 2 - sqrtDisc;
      
      double uVal = u3 >= 0 ? math.pow(u3, 1/3).toDouble() : -math.pow(-u3, 1/3).toDouble();
      double vVal = v3 >= 0 ? math.pow(v3, 1/3).toDouble() : -math.pow(-v3, 1/3).toDouble();
      
      u = Complex(uVal, 0.0);
      v = Complex(vVal, 0.0);
    } else if (disc == 0) {
      double uVal = q > 0 ? -math.pow(q / 2, 1/3).toDouble() : math.pow(-q / 2, 1/3).toDouble();
      u = Complex(uVal, 0.0);
      v = Complex(uVal, 0.0);
    } else {
      // disc < 0: Three real roots
      double r = math.sqrt(-(p * p * p) / 27);
      double phi = math.acos(-q / (2 * r));
      double uVal = math.pow(r, 1/3).toDouble();
      u = Complex.fromPolar(uVal, phi / 3);
      v = u.conjugate;
    }

    // Roots of y^3 + py + q = 0 are:
    // y1 = u + v
    // y2 = u * omega + v * omega^2
    // y3 = u * omega^2 + v * omega
    // where omega = -0.5 + i * sqrt(3)/2
    Complex omega = Complex(-0.5, math.sqrt(3) / 2);
    Complex omegaSq = Complex(-0.5, -math.sqrt(3) / 2);

    Complex y1 = u.add(v);
    Complex y2 = u.multiply(omega).add(v.multiply(omegaSq));
    Complex y3 = u.multiply(omegaSq).add(v.multiply(omega));

    // Convert back to x = y - b/(3a)
    double offset = b / (3 * a);
    return [
      Complex(y1.real - offset, y1.imaginary),
      Complex(y2.real - offset, y2.imaginary),
      Complex(y3.real - offset, y3.imaginary),
    ];
  }

  /// Solves quartic equation: a*x^4 + b*x^3 + c*x^2 + d*x + e = 0
  /// Uses Ferrari's method. Returns 4 Complex roots.
  static List<Complex> solveQuartic(double a, double b, double c, double d, double e) {
    if (a == 0) return solveCubic(b, c, d, e);

    // Normalize coefficients: x^4 + Bx^3 + Cx^2 + Dx + E = 0
    double B = b / a;
    double C = c / a;
    double D = d / a;
    double E = e / a;

    // Substitute x = y - B/4 to get depressed quartic: y^4 + p*y^2 + q*y + r = 0
    double p = C - 3 * B * B / 8;
    double q = D - B * C / 2 + B * B * B / 8;
    double r = E - B * D / 4 + B * B * C / 16 - 3 * B * B * B * B / 256;

    if (q == 0) {
      // Biquadratic equation: y^4 + p*y^2 + r = 0
      List<Complex> sqRoots = solveQuadratic(1.0, p, r);
      List<Complex> roots = [];
      for (var root in sqRoots) {
        Complex r1 = root.sqrt();
        Complex r2 = Complex(-r1.real, -r1.imaginary);
        roots.addAll([r1, r2]);
      }
      double offset = B / 4;
      return roots.map((root) => Complex(root.real - offset, root.imaginary)).toList();
    }

    // Resolving cubic: m^3 + (5/2)*p*m^2 + (2*p^2 - r)*m + (p^3/2 - p*r - q^2/8) = 0
    double cA = 1.0;
    double cB = 2.5 * p;
    double cC = 2 * p * p - r;
    double cD = 0.5 * p * p * p - p * r - q * q / 8;

    List<Complex> cubicRoots = solveCubic(cA, cB, cC, cD);
    // Find a real root m
    double m = 0.0;
    for (var root in cubicRoots) {
      if (root.imaginary.abs() < 1e-9) {
        m = root.real;
        break;
      }
    }

    // Solve two quadratics:
    // y^2 + k*y + (m + p/2 - q/(2k)) = 0
    // y^2 - k*y + (m + p/2 + q/(2k)) = 0
    // where k = sqrt(2m + p)
    double kSq = 2 * m + p;
    if (kSq < 0) {
      // Let's use Newton-Raphson starting from estimated roots for robustness when Cardano/Ferrari splits fail
      return _newtonRaphsonQuartic(B, C, D, E);
    }
    double k = math.sqrt(kSq);
    if (k == 0) return _newtonRaphsonQuartic(B, C, D, E);

    List<Complex> roots = [];
    double offset = B / 4;

    // First quadratic: y^2 + k*y + (m + p/2 - q/(2k)) = 0
    double q1_c = m + p / 2 - q / (2 * k);
    List<Complex> r12 = solveQuadratic(1.0, k, q1_c);
    for (var r in r12) {
      roots.add(Complex(r.real - offset, r.imaginary));
    }

    // Second quadratic: y^2 - k*y + (m + p/2 + q/(2k)) = 0
    double q2_c = m + p / 2 + q / (2 * k);
    List<Complex> r34 = solveQuadratic(1.0, -k, q2_c);
    for (var r in r34) {
      roots.add(Complex(r.real - offset, r.imaginary));
    }

    return roots;
  }

  static List<Complex> _newtonRaphsonQuartic(double B, double C, double D, double E) {
    // Basic root-finding fallback using deflation
    List<Complex> roots = [];
    // Helper function to evaluate polynomial and its derivative
    Complex evalPoly(Complex x) {
      // x^4 + Bx^3 + Cx^2 + Dx + E
      Complex x2 = x.multiply(x);
      Complex x3 = x2.multiply(x);
      Complex x4 = x3.multiply(x);
      return x4.add(x3.scale(B)).add(x2.scale(C)).add(x.scale(D)).add(Complex(E, 0.0));
    }
    Complex evalDeriv(Complex x) {
      // 4x^3 + 3Bx^2 + 2Cx + D
      Complex x2 = x.multiply(x);
      Complex x3 = x2.multiply(x);
      return x3.scale(4.0).add(x2.scale(3 * B)).add(x.scale(2 * C)).add(Complex(D, 0.0));
    }

    List<Complex> initialGuesses = [
      Complex(1.0, 0.0), Complex(-1.0, 0.0), Complex(0.0, 1.0), Complex(0.0, -1.0)
    ];

    for (int step = 0; step < 4; step++) {
      Complex x = initialGuesses[step];
      for (int i = 0; i < 100; i++) {
        Complex f = evalPoly(x);
        Complex df = evalDeriv(x);
        if (df.magnitude < 1e-12) break;
        Complex ratio = f.divide(df);
        x = x.subtract(ratio);
        if (ratio.magnitude < 1e-12) break;
      }
      roots.add(x);
    }
    return roots;
  }
}

extension on Complex {
  Complex scale(double factor) => Complex(real * factor, imaginary * factor);
}
