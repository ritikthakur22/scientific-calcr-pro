import 'cas_engine.dart';

void main() async {
  final jsCode = await CasEngine.getNerdamerCode();
  final result = CasEngine.evaluateDirect(jsCode, "nerdamer('diff(x^2, x)').toString()");
  print('Result: $result');
}
