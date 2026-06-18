import 'dart:math' as math;
import 'lib/core/math_engine/complex_number.dart';

extension ComplexTrig on Complex {
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
}

void main() {
  var c = Complex(8.0, 0.0);
  print("acos(8): ${c.acos().toRectString(precision: 6)}");
  print("asin(8): ${c.asin().toRectString(precision: 6)}");
  print("atan(8): ${c.atan().toRectString(precision: 6)}");
}
