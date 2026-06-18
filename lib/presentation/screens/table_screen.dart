import 'package:flutter/material.dart';
import '../../core/math_engine/math_parser.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  final TextEditingController _fxController = TextEditingController();
  final TextEditingController _gxController = TextEditingController();
  final TextEditingController _startController = TextEditingController(text: '1');
  final TextEditingController _endController = TextEditingController(text: '5');
  final TextEditingController _stepController = TextEditingController(text: '1');

  List<Map<String, String>> _tableData = [];
  bool _isLoading = false;

  void _generateTable() {
    setState(() {
      _isLoading = true;
    });

    // A small delay to allow UI to update loading state
    Future.delayed(const Duration(milliseconds: 50), () {
      _tableData.clear();
      double start = double.tryParse(_startController.text) ?? 1;
      double end = double.tryParse(_endController.text) ?? 5;
      double step = double.tryParse(_stepController.text) ?? 1;

      if (step == 0) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Step cannot be zero')),
        );
        return;
      }

      // Pre-process function strings: replace 'x' with 'X' since MathParser uses uppercase X
      String fx = _fxController.text.replaceAll('x', 'X');
      String gx = _gxController.text.replaceAll('x', 'X');

      int iterations = ((end - start) / step).abs().toInt();
      if (iterations > 5000) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Too many rows. Please reduce the range or increase the step.')),
        );
        return;
      }

      List<Map<String, String>> newData = [];
      for (double i = start; step > 0 ? i <= end : i >= end; i += step) {
        MathParser.setVariable('X', i);
        String fVal = '-';
        String gVal = '-';

        if (fx.isNotEmpty) {
          try {
            fVal = MathParser.evaluate(fx).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
          } catch (e) {
            fVal = 'Error';
          }
        }

        if (gx.isNotEmpty) {
          try {
            gVal = MathParser.evaluate(gx).toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');
          } catch (e) {
            gVal = 'Error';
          }
        }

        newData.add({
          'x': i.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), ''),
          'fx': fVal,
          'gx': gVal,
        });
      }

      setState(() {
        _tableData = newData;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Function Inputs
            TextField(
              controller: _fxController,
              decoration: const InputDecoration(
                labelText: 'f(x) =',
                hintText: 'e.g. x^2 + 2*x + 1',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _gxController,
              decoration: const InputDecoration(
                labelText: 'g(x) = (Optional)',
                hintText: 'e.g. sin(x)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),

            // Range Inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startController,
                    decoration: const InputDecoration(labelText: 'Start', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _endController,
                    decoration: const InputDecoration(labelText: 'End', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    decoration: const InputDecoration(labelText: 'Step', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateTable,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Generate Table', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // Table Output
            Expanded(
              child: _tableData.isEmpty
                  ? Center(
                      child: Text(
                        'Enter functions and range to generate table.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 32,
                          headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.blue.withOpacity(0.1)),
                          columns: const [
                            DataColumn(label: Text('x', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('f(x)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('g(x)', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _tableData.map((row) {
                            return DataRow(cells: [
                              DataCell(Text(row['x']!)),
                              DataCell(Text(row['fx']!)),
                              DataCell(Text(row['gx']!)),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
