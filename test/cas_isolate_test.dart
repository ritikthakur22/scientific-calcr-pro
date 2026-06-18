import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/execution/calculation_job.dart';
import 'package:scientific_calcr_pro/core/execution/math_isolate.dart';
import 'package:scientific_calcr_pro/core/cas_engine/cas_engine.dart';

void main() {
  group('CAS Engine Isolate Tests', () {
    late String jsCode;

    setUpAll(() async {
      jsCode = await CasEngine.getNerdamerCode();
      expect(jsCode, isNotEmpty);
    });

    test('CAS Simplify Job', () async {
      final job = CalculationJob(
        id: 'test-simp',
        type: JobType.casSimplify,
        expression: '(x^2 - 1)/(x - 1)',
        extra: {'jsCode': jsCode},
      );
      final result = await MathIsolate.executeJob(job);
      expect(result.error, isNull, reason: 'Isolate error: ${result.error}');
      expect(result.success, isTrue);
      // nerdamer.simplify('(x^2 - 1)/(x - 1)') -> 1+x
      expect(result.data.toString().replaceAll(' ', ''), '1+x');
    });

    test('CAS Factor Job', () async {
      final job = CalculationJob(
        id: 'test-factor',
        type: JobType.casFactor,
        expression: 'x^2 - 5*x + 6',
        extra: {'jsCode': jsCode},
      );
      final result = await MathIsolate.executeJob(job);
      expect(result.error, isNull, reason: 'Isolate error: ${result.error}');
      expect(result.success, isTrue);
      // nerdamer.factor('x^2 - 5*x + 6') -> (-2+x)*(-3+x)
      expect(result.data.toString().replaceAll(' ', ''), '(-2+x)*(-3+x)');
    });

    test('CAS Diff Job', () async {
      final job = CalculationJob(
        id: 'test-diff',
        type: JobType.casDiff,
        expression: 'x^3',
        extra: {'jsCode': jsCode, 'variable': 'x'},
      );
      final result = await MathIsolate.executeJob(job);
      expect(result.error, isNull, reason: 'Isolate error: ${result.error}');
      expect(result.success, isTrue);
      // d/dx [x^3] -> 3*x^2
      expect(result.data.toString().replaceAll(' ', ''), '3*x^2');
    });

    test('CAS Integrate Job', () async {
      final job = CalculationJob(
        id: 'test-integrate',
        type: JobType.casIntegrate,
        expression: '3*x^2',
        extra: {'jsCode': jsCode, 'variable': 'x'},
      );
      final result = await MathIsolate.executeJob(job);
      expect(result.error, isNull, reason: 'Isolate error: ${result.error}');
      expect(result.success, isTrue);
      // ∫ 3*x^2 dx -> x^3
      expect(result.data.toString().replaceAll(' ', ''), 'x^3');
    });

    test('CAS Solve Job', () async {
      final job = CalculationJob(
        id: 'test-solve',
        type: JobType.casSolve,
        expression: 'x^2 - 4 = 0',
        extra: {'jsCode': jsCode, 'variable': 'x'},
      );
      final result = await MathIsolate.executeJob(job);
      expect(result.error, isNull, reason: 'Isolate error: ${result.error}');
      expect(result.success, isTrue);
      // Solve x^2 - 4 = 0 -> [-2, 2] or [2, -2] or similar
      final solved = result.data.toString().replaceAll(' ', '');
      expect(solved, contains('2'));
      expect(solved, contains('-2'));
    });
  });
}
