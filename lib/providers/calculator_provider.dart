import "../core/math_engine/ast_render_node.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/math_engine/math_parser.dart';
import '../core/math_engine/complex_number.dart';
import '../core/math_engine/matrix_engine.dart';
import '../core/math_engine/vector_engine.dart';
import '../core/math_engine/equation_solver.dart';
import '../data/database_helper.dart';
import '../core/execution/calculation_job.dart';
import '../core/execution/math_isolate.dart';
import '../core/cas_engine/cas_engine.dart';

enum CalculatorMode {
  comp,
  complex,
  baseN,
  equation,
  matrix,
  vector,
  statistics,
  table,
  graph,
  unitConverter,
  cas,
}

enum AngleMode {
  deg,
  rad,
  grad,
}

enum ComplexFormat {
  rect,
  polar,
}

class CalculatorState {
  final String expression;
  final MathAST mathAst;
  final String result;
  final CalculatorMode mode;
  final AngleMode angleMode;
  final bool isShift;
  final bool isAlpha;
  final bool isExamMode;
  final String ans;
  final Map<String, String> variables;
  final int cursorPosition;
  final List<String> undoStack;
  final List<String> redoStack;
  final ComplexFormat complexFormat;

  CalculatorState({
    required this.expression,
    required this.mathAst,
    required this.result,
    required this.mode,
    required this.angleMode,
    required this.isShift,
    required this.isAlpha,
    required this.isExamMode,
    required this.ans,
    required this.variables,
    required this.cursorPosition,
    required this.undoStack,
    required this.redoStack,
    required this.complexFormat,
  });

