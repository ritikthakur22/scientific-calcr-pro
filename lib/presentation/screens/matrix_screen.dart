import 'package:flutter/material.dart';

class MatrixHelper {
  static double determinant(List<List<double>> m) {
    int n = m.length;
    if (n == 1) return m[0][0];
    if (n == 2) return m[0][0] * m[1][1] - m[0][1] * m[1][0];
    if (n == 3) {
      return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
          m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
          m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
    }
    if (n == 4) {
      double det = 0;
      for (int i = 0; i < 4; i++) {
        det += (i % 2 == 0 ? 1 : -1) * m[0][i] * determinant(minor(m, 0, i));
      }
      return det;
    }
    return 0;
  }

  static List<List<double>> minor(List<List<double>> m, int row, int col) {
    List<List<double>> res = [];
    for (int i = 0; i < m.length; i++) {
      if (i == row) continue;
      List<double> newRow = [];
      for (int j = 0; j < m[i].length; j++) {
        if (j == col) continue;
        newRow.add(m[i][j]);
      }
      res.add(newRow);
    }
    return res;
  }

  static List<List<double>>? inverse(List<List<double>> m) {
    double det = determinant(m);
    if (det == 0) return null;
    int n = m.length;
    if (n == 1) return [[1 / m[0][0]]];

    List<List<double>> adj = [];
    for (int i = 0; i < n; i++) {
      List<double> row = [];
      for (int j = 0; j < n; j++) {
        double sign = ((i + j) % 2 == 0) ? 1.0 : -1.0;
        row.add(sign * determinant(minor(m, i, j)));
      }
      adj.add(row);
    }
    adj = transpose(adj);

    List<List<double>> inv = [];
    for (int i = 0; i < n; i++) {
      List<double> row = [];
      for (int j = 0; j < n; j++) {
        row.add(adj[i][j] / det);
      }
      inv.add(row);
    }
    return inv;
  }

  static List<List<double>> transpose(List<List<double>> m) {
    int rows = m.length;
    int cols = m[0].length;
    List<List<double>> res = List.generate(cols, (_) => List.filled(rows, 0.0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        res[j][i] = m[i][j];
      }
    }
    return res;
  }

