import 'package:flutter/material.dart';
import '../../core/theme/calc_theme.dart';

class CalcKeyboard extends StatelessWidget {
  final CalcTheme theme;
  final Function(String) onKeyPressed;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onEvaluate;
  final VoidCallback onShift;
  final VoidCallback onAlpha;
  final VoidCallback onModePressed;

  const CalcKeyboard({
    super.key,
    required this.theme,
    required this.onKeyPressed,
    required this.onClear,
    required this.onBackspace,
    required this.onEvaluate,
    required this.onShift,
    required this.onAlpha,
    required this.onModePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: theme.keyboardBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Command Keys (SHIFT, ALPHA, MODE, DEL, AC)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('SHIFT', theme.shiftKeyColor, Colors.white, onShift),
                _buildBtn('ALPHA', theme.alphaKeyColor, Colors.white, onAlpha),
                _buildBtn('MODE', theme.operatorKeyColor, theme.operatorKeyTextColor, onModePressed),
                _buildBtn('DEL', Colors.redAccent, Colors.white, onBackspace, onLongPress: onClear),
                _buildBtn('AC', Colors.red, Colors.white, onClear),
              ],
            ),
            const SizedBox(height: 8),
  
            // Row 2: Scientific Functions (sin, cos, tan, log, ln, sqrt)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('sin', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('sin(')),
                _buildBtn('cos', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('cos(')),
                _buildBtn('tan', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('tan(')),
                _buildBtn('log', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('log(')),
                _buildBtn('ln', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('ln(')),
              ],
            ),
            const SizedBox(height: 8),
  
            // Row 3: Math operations (Fraction, Power, Root, brackets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('a/b', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('/')),
                _buildBtn('xʸ', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('^')),
                _buildBtn('√', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('√')),
                _buildBtn('(', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('(')),
                _buildBtn(')', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed(')')),
              ],
            ),
            const SizedBox(height: 8),
  
            // Row 4: Numbers (7, 8, 9) & division / multiplication
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('7', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('7')),
                _buildBtn('8', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('8')),
                _buildBtn('9', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('9')),
                _buildBtn('÷', theme.functionKeyColor, theme.functionKeyTextColor, () => onKeyPressed('÷')),
                _buildBtn('π', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('π')),
              ],
            ),
            const SizedBox(height: 8),
  
            // Row 5: Numbers (4, 5, 6) & addition / subtraction
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('4', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('4')),
                _buildBtn('5', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('5')),
                _buildBtn('6', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('6')),
                _buildBtn('×', theme.functionKeyColor, theme.functionKeyTextColor, () => onKeyPressed('×')),
                _buildBtn('Ans', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('Ans')),
              ],
            ),
            const SizedBox(height: 8),
  
            // Row 6: Numbers (1, 2, 3) & operators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('1', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('1')),
                _buildBtn('2', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('2')),
                _buildBtn('3', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('3')),
                _buildBtn('-', theme.functionKeyColor, theme.functionKeyTextColor, () => onKeyPressed('-')),
                _buildBtn(',', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed(',')),
              ],
            ),
            const SizedBox(height: 8),
  
            // Row 7: Number (0), Decimal, exponent, addition & EXE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBtn('0', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('0')),
                _buildBtn('.', theme.numberKeyColor, theme.numberKeyTextColor, () => onKeyPressed('.')),
                _buildBtn('EXP', theme.operatorKeyColor, theme.operatorKeyTextColor, () => onKeyPressed('*10^')),
                _buildBtn('+', theme.functionKeyColor, theme.functionKeyTextColor, () => onKeyPressed('+')),
                _buildBtn('EXE', theme.functionKeyColor, theme.functionKeyTextColor, onEvaluate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(String label, Color btnColor, Color txtColor, VoidCallback action, {VoidCallback? onLongPress}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: txtColor,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: action,
          onLongPress: onLongPress,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
