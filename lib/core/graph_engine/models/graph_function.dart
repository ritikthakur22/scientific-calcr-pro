import 'dart:ui';

class GraphFunction {
  final String id;
  final String expression;
  final Color color;
  final bool isVisible;

  GraphFunction({
    required this.id,
    required this.expression,
    required this.color,
    this.isVisible = true,
  });
}
