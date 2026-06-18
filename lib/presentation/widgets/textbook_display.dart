import 'package:flutter/material.dart';
import '../../core/theme/calc_theme.dart';
import '../../core/math_engine/ast_render_node.dart';

class TextbookDisplay extends StatelessWidget {
  final String expression;
  final MathAST mathAst;
  final Function(MathCursor)? onCursorChanged;
  final String result;
  final CalcTheme theme;
  final bool isShift;
  final bool isAlpha;
  final String modeName;
  final int cursorPosition;

  const TextbookDisplay({
    super.key,
    required this.expression,
    required this.mathAst,
    this.onCursorChanged,
    required this.result,
    required this.theme,
    required this.isShift,
    required this.isAlpha,
    required this.modeName,
    required this.cursorPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.displayBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.backgroundColor.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top status bar (shows SHIFT, ALPHA, current Mode)
          Row(
            children: [
              _buildBadge('SHIFT', isShift, theme.shiftKeyColor),
              const SizedBox(width: 6),
              _buildBadge('ALPHA', isAlpha, theme.alphaKeyColor),
              const Spacer(),
              Text(
                modeName.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.displayTextColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // reduced from 12
          // Upper Display (editable expression)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _buildTextbookExpression(expression, cursorPosition),
                ),
              ),
            ),
          ),
          const Divider(height: 8, thickness: 1), // reduced from 20
          // Lower Display (results)
          Align(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                result.isEmpty ? '0' : result,
                style: theme.displayResultStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, bool active, Color activeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: active ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? activeColor : theme.displayTextColor.withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : theme.displayTextColor.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Uses the provided MathAST to build the textbook expression
  Widget _buildTextbookExpression(String expr, int cursorPos) {
    return mathAst.root.buildWidget(
      mathAst.cursor, 
      theme.displayInputStyle, 
      theme.displayTextColor,
      (cursor) {
        if (onCursorChanged != null) {
          onCursorChanged!(cursor);
        }
      }
    );
  }
}
