import 'package:flutter/foundation.dart';
import 'calculation_job.dart';
import 'calculation_result.dart';
import '../math_engine/math_parser.dart';
import '../math_engine/equation_solver.dart';
import '../math_engine/matrix_engine.dart';
import '../cas_engine/cas_engine.dart';

class MathIsolate {
  static Future<CalculationResult> executeJob(CalculationJob job) async {
    final stopwatch = Stopwatch()..start();
    try {
      final data = await compute(_runJob, job);
      stopwatch.stop();
      return CalculationResult(
        jobId: job.id,
        success: true,
        data: data,
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      return CalculationResult(
        jobId: job.id,
        success: false,
        error: e.toString(),
        executionTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  static dynamic _runJob(CalculationJob job) {
    // Perform job calculation based on job.type
    // Bind variables if present
    job.variables.forEach((key, value) {
      MathParser.setVariable(key, value);
    });

    switch (job.type) {
      case JobType.casSimplify:
        final jsCode = job.extra['jsCode'] as String;
        final escaped = job.expression.replaceAll("'", "\\'");
        return CasEngine.evaluateDirect(jsCode, "nerdamer.simplify('$escaped').toString()");
      case JobType.casFactor:
        final jsCode = job.extra['jsCode'] as String;
        final escaped = job.expression.replaceAll("'", "\\'");
        return CasEngine.evaluateDirect(jsCode, "nerdamer.factor('$escaped').toString()");
      case JobType.casDiff:
        final jsCode = job.extra['jsCode'] as String;
        final escapedExpr = job.expression.replaceAll("'", "\\'");
        final variable = job.extra['variable'] as String? ?? 'x';
        final escapedVar = variable.replaceAll("'", "\\'");
        return CasEngine.evaluateDirect(jsCode, "nerdamer.diff('$escapedExpr', '$escapedVar').toString()");
      case JobType.casIntegrate:
        final jsCode = job.extra['jsCode'] as String;
        final escapedExpr = job.expression.replaceAll("'", "\\'");
        final variable = job.extra['variable'] as String? ?? 'x';
        final escapedVar = variable.replaceAll("'", "\\'");
        return CasEngine.evaluateDirect(jsCode, "nerdamer.integrate('$escapedExpr', '$escapedVar').toString()");
      case JobType.casSolve:
        final jsCode = job.extra['jsCode'] as String;
        final escapedExpr = job.expression.replaceAll("'", "\\'");
        final variable = job.extra['variable'] as String? ?? 'x';
        final escapedVar = variable.replaceAll("'", "\\'");
        return CasEngine.evaluateDirect(jsCode, "nerdamer.solve('$escapedExpr', '$escapedVar').toString()");
      case JobType.evaluate:
        return MathParser.evaluate(job.expression);
      case JobType.derivative:
        final varName = job.extra['variable'] as String? ?? 'X';
        final val = (job.extra['value'] as num).toDouble();
        return MathParser.numericalDerivative(job.expression, varName, val);
      case JobType.integral:
        final varName = job.extra['variable'] as String? ?? 'X';
        final lower = (job.extra['lower'] as num).toDouble();
        final upper = (job.extra['upper'] as num).toDouble();
        return MathParser.numericalIntegral(job.expression, varName, lower, upper);
      case JobType.solveLinear:
        final coefficients = (job.extra['coefficients'] as List).map(
          (row) => (row as List).map((val) => (val as num).toDouble()).toList()
        ).toList();
        final constants = (job.extra['constants'] as List).map((val) => (val as num).toDouble()).toList();
        return EquationSolver.solveLinearSystem(coefficients, constants);
      case JobType.solveQuadratic:
        final a = (job.extra['a'] as num).toDouble();
        final b = (job.extra['b'] as num).toDouble();
        final c = (job.extra['c'] as num).toDouble();
        final roots = EquationSolver.solveQuadratic(a, b, c);
        return roots.map((r) => {'real': r.real, 'imaginary': r.imaginary}).toList();
      case JobType.solveCubic:
        final a = (job.extra['a'] as num).toDouble();
        final b = (job.extra['b'] as num).toDouble();
        final c = (job.extra['c'] as num).toDouble();
        final d = (job.extra['d'] as num).toDouble();
        final roots = EquationSolver.solveCubic(a, b, c, d);
        return roots.map((r) => {'real': r.real, 'imaginary': r.imaginary}).toList();
      case JobType.solveQuartic:
        final a = (job.extra['a'] as num).toDouble();
        final b = (job.extra['b'] as num).toDouble();
        final c = (job.extra['c'] as num).toDouble();
        final d = (job.extra['d'] as num).toDouble();
        final e = (job.extra['e'] as num).toDouble();
        final roots = EquationSolver.solveQuartic(a, b, c, d, e);
        return roots.map((r) => {'real': r.real, 'imaginary': r.imaginary}).toList();
      case JobType.matrixDet:
        final data = (job.extra['data'] as List).map(
          (row) => (row as List).map((val) => (val as num).toDouble()).toList()
        ).toList();
        final rows = job.extra['rows'] as int;
        final cols = job.extra['cols'] as int;
        return Matrix(rows, cols, data).determinant();
      case JobType.matrixInv:
        final data = (job.extra['data'] as List).map(
          (row) => (row as List).map((val) => (val as num).toDouble()).toList()
        ).toList();
        final rows = job.extra['rows'] as int;
        final cols = job.extra['cols'] as int;
        final inv = Matrix(rows, cols, data).inverse();
        return inv.data;
      case JobType.matrixRank:
        final data = (job.extra['data'] as List).map(
          (row) => (row as List).map((rowVal) => (rowVal as num).toDouble()).toList()
        ).toList();
        final rows = job.extra['rows'] as int;
        final cols = job.extra['cols'] as int;
        return Matrix(rows, cols, data).rank();
      case JobType.matrixMul:
        final dataA = (job.extra['dataA'] as List).map(
          (row) => (row as List).map((val) => (val as num).toDouble()).toList()
        ).toList();
        final rowsA = job.extra['rowsA'] as int;
        final colsA = job.extra['colsA'] as int;
        final dataB = (job.extra['dataB'] as List).map(
          (row) => (row as List).map((val) => (val as num).toDouble()).toList()
        ).toList();
        final rowsB = job.extra['rowsB'] as int;
        final colsB = job.extra['colsB'] as int;
        final product = Matrix(rowsA, colsA, dataA).multiply(Matrix(rowsB, colsB, dataB));
        return product.data;
    }
  }
}