  CalculatorState copyWith({
    String? expression,
    MathAST? mathAst,
    String? result,
    CalculatorMode? mode,
    AngleMode? angleMode,
    bool? isShift,
    bool? isAlpha,
    bool? isExamMode,
    String? ans,
    Map<String, String>? variables,
    int? cursorPosition,
    List<String>? undoStack,
    List<String>? redoStack,
    ComplexFormat? complexFormat,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      mathAst: mathAst ?? this.mathAst,
      result: result ?? this.result,
      mode: mode ?? this.mode,
      angleMode: angleMode ?? this.angleMode,
      isShift: isShift ?? this.isShift,
      isAlpha: isAlpha ?? this.isAlpha,
      isExamMode: isExamMode ?? this.isExamMode,
      ans: ans ?? this.ans,
      variables: variables ?? this.variables,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      complexFormat: complexFormat ?? this.complexFormat,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier()
      : super(CalculatorState(
          expression: '',
          mathAst: MathAST(),
          result: '',
          mode: CalculatorMode.comp,
          angleMode: AngleMode.deg,
          isShift: false,
          isAlpha: false,
          isExamMode: false,
          ans: '0',
          variables: {
            'A': '0',
            'B': '0',
            'C': '0',
            'D': '0',
            'X': '0',
            'Y': '0',
            'M': '0',
          },
          cursorPosition: 0,
          undoStack: const [],
          redoStack: const [],
          complexFormat: ComplexFormat.rect,
        ));

  void append(String char) {
    if (char == 'DRG') {
      AngleMode newMode = AngleMode.deg;
      if (state.angleMode == AngleMode.deg) newMode = AngleMode.rad;
      else if (state.angleMode == AngleMode.rad) newMode = AngleMode.grad;
      else newMode = AngleMode.deg;
      state = state.copyWith(angleMode: newMode, isShift: false, isAlpha: false);
      evaluate(isInstant: true);
      return;
    }
    state.mathAst.insert(char);
    state = state.copyWith(
      expression: state.mathAst.toExpression(),
      isShift: false,
      isAlpha: false,
    );
    evaluate(isInstant: true);
  }

  void insertText(String text) {
    state.mathAst.insert(text);
    state = state.copyWith(
      expression: state.mathAst.toExpression(),
    );
    evaluate(isInstant: true);
  }

  void backspace() {
    state.mathAst.backspace();
    state = state.copyWith(
      expression: state.mathAst.toExpression(),
    );
    evaluate(isInstant: true);
  }

  void clear() {
    state.mathAst.clear();
    state = state.copyWith(
      expression: '',
      result: '',
    );
    evaluate(isInstant: true);
  }

  void moveCursorLeft() {
    state.mathAst.moveLeft();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }

  void moveCursorRight() {
    state.mathAst.moveRight();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }

  void undo() { // We map UP nav to undo() in UI, so let's make it moveUp()
    state.mathAst.moveUp();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }

  void redo() { // We map DOWN nav to redo() in UI, so let's make it moveDown()
    state.mathAst.moveDown();
    state = state.copyWith(expression: state.mathAst.toExpression());
  }
  
  void setCursor(MathCursor cursor) {
    state.mathAst.cursor = cursor;
    state = state.copyWith(expression: state.mathAst.toExpression());
  }

  void toggleShift() {
    state = state.copyWith(isShift: !state.isShift, isAlpha: false);
  }

  void toggleAlpha() {
    state = state.copyWith(isAlpha: !state.isAlpha, isShift: false);
  }

  void setMode(CalculatorMode newMode) {
    if (state.isExamMode && (newMode == CalculatorMode.unitConverter)) {
      // Prevent advanced features in exam mode
    }
    state = state.copyWith(
      mode: newMode,
      expression: '',
          mathAst: MathAST(),
      result: '',
      cursorPosition: 0,
      undoStack: const [],
      redoStack: const [],
    );
  }

  void setExamMode(bool enable) {
    state = state.copyWith(
      isExamMode: enable,
      mode: enable ? CalculatorMode.comp : state.mode,
      expression: '',
          mathAst: MathAST(),
      result: '',
      cursorPosition: 0,
      undoStack: const [],
      redoStack: const [],
    );
  }

  Future<void> evaluate({bool isInstant = false}) async {
    if (state.expression.isEmpty) {
      if (isInstant) {
        state = state.copyWith(result: '');
      }
      return;
    }

    String expressionToParse = state.expression;
    expressionToParse = expressionToParse.replaceAll('Ans', state.ans);

    try {
      String finalResult = '';
      switch (state.mode) {
        case CalculatorMode.cas:
        case CalculatorMode.comp:
          JobType? casJobType;
          String expr = expressionToParse.trim();
          String? variable;
          
          if (expr.startsWith('simplify(') && expr.endsWith(')')) {
            expr = expr.substring(9, expr.length - 1).trim();
            casJobType = JobType.casSimplify;
          } else if (expr.startsWith('factor(') && expr.endsWith(')')) {
            expr = expr.substring(7, expr.length - 1).trim();
            casJobType = JobType.casFactor;
          } else if (expr.startsWith('diff(') && expr.endsWith(')')) {
            final inner = expr.substring(5, expr.length - 1).trim();
            final comma = inner.indexOf(',');
            if (comma != -1) {
              expr = inner.substring(0, comma).trim();
              variable = inner.substring(comma + 1).trim();
            } else {
              expr = inner;
              variable = 'x';
            }
            casJobType = JobType.casDiff;
          } else if (expr.startsWith('integrate(') && expr.endsWith(')')) {
            final inner = expr.substring(10, expr.length - 1).trim();
            final comma = inner.indexOf(',');
            if (comma != -1) {
              expr = inner.substring(0, comma).trim();
              variable = inner.substring(comma + 1).trim();
            } else {
              expr = inner;
              variable = 'x';
            }
            casJobType = JobType.casIntegrate;
          } else if (expr.startsWith('solve(') && expr.endsWith(')')) {
            final inner = expr.substring(6, expr.length - 1).trim();
            final comma = inner.indexOf(',');
            if (comma != -1) {
              expr = inner.substring(0, comma).trim();
              variable = inner.substring(comma + 1).trim();
            } else {
              expr = inner;
              variable = 'x';
            }
            casJobType = JobType.casSolve;
          }

          if (casJobType != null || state.mode == CalculatorMode.cas) {
            casJobType ??= JobType.casSimplify; // Default for CAS mode

            final jsCode = await CasEngine.getNerdamerCode();
            final job = CalculationJob(
              id: 'cas-job-${DateTime.now().millisecondsSinceEpoch}',
              type: casJobType,
              expression: expr,
              extra: {
                'jsCode': jsCode,
                if (variable != null) 'variable': variable,
              },
            );
            
            final result = await MathIsolate.executeJob(job);
            if (result.success) {
              finalResult = result.data.toString();
            } else {
              throw Exception(result.error);
            }
            break;
          }

          // If we reach here, it's COMP mode and NOT a CAS command.
          double val = MathParser.evaluate(expressionToParse, isDegree: state.angleMode == AngleMode.deg);
          finalResult = val.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
          break;

        case CalculatorMode.complex:
          // Standard evaluation on real/imaginary parts of string
          // For complex we'll look for custom strings like "2 + 3i"
          // We can parse real and imaginary parts using regex
          finalResult = _evaluateComplex(expressionToParse);
          break;

        case CalculatorMode.baseN:
          finalResult = _evaluateBaseN(expressionToParse);
          break;

        case CalculatorMode.equation:
          finalResult = _evaluateEquation(expressionToParse);
          break;

        case CalculatorMode.matrix:
          finalResult = _evaluateMatrix(expressionToParse);
          break;

        case CalculatorMode.vector:
          finalResult = _evaluateVector(expressionToParse);
          break;

        case CalculatorMode.statistics:
          finalResult = _evaluateStatistics(expressionToParse);
          break;

        case CalculatorMode.unitConverter:
          finalResult = 'Use converter utility screen.';
          break;

        case CalculatorMode.table:
          finalResult = 'Use table utility screen.';
          break;

        case CalculatorMode.graph:
          finalResult = 'Use graph utility screen.';
          break;
      }

      state = state.copyWith(
        result: finalResult,
        ans: isInstant ? state.ans : finalResult,
      );

      // Save to history offline if NOT in Exam Mode
      if (!state.isExamMode && !isInstant) {
        await DatabaseHelper.instance.insertHistory({
          'expression': state.expression,
          'result': finalResult,
          'mode': state.mode.toString().split('.').last.toUpperCase(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (!isInstant) {
        state = state.copyWith(result: 'Math ERROR');
      } else {
        state = state.copyWith(result: '');
      }
    }
  }

  String _evaluateComplex(String expr) {
    // Simple complex evaluation framework
    // e.g. "Conjg(2+3i)" or "(2+3i)*(1-i)"
    // We'll support standard operations on Complex representations
    // For MVP, if it parses as regular real/imag parts:
    if (expr.contains('Conjg')) {
      var match = RegExp(r'Conjg\(([^)]+)\)').firstMatch(expr);
      if (match != null) {
        var num = _parseComplexNumber(match.group(1)!);
        return num.conjugate.toRectString();
      }
    }

    var inverseTrigMatch = RegExp(r'(acos|asin|atan|arccos|arcsin|arctan|cos⁻¹|sin⁻¹|tan⁻¹)\(([^)]+)\)').firstMatch(expr);
    if (inverseTrigMatch != null) {
      String func = inverseTrigMatch.group(1)!;
      var num = _parseComplexNumber(inverseTrigMatch.group(2)!);
      Complex result;
      if (func == 'acos' || func == 'arccos' || func == 'cos⁻¹') result = num.acos();
      else if (func == 'asin' || func == 'arcsin' || func == 'sin⁻¹') result = num.asin();
      else result = num.atan();
      
      return state.complexFormat == ComplexFormat.polar ? result.toPolarString() : result.toRectString();
    }
    
    // Otherwise split by operators
    var parts = expr.split(RegExp(r'(?=[+\-*/])'));
    if (parts.length >= 2) {
      Complex first = _parseComplexNumber(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        String p = parts[i].trim();
        if (p.isEmpty) continue;
        String op = p.substring(0, 1);
        Complex second = _parseComplexNumber(p.substring(1));
        if (op == '+') first = first.add(second);
        if (op == '-') first = first.subtract(second);
        if (op == '*') first = first.multiply(second);
        if (op == '/') first = first.divide(second);
      }
      return first.toRectString();
    }
    return _parseComplexNumber(expr).toRectString();
  }

  Complex _parseComplexNumber(String s) {
    String clean = s.replaceAll(' ', '');
    if (clean.endsWith('i')) {
      if (clean == 'i') return Complex(0.0, 1.0);
      if (clean == '-i') return Complex(0.0, -1.0);
      var match = RegExp(r'^([+\-]?\d*\.?\d*)([+\-]\d*\.?\d*)i$').firstMatch(clean);
      if (match != null) {
        double r = double.tryParse(match.group(1)!) ?? 0.0;
        String imagStr = match.group(2)!;
        double img = imagStr == '+' ? 1.0 : (imagStr == '-' ? -1.0 : (double.tryParse(imagStr) ?? 0.0));
        return Complex(r, img);
      }
      var imagOnly = RegExp(r'^([+\-]?\d*\.?\d*)i$').firstMatch(clean);
      if (imagOnly != null) {
        double img = double.tryParse(imagOnly.group(1)!) ?? 1.0;
        return Complex(0.0, img);
      }
    }
    return Complex(double.tryParse(clean) ?? 0.0, 0.0);
  }

  String _evaluateBaseN(String expr) {
    // Format: "HEX:FF + DEC:10"
    // Support parsing Bin, Oct, Dec, Hex and computing
    var parts = expr.split('+');
    int sum = 0;
    for (var part in parts) {
      String clean = part.trim();
      if (clean.startsWith('0x') || clean.startsWith('HEX:')) {
        sum += int.parse(clean.replaceAll('0x', '').replaceAll('HEX:', ''), radix: 16);
      } else if (clean.startsWith('0b') || clean.startsWith('BIN:')) {
        sum += int.parse(clean.replaceAll('0b', '').replaceAll('BIN:', ''), radix: 2);
      } else if (clean.startsWith('0o') || clean.startsWith('OCT:')) {
        sum += int.parse(clean.replaceAll('0o', '').replaceAll('OCT:', ''), radix: 8);
      } else {
        sum += int.parse(clean.replaceAll('DEC:', ''));
      }
    }
    return sum.toString();
  }

  String _evaluateEquation(String expr) {
    // Standard quadratic: "a=1,b=-3,c=2"
    var pairs = expr.split(',');
    double a = 0.0, b = 0.0, c = 0.0;
    for (var pair in pairs) {
      var side = pair.split('=');
      if (side.length == 2) {
        double val = double.tryParse(side[1].trim()) ?? 0.0;
        if (side[0].trim() == 'a') a = val;
        if (side[0].trim() == 'b') b = val;
        if (side[0].trim() == 'c') c = val;
      }
    }
    var roots = EquationSolver.solveQuadratic(a, b, c);
    return roots.map((r) => r.toString()).join(", ");
  }

  String _evaluateMatrix(String expr) {
    // Simple mock operations on matrices: "Det([[1,2],[3,4]])"
    if (expr.startsWith('Det')) {
      var match = RegExp(r'Det\((.+)\)').firstMatch(expr);
      if (match != null) {
        var m = _parseMatrix(match.group(1)!);
        return m.determinant().toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
      }
    } else if (expr.startsWith('Inv')) {
      var match = RegExp(r'Inv\((.+)\)').firstMatch(expr);
      if (match != null) {
        var m = _parseMatrix(match.group(1)!);
        return m.inverse().toString();
      }
    }
    
    try {
      double result = MathParser.evaluate(expr);
      return result.toString().replaceAll(RegExp(r'\.?0+$'), '');
    } catch (e) {
      throw FormatException('Math ERROR');
    }
  }

  Matrix _parseMatrix(String s) {
    // Parses string representation of matrix e.g. "[[1,2],[3,4]]"
    String clean = s.replaceAll(' ', '');
    var rowsData = RegExp(r'\[([^\]]+)\]').allMatches(clean).map((m) {
      return m.group(1)!.split(',').map((e) => double.parse(e)).toList();
    }).toList();
    return Matrix(rowsData.length, rowsData[0].length, rowsData);
  }

  String _evaluateVector(String expr) {
    // Vector arithmetic e.g. "[1,2,3] . [4,5,6]"
    if (expr.contains('.')) {
      var parts = expr.split('.');
      var v1 = _parseVector(parts[0]);
      var v2 = _parseVector(parts[1]);
      return v1.dot(v2).toString();
    } else if (expr.contains('x')) {
      var parts = expr.split('x');
      var v1 = _parseVector(parts[0]);
      var v2 = _parseVector(parts[1]);
      return v1.cross(v2).toString();
    }
    return _parseVector(expr).toString();
  }

  Vector _parseVector(String s) {
    // Parses string e.g. "[1,2,3]"
    String clean = s.replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');
    var parts = clean.split(',').map((e) => double.parse(e)).toList();
    return Vector(parts);
  }

  String _evaluateStatistics(String expr) {
    // Mean of List: "Mean(1,2,3,4,5)"
    var match = RegExp(r'Mean\(([^)]+)\)').firstMatch(expr);
    if (match != null) {
      var vals = match.group(1)!.split(',').map((e) => double.parse(e.trim())).toList();
      double sum = vals.reduce((a, b) => a + b);
      return (sum / vals.length).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
    }
    return 'Stats Mode';
  }
}

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});
