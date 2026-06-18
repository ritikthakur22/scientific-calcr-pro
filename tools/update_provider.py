import sys

with open("lib/providers/calculator_provider.dart", "r") as f:
    content = f.read()

# Replace methods
replacements = {
'''  void append(String char) {
    final curPos = state.cursorPosition;
    final expr = state.expression;
    final newExpression = expr.substring(0, curPos) + char + expr.substring(curPos);
    final newCursorPos = curPos + char.length;
    final List<String> newUndo = List.from(state.undoStack)..add(expr);

    state = state.copyWith(
      expression: newExpression,
      cursorPosition: newCursorPos,
      undoStack: newUndo,
      redoStack: const [],
      isShift: false,
      isAlpha: false,
    );
  }''': '''  void append(String char) {
    state.mathAst.insert(char);
    state = state.copyWith(
      expression: state.mathAst.toExpression(),
      isShift: false,
      isAlpha: false,
    );
  }''',

'''  void insertText(String text) {
    final curPos = state.cursorPosition;
    final expr = state.expression;
    final newExpression = expr.substring(0, curPos) + text + expr.substring(curPos);
    final newCursorPos = curPos + text.length;
    final List<String> newUndo = List.from(state.undoStack)..add(expr);

    state = state.copyWith(
      expression: newExpression,
      cursorPosition: newCursorPos,
      undoStack: newUndo,
      redoStack: const [],
    );
  }''': '''  void insertText(String text) {
    state.mathAst.insert(text);
    state = state.copyWith(
      expression: state.mathAst.toExpression(),
    );
  }''',

'''  void backspace() {
    final curPos = state.cursorPosition;
    final expr = state.expression;
    if (expr.isNotEmpty && curPos > 0) {
      final newExpression = expr.substring(0, curPos - 1) + expr.substring(curPos);
      final newCursorPos = curPos - 1;
      final List<String> newUndo = List.from(state.undoStack)..add(expr);

      state = state.copyWith(
        expression: newExpression,
        cursorPosition: newCursorPos,
        undoStack: newUndo,
        redoStack: const [],
      );
    }
  }''': '''  void backspace() {
    state.mathAst.backspace();
    state = state.copyWith(
      expression: state.mathAst.toExpression(),
    );
  }''',

'''  void moveCursorLeft() {
    if (state.cursorPosition > 0) {
      state = state.copyWith(cursorPosition: state.cursorPosition - 1);
    }
  }''': '''  void moveCursorLeft() {
    state.mathAst.moveLeft();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }''',

'''  void moveCursorRight() {
    if (state.cursorPosition < state.expression.length) {
      state = state.copyWith(cursorPosition: state.cursorPosition + 1);
    }
  }''': '''  void moveCursorRight() {
    state.mathAst.moveRight();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }''',

'''  void undo() {
    if (state.undoStack.isNotEmpty) {
      final prevExpr = state.undoStack.last;
      final newUndo = List<String>.from(state.undoStack)..removeLast();
      final newRedo = List<String>.from(state.redoStack)..add(state.expression);
      final newCursor = state.cursorPosition > prevExpr.length ? prevExpr.length : state.cursorPosition;

      state = state.copyWith(
        expression: prevExpr,
        undoStack: newUndo,
        redoStack: newRedo,
        cursorPosition: newCursor,
      );
    }
  }''': '''  void undo() { // We map UP nav to undo() in UI, so let's make it moveUp()
    state.mathAst.moveUp();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }''',

'''  void redo() {
    if (state.redoStack.isNotEmpty) {
      final nextExpr = state.redoStack.last;
      final newRedo = List<String>.from(state.redoStack)..removeLast();
      final newUndo = List<String>.from(state.undoStack)..add(state.expression);
      final newCursor = state.cursorPosition > nextExpr.length ? nextExpr.length : state.cursorPosition;

      state = state.copyWith(
        expression: nextExpr,
        undoStack: newUndo,
        redoStack: newRedo,
        cursorPosition: newCursor,
      );
    }
  }''': '''  void redo() { // We map DOWN nav to redo() in UI, so let's make it moveDown()
    state.mathAst.moveDown();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }
  
  void setCursor(MathCursor cursor) {
    state.mathAst.cursor = cursor;
    state = state.copyWith(expression: state.mathAst.toExpression());
  }'''
}

for k, v in replacements.items():
    content = content.replace(k, v)

with open("lib/providers/calculator_provider.dart", "w") as f:
    f.write(content)
