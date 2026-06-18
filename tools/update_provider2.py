import sys

with open("lib/providers/calculator_provider.dart", "r") as f:
    content = f.read()

content = content.replace('''  void clear() {
    final expr = state.expression;
    final List<String> newUndo = List.from(state.undoStack)..add(expr);
    state = state.copyWith(
      expression: '',
          mathAst: MathAST(),
      result: '',
      cursorPosition: 0,
      undoStack: newUndo,
      redoStack: const [],
    );
  }''', '''  void clear() {
    state.mathAst.clear();
    state = state.copyWith(
      expression: '',
      result: '',
    );
  }''')

with open("lib/providers/calculator_provider.dart", "w") as f:
    f.write(content)
