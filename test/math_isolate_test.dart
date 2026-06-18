import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/execution/math_isolate.dart';
import 'package:scientific_calcr_pro/core/execution/calculation_job.dart';
import 'package:scientific_calcr_pro/core/math_engine/math_parser.dart';

void main() {
  group('Math Isolate Tests', () {
    test('Offload evaluation, derivative, and integral to isolate', () async {
      final job1 = CalculationJob(
        id: 'job-1',
        type: JobType.evaluate,
        expression: '2 * sin(pi / 4) + ln(e^3) - 5^2',
      );
      final res1 = await MathIsolate.executeJob(job1);
      expect(res1.success, true);
      expect(res1.data, closeTo(2.0 * 0.70710678 + 3.0 - 25.0, 1e-4));

      final job2 = CalculationJob(
        id: 'job-2',
        type: JobType.derivative,
        expression: 'X^2',
        extra: {'variable': 'X', 'value': 3.0},
      );
      final res2 = await MathIsolate.executeJob(job2);
      expect(res2.success, true);
      expect(res2.data, closeTo(6.0, 1e-4));

      final job3 = CalculationJob(
        id: 'job-3',
        type: JobType.integral,
        expression: 'X',
        extra: {'variable': 'X', 'lower': 0.0, 'upper': 2.0},
      );
      final res3 = await MathIsolate.executeJob(job3);
      expect(res3.success, true);
      expect(res3.data, closeTo(2.0, 1e-4));
    });

    test('Offload equation solving and matrix operations', () async {
      // solveLinear
      final job1 = CalculationJob(
        id: 'linear',
        type: JobType.solveLinear,
        extra: {
          'coefficients': [[2.0, 1.0], [1.0, -1.0]],
          'constants': [5.0, 1.0]
        }
      );
      final res1 = await MathIsolate.executeJob(job1);
      expect(res1.success, true);
      expect(res1.data[0], closeTo(2.0, 1e-9));

      // solveQuadratic
      final job2 = CalculationJob(
        id: 'quad',
        type: JobType.solveQuadratic,
        extra: {'a': 1.0, 'b': -5.0, 'c': 6.0}
      );
      final res2 = await MathIsolate.executeJob(job2);
      expect(res2.success, true);
      expect(res2.data[0]['real'], closeTo(3.0, 1e-9));

      // solveCubic
      final job3 = CalculationJob(
        id: 'cubic',
        type: JobType.solveCubic,
        extra: {'a': 1.0, 'b': -6.0, 'c': 11.0, 'd': -6.0}
      );
      final res3 = await MathIsolate.executeJob(job3);
      expect(res3.success, true);

      // solveQuartic
      final job4 = CalculationJob(
        id: 'quartic',
        type: JobType.solveQuartic,
        extra: {'a': 1.0, 'b': -10.0, 'c': 35.0, 'd': -50.0, 'e': 24.0}
      );
      final res4 = await MathIsolate.executeJob(job4);
      expect(res4.success, true);

      // matrixDet
      final job5 = CalculationJob(
        id: 'det',
        type: JobType.matrixDet,
        extra: {
          'data': [[1.0, 2.0], [3.0, 4.0]],
          'rows': 2,
          'cols': 2
        }
      );
      final res5 = await MathIsolate.executeJob(job5);
      expect(res5.success, true);
      expect(res5.data, -2.0);

      // matrixInv
      final job6 = CalculationJob(
        id: 'inv',
        type: JobType.matrixInv,
        extra: {
          'data': [[1.0, 2.0], [3.0, 4.0]],
          'rows': 2,
          'cols': 2
        }
      );
      final res6 = await MathIsolate.executeJob(job6);
      expect(res6.success, true);

      // matrixRank
      final job7 = CalculationJob(
        id: 'rank',
        type: JobType.matrixRank,
        extra: {
          'data': [[1.0, 2.0], [2.0, 4.0]],
          'rows': 2,
          'cols': 2
        }
      );
      final res7 = await MathIsolate.executeJob(job7);
      expect(res7.success, true);
      expect(res7.data, 1);

      // matrixMul
      final job8 = CalculationJob(
        id: 'mul',
        type: JobType.matrixMul,
        extra: {
          'dataA': [[1.0, 2.0]], 'rowsA': 1, 'colsA': 2,
          'dataB': [[3.0], [4.0]], 'rowsB': 2, 'colsB': 1
        }
      );
      final res8 = await MathIsolate.executeJob(job8);
      expect(res8.success, true);
      expect(res8.data[0][0], 11.0);
    });

    test('Error handling in isolate job execution', () async {
      final job = CalculationJob(
        id: 'err',
        type: JobType.evaluate,
        expression: '1 / 0',
      );
      final res = await MathIsolate.executeJob(job);
      expect(res.success, false);
      expect(res.error, contains('Math Error'));
    });

    test('Isolate Benchmark vs Main Thread Benchmark', () async {
      const String heavyExpr = 'sin(X) * cos(X) * X^2';
      
      // 1. Main Thread Benchmark
      final mainWatch = Stopwatch()..start();
      for (int i = 0; i < 20; i++) {
        MathParser.numericalIntegral(heavyExpr, 'X', 0.0, 10.0);
      }
      mainWatch.stop();
      final double mainTimeMs = mainWatch.elapsedMilliseconds.toDouble() / 20;

      // 2. Isolate Benchmark
      final isoWatch = Stopwatch()..start();
      for (int i = 0; i < 20; i++) {
        final job = CalculationJob(
          id: 'job-iso-$i',
          type: JobType.integral,
          expression: heavyExpr,
          extra: {'variable': 'X', 'lower': 0.0, 'upper': 10.0},
        );
        final res = await MathIsolate.executeJob(job);
        expect(res.success, true);
      }
      isoWatch.stop();
      final double isoTimeMs = isoWatch.elapsedMilliseconds.toDouble() / 20;

      print("BENCHMARK_RESULT: Heavy calculation main thread avg = ${mainTimeMs.toStringAsFixed(2)} ms");
      print("BENCHMARK_RESULT: Heavy calculation isolate avg = ${isoTimeMs.toStringAsFixed(2)} ms");
    });
  });
}
