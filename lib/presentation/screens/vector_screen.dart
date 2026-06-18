import 'dart:math' as math;
import 'package:flutter/material.dart';

class VectorHelper {
  static double dotProduct(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) sum += a[i] * b[i];
    return sum;
  }
  
  static List<double> crossProduct(List<double> a, List<double> b) {
    if (a.length == 3 && b.length == 3) {
      return [
        a[1]*b[2] - a[2]*b[1],
        a[2]*b[0] - a[0]*b[2],
        a[0]*b[1] - a[1]*b[0]
      ];
    }
    return [0, 0, a[0]*b[1] - a[1]*b[0]]; // 2D cross product returns Z vector
  }
  
  static double magnitude(List<double> a) {
    double sum = 0;
    for (var val in a) sum += val * val;
    return math.sqrt(sum);
  }
  
  static List<double> unitVector(List<double> a) {
    double mag = magnitude(a);
    if (mag == 0) return a;
    return a.map((e) => e / mag).toList();
  }
  
  static double angleBetween(List<double> a, List<double> b) {
    double dot = dotProduct(a, b);
    double magA = magnitude(a);
    double magB = magnitude(b);
    if (magA == 0 || magB == 0) return 0.0;
    double val = dot / (magA * magB);
    val = val.clamp(-1.0, 1.0);
    return math.acos(val) * 180 / math.pi; // degrees
  }
}

class VectorScreen extends StatefulWidget {
  const VectorScreen({super.key});

  @override
  State<VectorScreen> createState() => _VectorScreenState();
}

class _VectorScreenState extends State<VectorScreen> {
  int _dim = 3;
  List<double> _vecA = [0.0, 0.0, 0.0];
  List<double> _vecB = [0.0, 0.0, 0.0];

  final List<TextEditingController> _ctrlA = List.generate(3, (_) => TextEditingController(text: '0'));
  final List<TextEditingController> _ctrlB = List.generate(3, (_) => TextEditingController(text: '0'));

  Widget? _resultWidget;

  void _saveVectors() {
    for (int i = 0; i < _dim; i++) {
      _vecA[i] = double.tryParse(_ctrlA[i].text) ?? 0.0;
      _vecB[i] = double.tryParse(_ctrlB[i].text) ?? 0.0;
    }
  }

  void _updateDimension(int newDim) {
    setState(() {
      _saveVectors();
      _dim = newDim;
      // Truncate or expand vectors
      List<double> newA = List.filled(newDim, 0.0);
      List<double> newB = List.filled(newDim, 0.0);
      for(int i=0; i<newDim; i++) {
        if(i < _vecA.length) newA[i] = _vecA[i];
        if(i < _vecB.length) newB[i] = _vecB[i];
      }
      _vecA = newA;
      _vecB = newB;
      
      for(int i=0; i<newDim; i++) {
        _ctrlA[i].text = _vecA[i].toStringAsFixed(0);
        _ctrlB[i].text = _vecB[i].toStringAsFixed(0);
      }
      _resultWidget = null;
    });
  }

  void _setResultScalar(String title, double val, {String unit = ''}) {
    setState(() {
      String display = val.truncateToDouble() == val ? val.toInt().toString() : val.toStringAsFixed(4);
      _resultWidget = Text('$title = $display $unit', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
    });
  }

  void _setResultVector(String title, List<double> vec) {
    setState(() {
      _resultWidget = Column(
        children: [
          Text('$title =', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: Column(
              children: vec.map((v) {
                String display = v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(3);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(display, style: const TextStyle(fontSize: 18)),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  void _handleOp(String op) {
    _saveVectors();
    if (op == 'Dot') {
      _setResultScalar('A · B', VectorHelper.dotProduct(_vecA, _vecB));
    } else if (op == 'Cross') {
      _setResultVector('A × B', VectorHelper.crossProduct(_vecA, _vecB));
    } else if (op == 'MagA') {
      _setResultScalar('|A|', VectorHelper.magnitude(_vecA));
    } else if (op == 'MagB') {
      _setResultScalar('|B|', VectorHelper.magnitude(_vecB));
    } else if (op == 'UnitA') {
      if (VectorHelper.magnitude(_vecA) == 0) {
        _setResultScalar('Error', 0);
        _resultWidget = const Text('Vector A has zero magnitude', style: TextStyle(color: Colors.red));
        return;
      }
      _setResultVector('Unit(A)', VectorHelper.unitVector(_vecA));
    } else if (op == 'UnitB') {
      if (VectorHelper.magnitude(_vecB) == 0) {
        _setResultScalar('Error', 0);
        _resultWidget = const Text('Vector B has zero magnitude', style: TextStyle(color: Colors.red));
        return;
      }
      _setResultVector('Unit(B)', VectorHelper.unitVector(_vecB));
    } else if (op == 'Angle') {
      _setResultScalar('Angle between A and B', VectorHelper.angleBetween(_vecA, _vecB), unit: '°');
    }
  }

  Widget _buildVectorInput(String title, List<TextEditingController> ctrls) {
    List<String> labels = ['x', 'y', 'z'];
    return Column(
      children: [
        Text('Vector $title', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_dim, (i) {
            return Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: TextField(
                controller: ctrls[i],
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: labels[i],
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vector Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Dimensions: '),
                ChoiceChip(
                  label: const Text('2D'),
                  selected: _dim == 2,
                  onSelected: (val) { if (val) _updateDimension(2); },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('3D'),
                  selected: _dim == 3,
                  onSelected: (val) { if (val) _updateDimension(3); },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildVectorInput('A', _ctrlA),
            const SizedBox(height: 20),
            _buildVectorInput('B', _ctrlB),
            const SizedBox(height: 30),
            const Text('Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(onPressed: () => _handleOp('Dot'), child: const Text('A · B (Dot)')),
                ElevatedButton(onPressed: () => _handleOp('Cross'), child: const Text('A × B (Cross)')),
                ElevatedButton(onPressed: () => _handleOp('Angle'), child: const Text('Angle(A, B)')),
                ElevatedButton(onPressed: () => _handleOp('MagA'), child: const Text('|A|')),
                ElevatedButton(onPressed: () => _handleOp('MagB'), child: const Text('|B|')),
                ElevatedButton(onPressed: () => _handleOp('UnitA'), child: const Text('Unit(A)')),
                ElevatedButton(onPressed: () => _handleOp('UnitB'), child: const Text('Unit(B)')),
              ],
            ),
            const SizedBox(height: 30),
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
