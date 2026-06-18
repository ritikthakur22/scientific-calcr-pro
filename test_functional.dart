import 'package:scientific_calcr_pro/core/math_engine/math_parser.dart';

void main() {
  final expressions = [
    'arcsin(2)',
    'arccos(2)',
    'arctan(999999)',
  ];

  for (var expr in expressions) {
    try {
      final res = MathParser.evaluate(expr, isDegree: true);
      print('$expr = $res');
    } catch (e) {
      print('$expr = ERROR ($e)');
    }
  }
}
