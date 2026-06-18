import 'package:flutter/material.dart';
import '../../core/math_engine/equation_solver.dart';

enum EquationType {
  linear2,
  linear3,
  quadratic,
  cubic,
  quartic,
}

class EquationScreen extends StatefulWidget {
  const EquationScreen({super.key});

  @override
  State<EquationScreen> createState() => _EquationScreenState();
}

class _EquationScreenState extends State<EquationScreen> {
  EquationType _selectedType = EquationType.quadratic;
  
  // Controllers for coefficients
  // For linear 2: a1, b1, c1, a2, b2, c2 (6)
  // For linear 3: a1..d1, a2..d2, a3..d3 (12)
  // For quadratic: a, b, c (3)
  // For cubic: a, b, c, d (4)
  // For quartic: a, b, c, d, e (5)
  final Map<String, TextEditingController> _controllers = {};
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _controllers.clear();
    _results.clear();
    List<String> keys = [];
    switch (_selectedType) {
      case EquationType.linear2:
        keys = ['a1', 'b1', 'c1', 'a2', 'b2', 'c2'];
        break;
      case EquationType.linear3:
        keys = ['a1', 'b1', 'c1', 'd1', 'a2', 'b2', 'c2', 'd2', 'a3', 'b3', 'c3', 'd3'];
        break;
      case EquationType.quadratic:
        keys = ['a', 'b', 'c'];
        break;
      case EquationType.cubic:
        keys = ['a', 'b', 'c', 'd'];
        break;
      case EquationType.quartic:
        keys = ['a', 'b', 'c', 'd', 'e'];
        break;
    }
    for (var key in keys) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _getVal(String key) {
    return double.tryParse(_controllers[key]?.text ?? '') ?? 0.0;
  }

  void _solve() {
    FocusScope.of(context).unfocus(); // hide keyboard
    setState(() {
      try {
        switch (_selectedType) {
          case EquationType.linear2:
            var a1 = _getVal('a1'), b1 = _getVal('b1'), c1 = _getVal('c1');
            var a2 = _getVal('a2'), b2 = _getVal('b2'), c2 = _getVal('c2');
            var res = EquationSolver.solveLinearSystem(
              [[a1, b1], [a2, b2]],
              [c1, c2],
            );
            _results = [
              'x = ${res[0].toStringAsFixed(4).replaceAll(RegExp(r'\\.?0+\$'), '')}',
              'y = ${res[1].toStringAsFixed(4).replaceAll(RegExp(r'\\.?0+\$'), '')}',
            ];
            break;
          case EquationType.linear3:
            var a1 = _getVal('a1'), b1 = _getVal('b1'), c1 = _getVal('c1'), d1 = _getVal('d1');
            var a2 = _getVal('a2'), b2 = _getVal('b2'), c2 = _getVal('c2'), d2 = _getVal('d2');
            var a3 = _getVal('a3'), b3 = _getVal('b3'), c3 = _getVal('c3'), d3 = _getVal('d3');
            var res = EquationSolver.solveLinearSystem(
              [[a1, b1, c1], [a2, b2, c2], [a3, b3, c3]],
              [d1, d2, d3],
            );
            _results = [
              'x = ${res[0].toStringAsFixed(4).replaceAll(RegExp(r'\\.?0+\$'), '')}',
              'y = ${res[1].toStringAsFixed(4).replaceAll(RegExp(r'\\.?0+\$'), '')}',
              'z = ${res[2].toStringAsFixed(4).replaceAll(RegExp(r'\\.?0+\$'), '')}',
            ];
            break;
          case EquationType.quadratic:
            var a = _getVal('a'), b = _getVal('b'), c = _getVal('c');
            var res = EquationSolver.solveQuadratic(a, b, c);
            _results = res.asMap().entries.map((e) => 'x${e.key + 1} = ${e.value.toRectString(precision: 4)}').toList();
            break;
          case EquationType.cubic:
            var a = _getVal('a'), b = _getVal('b'), c = _getVal('c'), d = _getVal('d');
            var res = EquationSolver.solveCubic(a, b, c, d);
            _results = res.asMap().entries.map((e) => 'x${e.key + 1} = ${e.value.toRectString(precision: 4)}').toList();
            break;
          case EquationType.quartic:
            var a = _getVal('a'), b = _getVal('b'), c = _getVal('c'), d = _getVal('d'), e = _getVal('e');
            var res = EquationSolver.solveQuartic(a, b, c, d, e);
            _results = res.asMap().entries.map((e) => 'x${e.key + 1} = ${e.value.toRectString(precision: 4)}').toList();
            break;
        }
      } catch (e) {
        _results = ['Error solving equation', e.toString()];
      }
    });
  }

