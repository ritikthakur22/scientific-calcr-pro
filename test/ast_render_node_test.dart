import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/math_engine/ast_render_node.dart';

void main() {
  group('MathAST Textbook Renderer Tests', () {
    test('Insert simple text and numbers', () {
      final ast = MathAST();
      ast.insert('123.45');
      expect(ast.toExpression(), '123.45');
      expect(ast.root.nodes.length, 6); // 1, 2, 3, ., 4, 5
      expect(ast.root.nodes.first, isA<CharNode>());
    });

    test('Insert fractions', () {
      final ast = MathAST();
      ast.insert('/');
      expect(ast.root.nodes.length, 1);
      expect(ast.root.nodes.first, isA<FractionNode>());
      ast.insert('1');
      ast.moveDown();
      ast.insert('2');
      expect(ast.toExpression(), '(1)/(2)');
    });

    test('Insert square roots', () {
      final ast = MathAST();
      ast.insert('√(');
      expect(ast.root.nodes.length, 1);
      expect(ast.root.nodes.first, isA<RootNode>());
      ast.insert('X');
      expect(ast.toExpression(), 'sqrt(X)');
    });

    test('Insert power / superscript', () {
      final ast = MathAST();
      ast.insert('X');
      ast.insert('^');
      expect(ast.root.nodes.length, 2);
      expect(ast.root.nodes[1], isA<PowerNode>());
      ast.insert('2');
      expect(ast.toExpression(), 'X^(2)');
    });

    test('Widget rendering validation', () {
      final ast = MathAST();
      ast.insert('123');
      final style = const TextStyle(fontSize: 20.0);
      final widget = ast.root.buildWidget(ast.cursor, style, Colors.black, (c) {});
      expect(widget, isA<MathListWidget>());
    });
  });
}
