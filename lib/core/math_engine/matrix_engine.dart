
class Matrix {
  final int rows;
  final int cols;
  final List<List<double>> data;

  Matrix(this.rows, this.cols, this.data) {
    if (data.length != rows || data.any((row) => row.length != cols)) {
      throw ArgumentError("Matrix dimensions do not match data dimensions.");
    }
  }

  factory Matrix.zero(int rows, int cols) {
    return Matrix(
      rows,
      cols,
      List.generate(rows, (_) => List.filled(cols, 0.0)),
    );
  }

  factory Matrix.identity(int size) {
    var m = Matrix.zero(size, size);
    for (int i = 0; i < size; i++) {
      m.data[i][i] = 1.0;
    }
    return m;
  }

  Matrix add(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw ArgumentError("Matrices must have the same dimensions for addition.");
    }
    var result = Matrix.zero(rows, cols);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result.data[r][c] = data[r][c] + other.data[r][c];
      }
    }
    return result;
  }

  Matrix subtract(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw ArgumentError("Matrices must have the same dimensions for subtraction.");
    }
    var result = Matrix.zero(rows, cols);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result.data[r][c] = data[r][c] - other.data[r][c];
      }
    }
    return result;
  }

  Matrix multiply(Matrix other) {
    if (cols != other.rows) {
      throw ArgumentError("Inner dimensions must match for matrix multiplication.");
    }
    var result = Matrix.zero(rows, other.cols);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < other.cols; c++) {
        double sum = 0.0;
        for (int k = 0; k < cols; k++) {
          sum += data[r][k] * other.data[k][c];
        }
        result.data[r][c] = sum;
      }
    }
    return result;
  }

  Matrix scalarMultiply(double scalar) {
    var result = Matrix.zero(rows, cols);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result.data[r][c] = data[r][c] * scalar;
      }
    }
    return result;
  }

  Matrix transpose() {
    var result = Matrix.zero(cols, rows);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result.data[c][r] = data[r][c];
      }
    }
    return result;
  }

  double determinant() {
    if (rows != cols) {
      throw ArgumentError("Determinant is only defined for square matrices.");
    }
    if (rows == 1) return data[0][0];
    if (rows == 2) return data[0][0] * data[1][1] - data[0][1] * data[1][0];
    if (rows == 3) {
      return data[0][0] * (data[1][1] * data[2][2] - data[1][2] * data[2][1]) -
             data[0][1] * (data[1][0] * data[2][2] - data[1][2] * data[2][0]) +
             data[0][2] * (data[1][0] * data[2][1] - data[1][1] * data[2][0]);
    }
    // General determinant using Gaussian elimination / LU Decomposition
    return _luDeterminant();
  }

  double _luDeterminant() {
    var m = _copyData();
    double det = 1.0;
    for (int i = 0; i < rows; i++) {
      int pivot = i;
      for (int j = i + 1; j < rows; j++) {
        if (m[j][i].abs() > m[pivot][i].abs()) {
          pivot = j;
        }
      }
      if (pivot != i) {
        var temp = m[i];
        m[i] = m[pivot];
        m[pivot] = temp;
        det *= -1.0;
      }
      if (m[i][i].abs() < 1e-12) return 0.0;
      det *= m[i][i];
      for (int j = i + 1; j < rows; j++) {
        double factor = m[j][i] / m[i][i];
        for (int k = i; k < rows; k++) {
          m[j][k] -= factor * m[i][k];
        }
      }
    }
    return det;
  }

  Matrix inverse() {
    if (rows != cols) {
      throw ArgumentError("Inverse is only defined for square matrices.");
    }
    int n = rows;
    var m = _copyData();
    var inv = Matrix.identity(n).data;

    for (int i = 0; i < n; i++) {
      int pivot = i;
      for (int j = i + 1; j < n; j++) {
        if (m[j][i].abs() > m[pivot][i].abs()) {
          pivot = j;
        }
      }
      if (pivot != i) {
        var tempM = m[i];
        m[i] = m[pivot];
        m[pivot] = tempM;

        var tempI = inv[i];
        inv[i] = inv[pivot];
        inv[pivot] = tempI;
      }
      if (m[i][i].abs() < 1e-12) {
        throw ArgumentError("Matrix is singular and cannot be inverted.");
      }
      double pivotVal = m[i][i];
      for (int j = 0; j < n; j++) {
        m[i][j] /= pivotVal;
        inv[i][j] /= pivotVal;
      }
      for (int j = 0; j < n; j++) {
        if (j != i) {
          double factor = m[j][i];
          for (int k = 0; k < n; k++) {
            m[j][k] -= factor * m[i][k];
            inv[j][k] -= factor * inv[i][k];
          }
        }
      }
    }
    return Matrix(n, n, inv);
  }

  int rank() {
    var m = _copyData();
    int r = 0;
    int c = 0;
    while (r < rows && c < cols) {
      int pivot = r;
      for (int i = r + 1; i < rows; i++) {
        if (m[i][c].abs() > m[pivot][c].abs()) {
          pivot = i;
        }
      }
      if (m[pivot][c].abs() < 1e-12) {
        c++;
      } else {
        if (pivot != r) {
          var temp = m[r];
          m[r] = m[pivot];
          m[pivot] = temp;
        }
        for (int i = r + 1; i < rows; i++) {
          double factor = m[i][c] / m[r][c];
          for (int j = c; j < cols; j++) {
            m[i][j] -= factor * m[r][j];
          }
        }
        r++;
        c++;
      }
    }
    return r;
  }

  List<List<double>> _copyData() {
    return List.generate(rows, (r) => List<double>.from(data[r]));
  }

  @override
  String toString() {
    return data.map((row) => '[${row.map((val) => val.toStringAsFixed(4)).join(", ")}]').join("\n");
  }
}
