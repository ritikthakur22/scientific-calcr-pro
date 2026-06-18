import 'package:math_expressions/math_expressions.dart';

void main() {
  Parser p = Parser();
  var cm = ContextModel();
  print("arcsin(2): ${p.parse('arcsin(2)').evaluate(EvaluationType.REAL, cm)}");
  print("arccos(2): ${p.parse('arccos(2)').evaluate(EvaluationType.REAL, cm)}");
  print("arctan(2): ${p.parse('arctan(2)').evaluate(EvaluationType.REAL, cm)}");
}
