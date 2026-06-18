import sys

with open("lib/presentation/widgets/textbook_display.dart", "r") as f:
    content = f.read()

content = content.replace('''  /// Parses the input expression and returns standard Widgets for textbook display
  Widget _buildTextbookExpression(String expr, int cursorPos) {
    if (expr.isEmpty) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BlinkingCursor(),
        ],
      );
    }
    // Insert cursor character at the cursorPosition
    final pos = cursorPos > expr.length ? expr.length : (cursorPos < 0 ? 0 : cursorPos);
    final withCursor = expr.substring(0, pos) + '⦀' + expr.substring(pos);
    return ASTTextbookParser.parse(withCursor).toWidget(theme.displayInputStyle, theme.displayTextColor);
  }''', '''  /// Uses the provided MathAST to build the textbook expression
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
  }''')

with open("lib/presentation/widgets/textbook_display.dart", "w") as f:
    f.write(content)
