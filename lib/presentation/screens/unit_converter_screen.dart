import 'package:flutter/material.dart';
import '../../core/utils/unit_converter_helper.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  UnitCategory _selectedCategory = UnitConverterHelper.categories[0];
  String _fromUnit = '';
  String _toUnit = '';
  double _inputValue = 1.0;
  double _outputValue = 0.0;

  @override
  void initState() {
    super.initState();
    _resetUnits();
  }

  void _resetUnits() {
    _fromUnit = _selectedCategory.units[0];
    _toUnit = _selectedCategory.units[1];
    _convert();
  }

  void _convert() {
    setState(() {
      _outputValue = UnitConverterHelper.convert(
        _selectedCategory.name,
        _fromUnit,
        _toUnit,
        _inputValue,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Selector
            DropdownButtonFormField<UnitCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              onChanged: (cat) {
                if (cat != null) {
                  setState(() {
                    _selectedCategory = cat;
                    _resetUnits();
                  });
                }
              },
              items: UnitConverterHelper.categories.map((cat) {
                return DropdownMenuItem<UnitCategory>(
                  value: cat,
                  child: Text(cat.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Input Value
            TextField(
              decoration: const InputDecoration(
                labelText: 'Input Value',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) {
                final double? parsed = double.tryParse(val);
                if (parsed != null) {
                  _inputValue = parsed;
                  _convert();
                }
              },
              controller: TextEditingController(text: _inputValue.toString()),
            ),
            const SizedBox(height: 20),

            // From Unit
            DropdownButtonFormField<String>(
              value: _fromUnit,
              decoration: const InputDecoration(
                labelText: 'From Unit',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                if (val != null) {
                  _fromUnit = val;
                  _convert();
                }
              },
              items: _selectedCategory.units.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Icon(Icons.arrow_downward, size: 36, color: Colors.blue),
            const SizedBox(height: 20),

            // To Unit
            DropdownButtonFormField<String>(
              value: _toUnit,
              decoration: const InputDecoration(
                labelText: 'To Unit',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                if (val != null) {
                  _toUnit = val;
                  _convert();
                }
              },
              items: _selectedCategory.units.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Output Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Resulting Conversion',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_inputValue $_fromUnit',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${_outputValue.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '')} $_toUnit',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
