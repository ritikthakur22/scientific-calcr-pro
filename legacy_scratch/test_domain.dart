import 'package:math_expressions/math_expressions.dart';

void main() {
  Parser p = Parser();
  var e1 = p.parse('arcsin(2)');
  print("arcsin(2): ${e1.evaluate(EvaluationType.REAL, ContextModel())}");
}
