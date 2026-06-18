import 'package:flutter/material.dart';

enum BaseMode { hex, dec, oct, bin }

enum Operator { add, sub, mul, div, and, or, xor, not, lsh, rsh }

class BaseNScreen extends StatefulWidget {
  const BaseNScreen({super.key});

  @override
  State<BaseNScreen> createState() => _BaseNScreenState();
}

class _BaseNScreenState extends State<BaseNScreen> {
  BaseMode _base1 = BaseMode.dec;
  BaseMode _base2 = BaseMode.dec;
  Operator _operator = Operator.add;

  final TextEditingController _input1Controller = TextEditingController(text: '0');
  final TextEditingController _input2Controller = TextEditingController(text: '0');

  int _result = 0;

  @override
  void initState() {
    super.initState();
    _input1Controller.addListener(_calculate);
    _input2Controller.addListener(_calculate);
    _calculate();
  }

  @override
  void dispose() {
    _input1Controller.dispose();
    _input2Controller.dispose();
    super.dispose();
  }

  void _calculate() {
    int? val1 = _parseValue(_input1Controller.text, _base1);
    int? val2 = _parseValue(_input2Controller.text, _base2);

    if (val1 == null) val1 = 0;
    if (val2 == null) val2 = 0;

    int res = 0;
    try {
      switch (_operator) {
        case Operator.add:
          res = val1 + val2;
          break;
        case Operator.sub:
          res = val1 - val2;
          break;
        case Operator.mul:
          res = val1 * val2;
          break;
        case Operator.div:
          res = val2 != 0 ? val1 ~/ val2 : 0;
          break;
        case Operator.and:
          res = val1 & val2;
          break;
        case Operator.or:
          res = val1 | val2;
          break;
        case Operator.xor:
          res = val1 ^ val2;
          break;
        case Operator.not:
          res = ~val1;
          break;
        case Operator.lsh:
          res = val1 << val2;
          break;
        case Operator.rsh:
          res = val1 >> val2;
          break;
      }
    } catch (e) {
      res = 0;
    }

    setState(() {
      _result = res;
    });
  }

  int? _parseValue(String text, BaseMode base) {
    if (text.isEmpty) return 0;
    int radix = 10;
    switch (base) {
      case BaseMode.hex: radix = 16; break;
      case BaseMode.dec: radix = 10; break;
      case BaseMode.oct: radix = 8; break;
      case BaseMode.bin: radix = 2; break;
    }
    return int.tryParse(text, radix: radix);
  }

  String _formatResult(int value, BaseMode base) {
    // Handling negative numbers properly for bitwise 64-bit display might be too long, 
    // so we just use toRadixString and let it handle minus sign for Dec, and standard bitwise for others
    if (base == BaseMode.dec) return value.toString();
    
    // For hex, oct, bin, show standard machine representation if negative
    String res = value.toRadixString(_getRadix(base)).toUpperCase();
    if (base == BaseMode.bin && res.length < 8) {
       // Pad binary just a little for aesthetics if positive and small
       if (value >= 0) {
         res = res.padLeft(8, '0');
       }
    }
    return res;
  }

  int _getRadix(BaseMode base) {
    switch (base) {
      case BaseMode.hex: return 16;
      case BaseMode.dec: return 10;
      case BaseMode.oct: return 8;
      case BaseMode.bin: return 2;
    }
  }

  String _getOperatorSymbol(Operator op) {
    switch (op) {
      case Operator.add: return '+';
      case Operator.sub: return '-';
      case Operator.mul: return '*';
      case Operator.div: return '/';
      case Operator.and: return 'AND';
      case Operator.or: return 'OR';
      case Operator.xor: return 'XOR';
      case Operator.not: return 'NOT';
      case Operator.lsh: return '<<';
      case Operator.rsh: return '>>';
    }
  }

  Widget _buildResultPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildResultRow('HEX', _formatResult(_result, BaseMode.hex)),
          const Divider(),
          _buildResultRow('DEC', _formatResult(_result, BaseMode.dec)),
          const Divider(),
          _buildResultRow('OCT', _formatResult(_result, BaseMode.oct)),
          const Divider(),
          _buildResultRow('BIN', _formatResult(_result, BaseMode.bin)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isUnary = _operator == Operator.not;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BASE-N & Bitwise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Operand 1', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<BaseMode>(
                    value: _base1,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                    items: const [
                      DropdownMenuItem(value: BaseMode.hex, child: Text('HEX')),
                      DropdownMenuItem(value: BaseMode.dec, child: Text('DEC')),
                      DropdownMenuItem(value: BaseMode.oct, child: Text('OCT')),
                      DropdownMenuItem(value: BaseMode.bin, child: Text('BIN')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() { _base1 = val; _calculate(); });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: _input1Controller,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    style: const TextStyle(fontFamily: 'monospace'),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text('Operator', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Operator>(
              value: _operator,
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              items: Operator.values.map((op) {
                return DropdownMenuItem(value: op, child: Text(_getOperatorSymbol(op)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() { _operator = val; _calculate(); });
              },
            ),
            const SizedBox(height: 16),

            if (!isUnary) ...[
              const Text('Operand 2', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<BaseMode>(
                      value: _base2,
                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                      items: const [
                        DropdownMenuItem(value: BaseMode.hex, child: Text('HEX')),
                        DropdownMenuItem(value: BaseMode.dec, child: Text('DEC')),
                        DropdownMenuItem(value: BaseMode.oct, child: Text('OCT')),
                        DropdownMenuItem(value: BaseMode.bin, child: Text('BIN')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() { _base2 = val; _calculate(); });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: _input2Controller,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      style: const TextStyle(fontFamily: 'monospace'),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            const Text('Result Conversions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildResultPanel(),
          ],
        ),
      ),
    );
  }
}
