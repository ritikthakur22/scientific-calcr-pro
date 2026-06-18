import 'dart:math' as math;

class Complex {
  final double real;
  final double imaginary;

  Complex(this.real, this.imaginary);

  factory Complex.fromPolar(double r, double thetaRad) {
    return Complex(r * math.cos(thetaRad), r * math.sin(thetaRad));
  }

  double get magnitude => math.sqrt(real * real + imaginary * imaginary);
  double get argument => math.atan2(imaginary, real); // theta in radians

  Complex get conjugate => Complex(real, -imaginary);

  Complex add(Complex other) => Complex(real + other.real, imaginary + other.imaginary);
  Complex subtract(Complex other) => Complex(real - other.real, imaginary - other.imaginary);
  
  Complex multiply(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }

  Complex divide(Complex other) {
    double denom = other.real * other.real + other.imaginary * other.imaginary;
    if (denom == 0) throw ArgumentError("Division by zero in complex numbers.");
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denom,
      (imaginary * other.real - real * other.imaginary) / denom,
    );
  }

  Complex power(double exponent) {
    double r = math.pow(magnitude, exponent).toDouble();
    double theta = argument * exponent;
    return Complex.fromPolar(r, theta);
  }

  Complex sqrt() {
    double r = math.sqrt(magnitude);
    double theta = argument / 2;
    return Complex.fromPolar(r, theta);
  }

  Complex get log {
    double r = magnitude;
    double theta = argument;
    return Complex(math.log(r), theta);
  }

  Complex asin() {
    Complex iz = Complex(-imaginary, real);
    Complex z2 = multiply(this);
    Complex oneMinusZ2 = Complex(1.0, 0.0).subtract(z2);
    Complex sqrtOneMinusZ2 = oneMinusZ2.sqrt();
    Complex argLog = iz.add(sqrtOneMinusZ2);
    Complex lnArg = argLog.log;
    return Complex(lnArg.imaginary, -lnArg.real);
  }

  Complex acos() {
    Complex z2 = multiply(this);
    Complex oneMinusZ2 = Complex(1.0, 0.0).subtract(z2);
    Complex sqrtOneMinusZ2 = oneMinusZ2.sqrt();
    Complex iSqrt = Complex(-sqrtOneMinusZ2.imaginary, sqrtOneMinusZ2.real);
    Complex argLog = this.add(iSqrt);
    Complex lnArg = argLog.log;
    return Complex(lnArg.imaginary, -lnArg.real);
  }

  Complex atan() {
    Complex i = Complex(0.0, 1.0);
    Complex iPlusZ = i.add(this);
    Complex iMinusZ = i.subtract(this);
    Complex ratio = iPlusZ.divide(iMinusZ);
    Complex lnRatio = ratio.log;
    return Complex(-lnRatio.imaginary / 2, lnRatio.real / 2);
  }

  String toRectString({int precision = 6}) {
    if (imaginary == 0) return real.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '');
    String sign = imaginary >= 0 ? '+' : '-';
    String imagPart = imaginary.abs() == 1 ? 'i' : '${imaginary.abs().toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '')}i';
    if (real == 0) return sign == '-' ? '-$imagPart' : imagPart;
    return '${real.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '')} $sign $imagPart';
  }

  String toPolarString({int precision = 6}) {
    double r = magnitude;
    double deg = argument * 180 / math.pi;
    return '${r.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '')} ∠ ${deg.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '')}°';
  }

  String toEulerString({int precision = 6}) {
    double r = magnitude;
    double theta = argument;
    return '${r.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '')}e^(${theta.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '')}i)';
  }

  @override
  String toString() => toRectString();
}