  Widget _buildTextField(String label, String key, {bool isLast = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: TextField(
          controller: _controllers[key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onSubmitted: isLast ? (_) => _solve() : null,
        ),
      ),
    );
  }

  Widget _buildEquationForm() {
    switch (_selectedType) {
      case EquationType.linear2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('a1·x + b1·y = c1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a1', 'a1'),
              _buildTextField('b1', 'b1'),
              _buildTextField('c1', 'c1'),
            ]),
            const SizedBox(height: 16),
            const Text('a2·x + b2·y = c2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a2', 'a2'),
              _buildTextField('b2', 'b2'),
              _buildTextField('c2', 'c2', isLast: true),
            ]),
          ],
        );
      case EquationType.linear3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('a1·x + b1·y + c1·z = d1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a1', 'a1'),
              _buildTextField('b1', 'b1'),
              _buildTextField('c1', 'c1'),
              _buildTextField('d1', 'd1'),
            ]),
            const SizedBox(height: 16),
            const Text('a2·x + b2·y + c2·z = d2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a2', 'a2'),
              _buildTextField('b2', 'b2'),
              _buildTextField('c2', 'c2'),
              _buildTextField('d2', 'd2'),
            ]),
            const SizedBox(height: 16),
            const Text('a3·x + b3·y + c3·z = d3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a3', 'a3'),
              _buildTextField('b3', 'b3'),
              _buildTextField('c3', 'c3'),
              _buildTextField('d3', 'd3', isLast: true),
            ]),
          ],
        );
      case EquationType.quadratic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('a·x² + b·x + c = 0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a', 'a'),
              _buildTextField('b', 'b'),
              _buildTextField('c', 'c', isLast: true),
            ]),
          ],
        );
      case EquationType.cubic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('a·x³ + b·x² + c·x + d = 0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a', 'a'),
              _buildTextField('b', 'b'),
              _buildTextField('c', 'c'),
              _buildTextField('d', 'd', isLast: true),
            ]),
          ],
        );
      case EquationType.quartic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('a·x⁴ + b·x³ + c·x² + d·x + e = 0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              _buildTextField('a', 'a'),
              _buildTextField('b', 'b'),
              _buildTextField('c', 'c'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildTextField('d', 'd'),
              _buildTextField('e', 'e', isLast: true),
              const Spacer(),
            ]),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation Solver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<EquationType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Equation Type',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                    _setupControllers();
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: EquationType.linear2, child: Text('Linear (2 Unknowns)')),
                DropdownMenuItem(value: EquationType.linear3, child: Text('Linear (3 Unknowns)')),
                DropdownMenuItem(value: EquationType.quadratic, child: Text('Quadratic (ax² + bx + c = 0)')),
                DropdownMenuItem(value: EquationType.cubic, child: Text('Cubic (ax³ + ...) ')),
                DropdownMenuItem(value: EquationType.quartic, child: Text('Quartic (ax⁴ + ...)')),
              ],
            ),
            const SizedBox(height: 24),
            _buildEquationForm(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _solve,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SOLVE', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 32),
            if (_results.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Roots / Solution:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                    const SizedBox(height: 12),
                    ..._results.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            r,
                            style: const TextStyle(fontSize: 20, fontFamily: 'monospace'),
                          ),
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
