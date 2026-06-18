import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

class MathParser {
  static final Parser _parser = Parser();
  static final Map<String, double> _variables = {
    'A': 0.0,
    'B': 0.0,
    'C': 0.0,
    'D': 0.0,
    'X': 0.0,
    'Y': 0.0,
    'M': 0.0,
  };

  static double getVariable(String name) => _variables[name] ?? 0.0;
  static void setVariable(String name, double value) {
    if (_variables.containsKey(name)) {
      _variables[name] = value;
    }
  }

  /// Evaluates standard real-value mathematical expressions.
  /// Handles implicit multiplication and Casio-specific tokens.
  static double evaluate(String expression, {bool isDegree = false}) {
    String preprocessed = _preprocess(expression, isDegree: isDegree);
    print("PREPROCESSED: '$expression' -> '$preprocessed'");
    try {
      Expression exp = _parser.parse(preprocessed);
      ContextModel cm = ContextModel();
      _variables.forEach((key, value) {
        cm.bindVariable(Variable(key), Number(value));
      });
      // Bind standard math constants
      cm.bindVariable(Variable('pi'), Number(math.pi));
      cm.bindVariable(Variable('e'), Number(math.e));
      cm.bindVariable(Variable('E'), Number(math.e));

      double result = exp.evaluate(EvaluationType.REAL, cm);
      if (result.isNaN || result.isInfinite) {
        throw ArgumentError("Math Error: Division by zero or out of domain.");
      }
      return result;
    } on ArgumentError {
      rethrow;
    } catch (e) {
      throw FormatException("Syntax Error in expression.");
    }
  }

  /// Run numerical differentiation: d/dx f(x) at x=val
  static double numericalDerivative(String expression, String variableName, double val) {
    double h = 1e-6;
    double f(double x) {
      setVariable(variableName, x);
      return evaluate(expression);
    }
    // Centered difference formula
    return (f(val + h) - f(val - h)) / (2 * h);
  }

  /// Run numerical integration: Integral of f(x) from [lower] to [upper]
  /// Uses Simpson's 3/8 Rule
  static double numericalIntegral(String expression, String variableName, double lower, double upper) {
    int intervals = 300; // Must be divisible by 3 for Simpson's 3/8
    double h = (upper - lower) / intervals;
    
    double f(double x) {
      setVariable(variableName, x);
      return evaluate(expression);
    }

    double sum = f(lower) + f(upper);
    for (int i = 1; i < intervals; i++) {
      double x = lower + i * h;
      if (i % 3 == 0) {
        sum += 2 * f(x);
      } else {
        sum += 3 * f(x);
      }
    }
    return (3 * h / 8) * sum;
  }