  static List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    int rows = a.length;
    int cols = a[0].length;
    List<List<double>> res = List.generate(rows, (_) => List.filled(cols, 0.0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        res[i][j] = a[i][j] + b[i][j];
      }
    }
    return res;
  }

  static List<List<double>> sub(List<List<double>> a, List<List<double>> b) {
    int rows = a.length;
    int cols = a[0].length;
    List<List<double>> res = List.generate(rows, (_) => List.filled(cols, 0.0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        res[i][j] = a[i][j] - b[i][j];
      }
    }
    return res;
  }

  static List<List<double>> multiply(List<List<double>> a, List<List<double>> b) {
    int r1 = a.length;
    int c1 = a[0].length;
    int c2 = b[0].length;
    List<List<double>> res = List.generate(r1, (_) => List.filled(c2, 0.0));
    for (int i = 0; i < r1; i++) {
      for (int j = 0; j < c2; j++) {
        double sum = 0;
        for (int k = 0; k < c1; k++) {
          sum += a[i][k] * b[k][j];
        }
        res[i][j] = sum;
      }
    }
    return res;
  }

  static int rank(List<List<double>> m) {
    int r = m.length;
    int c = m[0].length;
    List<List<double>> mat = m.map((row) => List<double>.from(row)).toList();
    int rank = 0;
    List<bool> rowSelected = List.filled(r, false);
    for (int i = 0; i < c; i++) {
      int j;
      for (j = 0; j < r; j++) {
        if (!rowSelected[j] && mat[j][i].abs() > 1e-9) {
          break;
        }
      }
      if (j != r) {
        rank++;
        rowSelected[j] = true;
        for (int p = i + 1; p < c; p++) {
          mat[j][p] /= mat[j][i];
        }
        for (int k = 0; k < r; k++) {
          if (k != j && mat[k][i].abs() > 1e-9) {
            for (int p = i + 1; p < c; p++) {
              mat[k][p] -= mat[j][p] * mat[k][i];
            }
          }
        }
      }
    }
    return rank;
  }
}

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  // We have 3 matrices A, B, C.
  Map<String, List<List<double>>> matrices = {
    'A': List.generate(2, (_) => List.filled(2, 0.0)),
    'B': List.generate(2, (_) => List.filled(2, 0.0)),
    'C': List.generate(2, (_) => List.filled(2, 0.0)),
  };

  // Dimensions for A, B, C. Stored as [rows, cols]
  Map<String, List<int>> dims = {
    'A': [2, 2],
    'B': [2, 2],
    'C': [2, 2],
  };

  String _currentMatrix = 'A';
  
  // Controllers to store text
  Map<String, List<List<TextEditingController>>> controllers = {};

  // String _resultText = '';
  Widget? _resultWidget;

  @override
  void initState() {
    super.initState();
    _initControllers('A');
    _initControllers('B');
    _initControllers('C');
  }

  void _initControllers(String matrixKey) {
    int r = dims[matrixKey]![0];
    int c = dims[matrixKey]![1];
    controllers[matrixKey] = List.generate(
      4,
      (i) => List.generate(4, (j) => TextEditingController(text: '0')),
    );
    for (int i = 0; i < r; i++) {
      for (int j = 0; j < c; j++) {
        controllers[matrixKey]![i][j].text = matrices[matrixKey]![i][j].toStringAsFixed(0);
      }
    }
  }

  void _updateMatrixSize(String matrixKey, int newR, int newC) {
    setState(() {
      dims[matrixKey] = [newR, newC];
      List<List<double>> newMat = List.generate(newR, (_) => List.filled(newC, 0.0));
      for (int i = 0; i < newR; i++) {
        for (int j = 0; j < newC; j++) {
          if (i < matrices[matrixKey]!.length && j < matrices[matrixKey]![0].length) {
            newMat[i][j] = matrices[matrixKey]![i][j];
          }
        }
      }
      matrices[matrixKey] = newMat;
      _initControllers(matrixKey);
    });
  }

  void _saveCurrentMatrix() {
    int r = dims[_currentMatrix]![0];
    int c = dims[_currentMatrix]![1];
    for (int i = 0; i < r; i++) {
      for (int j = 0; j < c; j++) {
        double val = double.tryParse(controllers[_currentMatrix]![i][j].text) ?? 0.0;
        matrices[_currentMatrix]![i][j] = val;
      }
    }
  }

  Widget _buildMatrixEditor() {
    int r = dims[_currentMatrix]![0];
    int c = dims[_currentMatrix]![1];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['A', 'B', 'C'].map((mName) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text('Mat $mName'),
                selected: _currentMatrix == mName,
                onSelected: (selected) {
                  if (selected) {
                    _saveCurrentMatrix();
                    setState(() {
                      _currentMatrix = mName;
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Rows: '),
            DropdownButton<int>(
              value: r,
              items: [1, 2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (v) {
                if (v != null) {
                  _saveCurrentMatrix();
                  _updateMatrixSize(_currentMatrix, v, c);
                }
              },
            ),
            const SizedBox(width: 20),
            const Text('Cols: '),
            DropdownButton<int>(
              value: c,
              items: [1, 2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (v) {
                if (v != null) {
                  _saveCurrentMatrix();
                  _updateMatrixSize(_currentMatrix, r, v);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(r, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(c, (j) {
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.all(4),
                    child: TextField(
                      controller: controllers[_currentMatrix]![i][j],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      ),
                      onChanged: (val) {
                         matrices[_currentMatrix]![i][j] = double.tryParse(val) ?? 0.0;
                      },
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    setState(() {
      _resultWidget = Text(message, style: const TextStyle(color: Colors.red, fontSize: 16));
    });
  }

  void _setResultMatrix(String title, List<List<double>> m) {
    setState(() {
      _resultWidget = Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildReadOnlyMatrix(m),
        ],
      );
    });
  }

  void _setResultScalar(String title, double val) {
    setState(() {
      String display = val.truncateToDouble() == val ? val.toInt().toString() : val.toStringAsFixed(4);
      _resultWidget = Text('$title = $display', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
    });
  }

  Widget _buildReadOnlyMatrix(List<List<double>> m) {
    int r = m.length;
    int c = m[0].length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.black, width: 2),
          right: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        children: List.generate(r, (i) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(c, (j) {
              double val = m[i][j];
              String display = val.truncateToDouble() == val ? val.toInt().toString() : val.toStringAsFixed(3);
              return Container(
                width: 50,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4),
                child: Text(display, style: const TextStyle(fontSize: 16)),
              );
            }),
          );
        }),
      ),
    );
  }

  void _handleOpSingle(String op) {
    _saveCurrentMatrix();
    var mat = matrices[_currentMatrix]!;
    int r = dims[_currentMatrix]![0];
    int c = dims[_currentMatrix]![1];

    if (op == 'Det') {
      if (r != c) {
        _showError('Determinant requires square matrix');
        return;
      }
      _setResultScalar('Det($_currentMatrix)', MatrixHelper.determinant(mat));
    } else if (op == 'Inv') {
      if (r != c) {
        _showError('Inverse requires square matrix');
        return;
      }
      var inv = MatrixHelper.inverse(mat);
      if (inv == null) {
        _showError('Matrix is singular (Det = 0)');
      } else {
        _setResultMatrix('Inv($_currentMatrix)', inv);
      }
    } else if (op == 'Tr') {
      _setResultMatrix('Transpose($_currentMatrix)', MatrixHelper.transpose(mat));
    } else if (op == 'Rank') {
      _setResultScalar('Rank($_currentMatrix)', MatrixHelper.rank(mat).toDouble());
    }
  }

  void _handleOpDouble(String op, String m1, String m2) {
    _saveCurrentMatrix();
    var mat1 = matrices[m1]!;
    var mat2 = matrices[m2]!;
    int r1 = dims[m1]![0];
    int c1 = dims[m1]![1];
    int r2 = dims[m2]![0];
    int c2 = dims[m2]![1];

    if (op == 'Add' || op == 'Sub') {
      if (r1 != r2 || c1 != c2) {
        _showError('Matrices must have same dimensions for $op');
        return;
      }
      if (op == 'Add') {
        _setResultMatrix('$m1 + $m2', MatrixHelper.add(mat1, mat2));
      } else {
        _setResultMatrix('$m1 - $m2', MatrixHelper.sub(mat1, mat2));
      }
    } else if (op == 'Mul') {
      if (c1 != r2) {
        _showError('Inner dimensions must match for multiplication (Cols of 1st == Rows of 2nd)');
        return;
      }
      _setResultMatrix('$m1 × $m2', MatrixHelper.multiply(mat1, mat2));
    }
  }

  Widget _buildOperations() {
    return Column(
      children: [
        const Text('Single Matrix Operations (on current)', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['Det', 'Inv', 'Tr', 'Rank'].map((op) {
            return ElevatedButton(
              onPressed: () => _handleOpSingle(op),
              child: Text(op),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        const Text('Two Matrix Operations', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(onPressed: () => _handleOpDouble('Add', 'A', 'B'), child: const Text('A + B')),
            ElevatedButton(onPressed: () => _handleOpDouble('Sub', 'A', 'B'), child: const Text('A - B')),
            ElevatedButton(onPressed: () => _handleOpDouble('Mul', 'A', 'B'), child: const Text('A × B')),
            ElevatedButton(onPressed: () => _handleOpDouble('Mul', 'B', 'A'), child: const Text('B × A')),
            ElevatedButton(onPressed: () => _handleOpDouble('Mul', 'A', 'C'), child: const Text('A × C')),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrix Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMatrixEditor(),
            const SizedBox(height: 20),
            _buildOperations(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Result:', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(minHeight: 100, minWidth: double.infinity),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: _resultWidget ?? const Text('No result yet'),
            ),
          ],
        ),
      ),
    );
  }
}
