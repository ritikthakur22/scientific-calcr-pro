import 'package:flutter/material.dart';
import 'dart:math' as math;

class StatsPoint {
  final double x;
  final double y;
  StatsPoint(this.x, this.y);
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final List<StatsPoint> _data = [];
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final FocusNode _xFocus = FocusNode();

  void _addPoint() {
    double? x = double.tryParse(_xController.text);
    double? y = double.tryParse(_yController.text);
    if (x != null) {
      setState(() {
        _data.add(StatsPoint(x, y ?? 0.0));
      });
      _xController.clear();
      _yController.clear();
      _xFocus.requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid X value.')),
      );
    }
  }

  void _removePoint(int index) {
    setState(() {
      _data.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _data.clear();
    });
  }

  // --- Calculations ---

  Map<String, String> _calculate1Var() {
    if (_data.isEmpty) return {'Status': 'No data'};
    int n = _data.length;
    double sumX = _data.fold(0, (sum, p) => sum + p.x);
    double mean = sumX / n;

    List<double> sortedX = _data.map((p) => p.x).toList()..sort();
    double median;
    if (n % 2 == 0) {
      median = (sortedX[n ~/ 2 - 1] + sortedX[n ~/ 2]) / 2;
    } else {
      median = sortedX[n ~/ 2];
    }

    Map<double, int> counts = {};
    for (var x in sortedX) {
      counts[x] = (counts[x] ?? 0) + 1;
    }
    int maxCount = counts.values.reduce(math.max);
    List<double> modes = counts.entries.where((e) => e.value == maxCount).map((e) => e.key).toList();
    String modeStr = modes.length > 3 ? '${modes.take(3).join(', ')}...' : modes.join(', ');

    double sumX2 = _data.fold(0, (sum, p) => sum + p.x * p.x);
    double popVariance = _data.fold(0.0, (sum, p) => sum + math.pow(p.x - mean, 2)) / n;
    double popStdDev = math.sqrt(popVariance);
    double sampleVariance = n > 1 ? _data.fold(0.0, (sum, p) => sum + math.pow(p.x - mean, 2)) / (n - 1) : 0.0;
    double sampleStdDev = math.sqrt(sampleVariance);

    return {
      'n (Count)': n.toString(),
      '∑x (Sum)': _fmt(sumX),
      '∑x² (Sum Sq)': _fmt(sumX2),
      'x̄ (Mean)': _fmt(mean),
      'Med (Median)': _fmt(median),
      'Mode': modeStr,
      'σ² (Pop. Var)': _fmt(popVariance),
      'σ (Pop. StdDev)': _fmt(popStdDev),
      's² (Sample Var)': n > 1 ? _fmt(sampleVariance) : 'N/A',
      's (Sample StdDev)': n > 1 ? _fmt(sampleStdDev) : 'N/A',
    };
  }

  Map<String, String> _calculateRegression() {
    if (_data.length < 2) return {'Status': 'Requires ≥ 2 points'};
    
    int n = _data.length;
    double sumX = 0, sumY = 0, sumX2 = 0, sumX3 = 0, sumX4 = 0, sumXY = 0, sumX2Y = 0;
    
    for (var p in _data) {
      sumX += p.x;
      sumY += p.y;
      sumX2 += p.x * p.x;
      sumX3 += math.pow(p.x, 3).toDouble();
      sumX4 += math.pow(p.x, 4).toDouble();
      sumXY += p.x * p.y;
      sumX2Y += p.x * p.x * p.y;
    }

    Map<String, String> results = {};

    // 1. Linear: y = ax + b
    double denLin = n * sumX2 - sumX * sumX;
    if (denLin == 0) {
      results['Linear (y = ax + b)'] = 'Undefined (Vertical Line)';
    } else {
      double aLin = (n * sumXY - sumX * sumY) / denLin;
      double bLin = (sumY - aLin * sumX) / n;
      results['Linear (y = ax + b)'] = 'a = ${_fmt(aLin)}\nb = ${_fmt(bLin)}';
    }

    // 2. Quadratic: y = ax^2 + bx + c
    if (n >= 3) {
      double D = sumX4 * (sumX2 * n - sumX * sumX) - sumX3 * (sumX3 * n - sumX2 * sumX) + sumX2 * (sumX3 * sumX - sumX2 * sumX2);
      if (D == 0) {
        results['Quadratic (y = ax² + bx + c)'] = 'Cannot fit quadratic';
      } else {
        double Da = sumX2Y * (sumX2 * n - sumX * sumX) - sumXY * (sumX3 * n - sumX * sumX2) + sumY * (sumX3 * sumX - sumX2 * sumX2);
        double Db = sumX4 * (sumXY * n - sumY * sumX) - sumX3 * (sumX2Y * n - sumY * sumX2) + sumX2 * (sumX2Y * sumX - sumXY * sumX2);
        double Dc = sumX4 * (sumX2 * sumY - sumXY * sumX) - sumX3 * (sumX3 * sumY - sumXY * sumX2) + sumX2 * (sumX3 * sumXY - sumX2Y * sumX2);
        
        double aQuad = Da / D;
        double bQuad = Db / D;
        double cQuad = Dc / D;
        results['Quadratic (y = ax² + bx + c)'] = 'a = ${_fmt(aQuad)}\nb = ${_fmt(bQuad)}\nc = ${_fmt(cQuad)}';
      }
    } else {
      results['Quadratic (y = ax² + bx + c)'] = 'Requires ≥ 3 points';
    }

    // 3. Exponential: y = a * b^x -> ln(y) = ln(a) + x * ln(b)
    bool validExp = true;
    double sumLnY = 0, sumXLnY = 0;
    for (var p in _data) {
      if (p.y <= 0) {
        validExp = false;
        break;
      }
      double lnY = math.log(p.y);
      sumLnY += lnY;
      sumXLnY += p.x * lnY;
    }
    
    if (!validExp) {
      results['Exponential (y = a·b^x)'] = 'Requires y > 0 for all points';
    } else if (denLin == 0) {
      results['Exponential (y = a·b^x)'] = 'Cannot fit';
    } else {
      double A = (n * sumXLnY - sumX * sumLnY) / denLin;
      double B = (sumLnY - A * sumX) / n;
      double aExp = math.exp(B);
      double bExp = math.exp(A);
      results['Exponential (y = a·b^x)'] = 'a = ${_fmt(aExp)}\nb = ${_fmt(bExp)}';
    }

    return results;
  }

  String _fmt(double val) {
    if (val.isNaN) return 'NaN';
    if (val.isInfinite) return 'Inf';
    return val.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final stats1Var = _calculate1Var();
    final statsReg = _calculateRegression();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics & Regression'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All Data',
            onPressed: _data.isEmpty ? null : _clearAll,
          )
        ],
      ),
      body: Column(
        children: [
          // Data Entry Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _xController,
                    focusNode: _xFocus,
                    decoration: const InputDecoration(
                      labelText: 'X Value',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _yController,
                    decoration: const InputDecoration(
                      labelText: 'Y Value (Opt)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    onSubmitted: (_) => _addPoint(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addPoint,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          
          // Data List Section
          if (_data.isNotEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
                color: Colors.grey.withOpacity(0.05),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final p = _data[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('X: ${_fmt(p.x)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Y: ${_fmt(p.y)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _removePoint(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Results Section
          Expanded(
            child: _data.isEmpty
                ? Center(
                    child: Text(
                      'Enter data points to view statistics.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // 1-Var Stats
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '1-Variable Statistics (X)',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              const Divider(),
                              ...stats1Var.entries.map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text(e.value, style: const TextStyle(fontFamily: 'monospace')),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 2-Var Regression
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Regression (2-Variable)',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const Divider(),
                              ...statsReg.entries.map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            e.value,
                                            style: const TextStyle(fontFamily: 'monospace'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