  /// Preprocesses Casio calculator expressions to standard mathematical syntax.
  static String _preprocess(String expr, {bool isDegree = false}) {
    String processed = expr;

    // Replace nth_root and cbrt
    processed = processed.replaceAllMapped(RegExp(r'nth_root\(([^,]+),\s*(.+)\)'), (m) => '(sgn(${m.group(2)})*abs(${m.group(2)})^(1/(${m.group(1)})))');
    processed = processed.replaceAllMapped(RegExp(r'cbrt\((.+)\)'), (m) => '(sgn(${m.group(1)})*abs(${m.group(1)})^(1/3))');

    // Handle custom inverse trig unicode functions from keyboard
    processed = processed.replaceAll('sin⁻¹', 'arcsin')
                         .replaceAll('cos⁻¹', 'arccos')
                         .replaceAll('tan⁻¹', 'arctan');

    // Handle hyperbolic functions
    processed = _replaceFunc(processed, 'sinh', (x) => '((e^($x) - e^(-($x))) / 2)');
    processed = _replaceFunc(processed, 'cosh', (x) => '((e^($x) + e^(-($x))) / 2)');
    processed = _replaceFunc(processed, 'tanh', (x) => '((e^($x) - e^(-($x))) / (e^($x) + e^(-($x))))');
    processed = _replaceFunc(processed, 'sinh⁻¹', (x) => 'ln($x + sqrt(($x)^2 + 1))');
    processed = _replaceFunc(processed, 'cosh⁻¹', (x) => 'ln($x + sqrt(($x)^2 - 1))');
    processed = _replaceFunc(processed, 'tanh⁻¹', (x) => '(0.5 * ln((1 + ($x)) / (1 - ($x))))');

    // Handle logarithms
    // log_base(x, y) from keypad becomes math_expressions log(x, y)
    // regular log(x) from keypad becomes math_expressions log(10, x)
    processed = processed.replaceAll('log(', 'log10_temp(');
    processed = processed.replaceAll('log_base(', 'log(');
    processed = processed.replaceAll('log10_temp(', 'log(10,');

    // Evaluate innermost integrals until none remain
    final RegExp intExp = RegExp(r'INT_EVALµ([^µ]*)µ([^µ]*)µ([^µ]*)µ');
    while (intExp.hasMatch(processed)) {
      processed = processed.replaceAllMapped(intExp, (m) {
        String body = m.group(1)!;
        double l = evaluate(m.group(2)!, isDegree: isDegree);
        double u = evaluate(m.group(3)!, isDegree: isDegree);
        double res = numericalIntegral(body, 'x', l, u);
        return res.toString();
      });
    }

    if (isDegree) {
      // Very simple regex replacement for trig degree mode.
      // This won't perfectly handle deeply nested same-functions without balanced matching, 
      // but works for basic sequential usage like sin(30) + cos(60)
      
      // Instead of regex, we'll inject conversions directly into the parser string:
      processed = processed.replaceAllMapped(RegExp(r'\b(sin|cos|tan)\('), (m) => '${m.group(1)}((pi/180)*');
      processed = processed.replaceAllMapped(RegExp(r'\b(arcsin|arccos|arctan)\('), (m) => '(180/pi)*${m.group(1)}(');
    }

    // Convert curly/square brackets to standard parentheses
    processed = processed.replaceAll('{', '(').replaceAll('}', ')');
    processed = processed.replaceAll('[', '(').replaceAll(']', ')');

    // Replace scientific symbols
    processed = processed.replaceAll('×', '*').replaceAll('÷', '/');
    processed = processed.replaceAll('π', 'pi');

    // Replace standalone e with E (not adjacent to other letters)
    processed = processed.replaceAllMapped(RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z])'), (m) => 'E');

    // Define left-hand side of implicit multiplication:
    // - a number: \d+(?:\.\d+)?
    // - pi: (?<![a-zA-Z])pi
    // - E: (?<![a-zA-Z])E
    // - single-letter variable: (?<![a-zA-Z])[A-DXYZM]
    // - a closing parenthesis: \)
    const lhs = r'(?:\d+(?:\.\d+)?|(?<![a-zA-Z])pi|(?<![a-zA-Z])E|(?<![a-zA-Z])[A-DXYZM]|\))';

    // Define right-hand side of implicit multiplication:
    // - any word starting with a letter (e.g. sin, cos, x, y, pi, E)
    // - an opening parenthesis: \(
    const rhs = r'(?:[a-zA-Z]+|\()';

    final implicitPattern = RegExp('($lhs)\\s*($rhs)');

    // Loop to handle all occurrences
    while (implicitPattern.hasMatch(processed)) {
      processed = processed.replaceAllMapped(implicitPattern, (m) {
        return '${m.group(1)}*${m.group(2)}';
      });
    }

    return processed;
  }

  /// Helper to replace function calls like func(x) with balanced parentheses
  static String _replaceFunc(String expr, String funcName, String Function(String) replacement) {
    String res = expr;
    int idx = 0;
    while ((idx = res.indexOf('$funcName(', idx)) != -1) {
      int start = idx + funcName.length + 1;
      int end = start;
      int depth = 1;
      while (end < res.length && depth > 0) {
        if (res[end] == '(') depth++;
        if (res[end] == ')') depth--;
        end++;
      }
      if (depth == 0) {
        String inner = res.substring(start, end - 1);
        String rep = replacement(inner);
        res = res.substring(0, idx) + rep + res.substring(end);
        idx += rep.length;
      } else {
        idx++; // Unbalanced, just skip
      }
    }
    return res;
  }
}
