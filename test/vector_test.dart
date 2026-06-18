import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/math_engine/vector_engine.dart';
import 'dart:math' as math;

void main() {
  group('Vector Engine Tests', () {
    test('Vector initialization and dimension verification', () {
      final v2 = Vector([3.0, 4.0]);
      expect(v2.dimension, 2);
      expect(v2.dx, 3.0);
      expect(v2.dy, 4.0);
      expect(v2.dz, 0.0);

      final v3 = Vector([1.0, 2.0, 3.0]);
      expect(v3.dimension, 3);
      expect(v3.dx, 1.0);
      expect(v3.dy, 2.0);
      expect(v3.dz, 3.0);

      // Dimension mismatch throws ArgumentError
      expect(() => Vector([1.0]), throwsArgumentError);
      expect(() => Vector([1.0, 2.0, 3.0, 4.0]), throwsArgumentError);
    });

    test('Vector magnitude and unit vector', () {
      final v = Vector([3.0, 4.0]);
      expect(v.magnitude(), 5.0);

      final unit = v.unit();
      expect(unit.dx, 0.6);
      expect(unit.dy, 0.8);

      final zero = Vector([0.0, 0.0]);
      expect(() => zero.unit(), throwsArgumentError);
    });

    test('Vector dot and cross products', () {
      final v1 = Vector([1.0, 2.0, 3.0]);
      final v2 = Vector([4.0, 5.0, 6.0]);

      // Dot product: 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
      expect(v1.dot(v2), 32.0);

      // Cross product: (2*6 - 3*5)i + (3*4 - 1*6)j + (1*5 - 2*4)k
      // = (12 - 15)i + (12 - 6)j + (5 - 8)k = -3i + 6j - 3k
      final cross = v1.cross(v2);
      expect(cross.dx, -3.0);
      expect(cross.dy, 6.0);
      expect(cross.dz, -3.0);

      // Dimension mismatch in cross product or dot product throws
      final v2d = Vector([1.0, 2.0]);
      expect(() => v1.dot(v2d), throwsArgumentError);
      expect(() => v2d.cross(v1), throwsArgumentError);
    });

    test('Vector angle calculations', () {
      final v1 = Vector([1.0, 0.0]);
      final v2 = Vector([0.0, 1.0]);
      expect(v1.angleBetween(v2), math.pi / 2);

      final v3 = Vector([2.0, 0.0]);
      expect(v1.angleBetween(v3), 0.0);

      final zero = Vector([0.0, 0.0]);
      expect(v1.angleBetween(zero), 0.0);

      // Dimension mismatch throws
      final v3d = Vector([1.0, 0.0, 0.0]);
      expect(() => v1.angleBetween(v3d), throwsArgumentError);
    });

    test('Vector arithmetic operations', () {
      final v1 = Vector([1.0, 2.0]);
      final v2 = Vector([3.0, 4.0]);

      final sum = v1.add(v2);
      expect(sum.dx, 4.0);
      expect(sum.dy, 6.0);

      final diff = v2.subtract(v1);
      expect(diff.dx, 2.0);
      expect(diff.dy, 2.0);

      final scaled = v1.scale(2.5);
      expect(scaled.dx, 2.5);
      expect(scaled.dy, 5.0);

      // Dimension mismatch throws
      final v3 = Vector([1.0, 2.0, 3.0]);
      expect(() => v1.add(v3), throwsArgumentError);
      expect(() => v1.subtract(v3), throwsArgumentError);
    });
  });
}
