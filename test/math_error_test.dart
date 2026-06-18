import 'package:flutter_test/flutter_test.dart';
import 'package:scientific_calcr_pro/providers/calculator_provider.dart';

void main() {
  test('Math ERROR for arcsin', () {
    final notifier = CalculatorNotifier();
    notifier.insertText('arcsin(2)');
    notifier.evaluate();
    expect(notifier.state.result, 'Math ERROR');
  });
  
  test('Math ERROR for arccos', () {
    final notifier = CalculatorNotifier();
    notifier.insertText('arccos(2)');
    notifier.evaluate();
    expect(notifier.state.result, 'Math ERROR');
  });

  test('Valid for arctan', () {
    final notifier = CalculatorNotifier();
    notifier.insertText('arctan(2)');
    notifier.evaluate();
    expect(notifier.state.result, isNot('Math ERROR'));
  });
}
