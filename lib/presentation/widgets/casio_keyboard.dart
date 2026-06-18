import "../../providers/calculator_provider.dart";
import 'package:flutter/material.dart';
import '../../core/theme/calc_theme.dart';
import 'scientific_key.dart';

class Dpad extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final Color color;

  const Dpad({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))
            ],
          ),
          child: Stack(
            children: [
              // Up
              Positioned(
                top: 0, left: 0, right: 0, height: constraints.maxHeight / 2.5,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onUp,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    child: const Align(alignment: Alignment.topCenter, child: Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.arrow_drop_up, size: 28, color: Colors.white))),
                  ),
                ),
              ),
              // Down
              Positioned(
                bottom: 0, left: 0, right: 0, height: constraints.maxHeight / 2.5,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDown,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    child: const Align(alignment: Alignment.bottomCenter, child: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.arrow_drop_down, size: 28, color: Colors.white))),
                  ),
                ),
              ),
              // Left
              Positioned(
                top: constraints.maxHeight / 4, bottom: constraints.maxHeight / 4, left: 0, width: constraints.maxWidth / 2.5,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onLeft,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(40)),
                    child: const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.arrow_left, size: 28, color: Colors.white))),
                  ),
                ),
              ),
              // Right
              Positioned(
                top: constraints.maxHeight / 4, bottom: constraints.maxHeight / 4, right: 0, width: constraints.maxWidth / 2.5,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onRight,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(40)),
                    child: const Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.arrow_right, size: 28, color: Colors.white))),
                  ),
                ),
              ),
              // Center hole
              Center(
                child: IgnorePointer(
                  child: Container(
                    width: constraints.maxWidth / 3,
                    height: constraints.maxHeight / 3,
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

class CasioKeyboard extends StatelessWidget {
  final CalcTheme theme;
  final bool isShift;
  final bool isAlpha;
  final Function(String) onKeyPressed;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onEvaluate;
  final VoidCallback onShiftPressed;
  final VoidCallback onAlphaPressed;
  final VoidCallback onModePressed;
  final VoidCallback onNavUp;
  final VoidCallback onNavDown;
  final VoidCallback onNavLeft;
  final VoidCallback onNavRight;
  final VoidCallback onHistory;
  final VoidCallback onGraph;
  final Function(CalculatorMode) onSetMode;
  final VoidCallback onConst;
  final VoidCallback onConv;

  const CasioKeyboard({
    super.key,
    required this.theme,
    required this.isShift,
    required this.isAlpha,
    required this.onKeyPressed,
    required this.onClear,
    required this.onBackspace,
    required this.onEvaluate,
    required this.onShiftPressed,
    required this.onAlphaPressed,
    required this.onModePressed,
    required this.onNavUp,
    required this.onNavDown,
    required this.onNavLeft,
    required this.onNavRight,
    required this.onHistory,
    required this.onGraph,
    required this.onSetMode,
    required this.onConst,
    required this.onConv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.keyboardBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Upper Zone (Top + Scientific) - 5 rows
          Expanded(
            flex: 5,
            child: _buildUpperZone(),
          ),
          
          const SizedBox(height: 12),
          
          // Numpad and Basic Math - 4 rows
          Expanded(
            flex: 4,
            child: _buildNumpadZone(),
          ),
        ],
      ),
    );
  }

  Widget _buildSciKey(String label, {String? shift, String? alpha, required String mainTap, VoidCallback? shiftTap, VoidCallback? alphaTap}) {
    return ScientificKey(
      mainLabel: label,
      shiftLabel: shift,
      alphaLabel: alpha,
      mainColor: theme.operatorKeyColor,
      textColor: theme.operatorKeyTextColor,
      isShiftActive: isShift,
      isAlphaActive: isAlpha,
      onMainTap: () => onKeyPressed(mainTap),
      onShiftTap: shiftTap ?? (shift != null ? () => onKeyPressed(shift) : null),
      onAlphaTap: alphaTap ?? (alpha != null ? () => onKeyPressed(alpha) : null),
    );
  }

  Widget _buildUpperZone() {
    return Column(
      children: [
        // Top 2 rows (Controls + D-Pad + upper sci)
        Expanded(
          flex: 2,
          child: Row(
            children: [
              // Left block
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ScientificKey(
                            mainLabel: 'SHIFT',
                            mainColor: isShift ? Colors.amber[700]! : theme.shiftKeyColor,
                            textColor: Colors.white,
                            onMainTap: onShiftPressed,
                          ),
                          ScientificKey(
                            mainLabel: 'ALPHA',
                            mainColor: isAlpha ? Colors.red[400]! : theme.alphaKeyColor,
                            textColor: Colors.white,
                            onMainTap: onAlphaPressed,
                          ),
                        ]
                      )
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          ScientificKey(
                            mainLabel: 'CALC',
                            shiftLabel: 'SOLVE',
                            alphaLabel: '=',
                            mainColor: theme.operatorKeyColor,
                            textColor: theme.operatorKeyTextColor,
                            isShiftActive: isShift,
                            isAlphaActive: isAlpha,
                            onMainTap: onEvaluate,
                            onShiftTap: () => onKeyPressed('solve('), 
                            onAlphaTap: () => onKeyPressed('='),
                          ),
                          ScientificKey(
                            mainLabel: '∫dx',
                            shiftLabel: 'd/dx',
                            alphaLabel: 'Σ',
                            mainColor: theme.operatorKeyColor,
                            textColor: theme.operatorKeyTextColor,
                            isShiftActive: isShift,
                            isAlphaActive: isAlpha,
                            onMainTap: () => onKeyPressed('∫('),
                            onShiftTap: () => onKeyPressed('diff('),
                            onAlphaTap: () => onKeyPressed('sum('),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),
              // Center D-Pad
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: Dpad(
                    onUp: onNavUp,
                    onDown: onNavDown,
                    onLeft: onNavLeft,
                    onRight: onNavRight,
                    color: theme.operatorKeyColor,
                  ),
                ),
              ),
              // Right block
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ScientificKey(
                            mainLabel: 'MODE',
                            shiftLabel: 'SETUP',
                            mainColor: theme.operatorKeyColor,
                            textColor: theme.operatorKeyTextColor,
                            onMainTap: onModePressed,
                            onShiftTap: onModePressed,
                            isShiftActive: isShift,
                            isAlphaActive: isAlpha,
                          ),
                          ScientificKey(
                            mainLabel: 'ON',
                            mainColor: theme.operatorKeyColor,
                            textColor: theme.operatorKeyTextColor,
                            onMainTap: onClear,
                          ),
                        ]
                      )
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          ScientificKey(
                            mainLabel: 'x⁻¹',
                            shiftLabel: 'x!',
                            mainColor: theme.operatorKeyColor,
                            textColor: theme.operatorKeyTextColor,
                            isShiftActive: isShift,
                            isAlphaActive: isAlpha,
                            onMainTap: () => onKeyPressed('^-1'),
                            onShiftTap: () => onKeyPressed('!'),
                          ),
                          ScientificKey(
                            mainLabel: 'logₐb',
                            shiftLabel: '10ˣ',
                            alphaLabel: 'eˣ',
                            mainColor: theme.operatorKeyColor,
                            textColor: theme.operatorKeyTextColor,
                            isShiftActive: isShift,
                            isAlphaActive: isAlpha,
                            onMainTap: () => onKeyPressed('log_base('),
                            onShiftTap: () => onKeyPressed('10^'),
                            onAlphaTap: () => onKeyPressed('e^'),
                          ),
                        ]
                      )
                    ),
                  ]
                )
              ),
            ]
          )
        ),
        // Row 3
        Expanded(
          child: Row(
            children: [
              _buildSciKey('a/b', shift: 'd/c', mainTap: '/'),
              _buildSciKey('√', shift: '³√', mainTap: '√(', shiftTap: () => onKeyPressed('cbrt(')),
              _buildSciKey('x²', shift: 'x³', mainTap: '^2', shiftTap: () => onKeyPressed('^3')),
              _buildSciKey('xʸ', shift: 'ˣ√', mainTap: '^', shiftTap: () => onKeyPressed('nth_root(')),
              _buildSciKey('log', shift: '10ˣ', mainTap: 'log(', shiftTap: () => onKeyPressed('10^(')),
              _buildSciKey('ln', shift: 'eˣ', alpha: 'e', mainTap: 'ln(', shiftTap: () => onKeyPressed('E^(')),
            ],
          ),
        ),
        // Row 4
        Expanded(
          child: Row(
            children: [
              _buildSciKey('(-)', shift: 'abs', alpha: 'A', mainTap: '-'),
              _buildSciKey('°\'\"', shift: 'FACT', alpha: 'B', mainTap: '°'),
              _buildSciKey('hyp', shift: 'sinh', alpha: 'C', mainTap: 'hyp('), 
              _buildSciKey('sin', shift: 'sin⁻¹', alpha: 'D', mainTap: 'sin(', shiftTap: () => onKeyPressed('sin⁻¹(')),
              _buildSciKey('cos', shift: 'cos⁻¹', alpha: 'E', mainTap: 'cos(', shiftTap: () => onKeyPressed('cos⁻¹(')),
              _buildSciKey('tan', shift: 'tan⁻¹', alpha: 'F', mainTap: 'tan(', shiftTap: () => onKeyPressed('tan⁻¹(')),
            ],
          ),
        ),
        // Row 5
        Expanded(
          child: Row(
            children: [
              _buildSciKey('RCL', shift: 'STO', mainTap: 'RCL'), 
              _buildSciKey('ENG', shift: '←', mainTap: 'E', shiftTap: onBackspace),
              _buildSciKey('(', shift: 'EQN', alpha: 'X', mainTap: '(', shiftTap: () => onSetMode(CalculatorMode.equation)),
              _buildSciKey(')', shift: 'GRAPH', alpha: 'Y', mainTap: ')', shiftTap: onGraph),
              _buildSciKey('S⇔D', shift: 'CAS', alpha: 'M', mainTap: 'S⇔D', shiftTap: () => onSetMode(CalculatorMode.cas)),
              _buildSciKey('M+', shift: 'M-', mainTap: 'M+'),
            ],
          ),
        ),
      ]
    );
  }

  Widget _numKey(String label, {String? shift, String? alpha, VoidCallback? shiftTap, VoidCallback? alphaTap}) {
    return ScientificKey(
      mainLabel: label,
      shiftLabel: shift,
      alphaLabel: alpha,
      mainColor: theme.numberKeyColor,
      textColor: theme.numberKeyTextColor,
      isShiftActive: isShift,
      isAlphaActive: isAlpha,
      onMainTap: () => onKeyPressed(label),
      onShiftTap: shiftTap,
      onAlphaTap: alphaTap,
    );
  }

  Widget _opKey(String label, {String? shift, String? alpha, VoidCallback? shiftTap, VoidCallback? alphaTap}) {
    return ScientificKey(
      mainLabel: label,
      shiftLabel: shift,
      alphaLabel: alpha,
      mainColor: theme.functionKeyColor,
      textColor: theme.functionKeyTextColor,
      isShiftActive: isShift,
      isAlphaActive: isAlpha,
      onMainTap: () => onKeyPressed(label),
      onShiftTap: shiftTap,
      onAlphaTap: alphaTap,
    );
  }

  Widget _buildNumpadZone() {
    return Column(
      children: [
        // 7 8 9 DEL AC
        Expanded(
          child: Row(
            children: [
              _numKey('7', shift: 'CONST', shiftTap: onConst),
              _numKey('8', shift: 'CONV', shiftTap: onConv),
              _numKey('9', shift: 'CLR', shiftTap: onClear),
              ScientificKey(
                mainLabel: 'DEL',
                shiftLabel: 'INS',
                mainColor: Colors.orange[800]!,
                textColor: Colors.white,
                isShiftActive: isShift,
                isAlphaActive: isAlpha,
                onMainTap: onBackspace,
                onShiftTap: () => onKeyPressed('INS'),
              ),
              ScientificKey(
                mainLabel: 'AC',
                shiftLabel: 'OFF',
                mainColor: Colors.red[800]!,
                textColor: Colors.white,
                isShiftActive: isShift,
                isAlphaActive: isAlpha,
                onMainTap: onClear,
                onShiftTap: onClear,
              ),
            ],
          ),
        ),
        // 4 5 6 * /
        Expanded(
          child: Row(
            children: [
              _numKey('4', shift: 'MATRIX', alpha: 'A', shiftTap: () => onSetMode(CalculatorMode.matrix), alphaTap: () => onKeyPressed('A')),
              _numKey('5', shift: 'VECTOR', alpha: 'B', shiftTap: () => onSetMode(CalculatorMode.vector), alphaTap: () => onKeyPressed('B')),
              _numKey('6', shift: 'STAT', alpha: 'C', shiftTap: () => onSetMode(CalculatorMode.statistics), alphaTap: () => onKeyPressed('C')),
              _opKey('×', shift: 'nPr', shiftTap: () => onKeyPressed('P')),
              _opKey('÷', shift: 'nCr', shiftTap: () => onKeyPressed('C')),
            ],
          ),
        ),
        // 1 2 3 + -
        Expanded(
          child: Row(
            children: [
              _numKey('1', shift: 'STATVAR', shiftTap: () => onKeyPressed('statvar(')),
              _numKey('2', shift: 'CMPLX', shiftTap: () => onSetMode(CalculatorMode.complex)),
              _numKey('3', shift: 'BASE', shiftTap: () => onSetMode(CalculatorMode.baseN)),
              _opKey('+', shift: 'Pol', shiftTap: () => onKeyPressed('Pol(')),
              _opKey('-', shift: 'Rec', shiftTap: () => onKeyPressed('Rec(')),
            ],
          ),
        ),
        // 0 . EXP Ans =
        Expanded(
          child: Row(
            children: [
              _numKey('0', shift: 'RND', shiftTap: () => onKeyPressed('rnd(')),
              _numKey('.', shift: 'Ran#', shiftTap: () => onKeyPressed('rand()')),
              ScientificKey(
                mainLabel: '×10ˣ',
                shiftLabel: 'π',
                alphaLabel: 'e',
                mainColor: theme.numberKeyColor,
                textColor: theme.numberKeyTextColor,
                isShiftActive: isShift,
                isAlphaActive: isAlpha,
                onMainTap: () => onKeyPressed('*10^'),
                onShiftTap: () => onKeyPressed('π'),
                onAlphaTap: () => onKeyPressed('e'),
              ),
              ScientificKey(
                mainLabel: 'Ans',
                shiftLabel: 'DRG',
                mainColor: theme.operatorKeyColor,
                textColor: theme.operatorKeyTextColor,
                isShiftActive: isShift,
                isAlphaActive: isAlpha,
                onMainTap: () => onKeyPressed('Ans'),
                onShiftTap: () => onKeyPressed('DRG'),
              ),
              ScientificKey(
                mainLabel: '=',
                shiftLabel: '≈',
                mainColor: Colors.blue[700]!,
                textColor: Colors.white,
                isShiftActive: isShift,
                isAlphaActive: isAlpha,
                onMainTap: onEvaluate,
                onShiftTap: onEvaluate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
