import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/math_engine/math_parser.dart';
import 'package:scientific_calcr_pro/core/math_engine/matrix_engine.dart';
import 'package:scientific_calcr_pro/core/cas_engine/cas_engine.dart';
import 'package:scientific_calcr_pro/core/execution/calculation_job.dart';
import 'package:scientific_calcr_pro/core/execution/math_isolate.dart';

void main() {
  group('Stress and Crash Resistance Testing', () {
    late String jsCode;

    setUpAll(() async {
      jsCode = await CasEngine.getNerdamerCode();
    });

    // === CRASH RESISTANCE TESTS ===
    test('Crash Resistance: Division by Zero', () {
      expect(() => MathParser.evaluate('5 / 0'), throwsA(anything));
    });

    test('Crash Resistance: Invalid Expressions', () {
      expect(() => MathParser.evaluate('5 + * 3'), throwsA(anything));
      expect(() => MathParser.evaluate('(((5 + 3)'), throwsA(anything));
    });

    test('Crash Resistance: Malformed Matrices', () {
      expect(() => Matrix(2, 2, [[1.0]]), throwsA(anything));
    });

    test('Crash Resistance: Invalid CAS Syntax', () async {
      final job = CalculationJob(
        id: 'test-invalid-cas',
        type: JobType.casSimplify,
        expression: 'simplify(x^/2++)',
        extra: {'jsCode': jsCode},
      );
      final result = await MathIsolate.executeJob(job);
      // It should fail gracefully, NOT crash
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    // === STRESS TESTS ===
    test('Stress Test: Deeply Nested Fractions and Brackets', () {
      // Create a deeply nested expression: 1/(1/(1/(1/...)))
      String expr = '1';
      for (int i = 0; i < 40; i++) {
        expr = '1 / ($expr + 1)';
      }
      final stopwatch = Stopwatch()..start();
      final double val = MathParser.evaluate(expr);
      stopwatch.stop();
      
      expect(val, isNotNull);
      expect(val, isNonNegative);
      print('Deeply nested fraction evaluation time: ${stopwatch.elapsedMilliseconds} ms');
    });

    test('Stress Test: Large Matrix Operations (10x10 Matrix operations)', () {
      final rows = 10;
      final cols = 10;
      final List<List<double>> data = List.generate(
        rows,
        (i) => List.generate(cols, (j) => (i + j + 1).toDouble()),
      );
      final matA = Matrix(rows, cols, data);
      
      final stopwatch = Stopwatch()..start();
      final matTrans = matA.transpose();
      stopwatch.stop();
      
      expect(matTrans.rows, cols);
      expect(matTrans.cols, rows);
      print('10x10 Matrix Transpose time: ${stopwatch.elapsedMicroseconds} us');
    });

    test('Stress Test: CAS Evaluation Chains', () async {
      // Evaluate 100 CAS simplifying operations in sequence
      final stopwatch = Stopwatch()..start();
      for (int i = 1; i <= 100; i++) {
        final result = CasEngine.evaluateDirect(
          jsCode,
          "nerdamer.simplify('x + $i * x - x').toString()",
        );
        final expected = i == 1 ? 'x' : '${i}*x';
        expect(result.replaceAll(' ', ''), expected);
      }
      stopwatch.stop();
      print('100 CAS Chain evaluations time: ${stopwatch.elapsedMilliseconds} ms');
    });
  });
}
