import 'lib/providers/calculator_provider.dart';
import 'lib/core/math_engine/math_parser.dart';

void main() {
  try {
    double r1 = MathParser.evaluate('arcsin(2)', isDegree: false);
    print("arcsin(2) = $r1");
  } catch (e) {
    print("arcsin(2) throws: $e");
  }

  try {
    double r2 = MathParser.evaluate('arctan(2)', isDegree: false);
    print("arctan(2) = $r2");
  } catch (e) {
    print("arctan(2) throws: $e");
  }
}
