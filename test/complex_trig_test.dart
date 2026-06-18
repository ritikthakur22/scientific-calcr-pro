import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/providers/calculator_provider.dart';

void main() {
  test('Complex acos', () {
    final notifier = CalculatorNotifier();
    // Switch to CMPLX mode
    notifier.state = notifier.state.copyWith(mode: CalculatorMode.complex);
    notifier.insertText('acos(8)');
    notifier.evaluate();
    expect(notifier.state.result, '0 + 2.768659i');
  });

  test('Complex asin', () {
    final notifier = CalculatorNotifier();
    notifier.state = notifier.state.copyWith(mode: CalculatorMode.complex);
    notifier.insertText('asin(8)');
    notifier.evaluate();
    expect(notifier.state.result, '1.570796 - 2.768659i');
  });

  test('Complex atan', () {
    final notifier = CalculatorNotifier();
    notifier.state = notifier.state.copyWith(mode: CalculatorMode.complex);
    notifier.insertText('atan(8)');
    notifier.evaluate();
    expect(notifier.state.result, '1.446441');
  });
}
