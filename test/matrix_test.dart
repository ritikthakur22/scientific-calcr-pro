import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/core/math_engine/matrix_engine.dart';

void main() {
  group('Matrix Engine Tests', () {
    test('Matrix initialization and dimensions', () {
      final m = Matrix(2, 3, [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
      ]);
      expect(m.rows, 2);
      expect(m.cols, 3);
      expect(m.data[0][0], 1.0);
      expect(m.data[1][2], 6.0);

      // Dimension mismatch throws ArgumentError
      expect(() => Matrix(2, 2, [[1.0], [2.0]]), throwsArgumentError);
    });

    test('Matrix Zero and Identity factories', () {
      final z = Matrix.zero(3, 2);
      expect(z.rows, 3);
      expect(z.cols, 2);
      expect(z.data.every((row) => row.every((val) => val == 0.0)), true);

      final id = Matrix.identity(3);
      expect(id.rows, 3);
      expect(id.cols, 3);
      expect(id.data[0][0], 1.0);
      expect(id.data[1][1], 1.0);
      expect(id.data[2][2], 1.0);
      expect(id.data[0][1], 0.0);
    });

    test('Matrix addition and subtraction', () {
      final m1 = Matrix(2, 2, [[1.0, 2.0], [3.0, 4.0]]);
      final m2 = Matrix(2, 2, [[5.0, 6.0], [7.0, 8.0]]);

      final sum = m1.add(m2);
      expect(sum.data[0][0], 6.0);
      expect(sum.data[1][1], 12.0);

      final diff = m2.subtract(m1);
      expect(diff.data[0][0], 4.0);
      expect(diff.data[1][1], 4.0);

      // Dimension mismatch throws ArgumentError
      final m3 = Matrix(3, 2, [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]);
      expect(() => m1.add(m3), throwsArgumentError);
    });

    test('Matrix multiplication and scalar multiplication', () {
      final m1 = Matrix(2, 3, [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0]
      ]);
      final m2 = Matrix(3, 2, [
        [7.0, 8.0],
        [9.0, 10.0],
        [11.0, 12.0]
      ]);

      final prod = m1.multiply(m2);
      expect(prod.rows, 2);
      expect(prod.cols, 2);
      // Row 0: 1*7 + 2*9 + 3*11 = 7 + 18 + 33 = 58
      // Row 1: 4*8 + 5*10 + 6*12 = 32 + 50 + 72 = 154
      expect(prod.data[0][0], 58.0);
      expect(prod.data[0][1], 64.0);
      expect(prod.data[1][0], 139.0);
      expect(prod.data[1][1], 154.0);

      final scalar = m1.scalarMultiply(2.0);
      expect(scalar.data[0][0], 2.0);
      expect(scalar.data[1][2], 12.0);

      // Dimension mismatch throws ArgumentError
      expect(() => m1.multiply(m1), throwsArgumentError);
    });

    test('Matrix transpose', () {
      final m = Matrix(2, 3, [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0]
      ]);
      final t = m.transpose();
      expect(t.rows, 3);
      expect(t.cols, 2);
      expect(t.data[0][0], 1.0);
      expect(t.data[1][0], 2.0);
      expect(t.data[2][1], 6.0);
    });

    test('Matrix determinant for various sizes', () {
      final m1 = Matrix(1, 1, [[5.0]]);
      expect(m1.determinant(), 5.0);

      final m2 = Matrix(2, 2, [[1.0, 2.0], [3.0, 4.0]]);
      expect(m2.determinant(), -2.0);

      final m3 = Matrix(3, 3, [
        [6.0, 1.0, 1.0],
        [4.0, -2.0, 5.0],
        [2.0, 8.0, 7.0]
      ]);
      expect(m3.determinant(), -306.0);

      final m4 = Matrix(4, 4, [
        [4.0, 7.0, 2.0, 3.0],
        [1.0, 3.0, 1.0, 2.0],
        [2.0, 0.0, 4.0, 1.0],
        [0.0, 1.0, 3.0, 5.0]
      ]);
      expect(m4.determinant(), closeTo(49.0, 1e-9));

      final nonSquare = Matrix(2, 3, [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]);
      expect(() => nonSquare.determinant(), throwsArgumentError);
    });

    test('Matrix inverse and singular errors', () {
      final m = Matrix(3, 3, [
        [2.0, -1.0, 0.0],
        [-1.0, 2.0, -1.0],
        [0.0, -1.0, 2.0]
      ]);
      final inv = m.inverse();
      expect(inv.data[0][0], closeTo(0.75, 1e-9));
      expect(inv.data[1][1], closeTo(1.0, 1e-9));

      // singular matrix throws error
      final singular = Matrix(2, 2, [[1.0, 2.0], [2.0, 4.0]]);
      expect(() => singular.inverse(), throwsArgumentError);
      
      final nonSquare = Matrix(2, 3, [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]);
      expect(() => nonSquare.inverse(), throwsArgumentError);
    });

    test('Matrix rank computation', () {
      final m1 = Matrix(3, 3, [
        [1.0, 2.0, 3.0],
        [2.0, 4.0, 6.0],
        [3.0, 6.0, 9.0]
      ]);
      expect(m1.rank(), 1);

      final m2 = Matrix(3, 3, [
        [1.0, 2.0, 3.0],
        [0.0, 1.0, 4.0],
        [5.0, 6.0, 0.0]
      ]);
      expect(m2.rank(), 3);
    });
  });
}
