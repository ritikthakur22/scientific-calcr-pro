import 'dart:io';

void main() {
  final script = "const nerdamer = require('./scratch_cas/node_modules/nerdamer/all.min.js'); console.log(nerdamer('solve(x^2 - 4, x)').toString());";
  final result = Process.runSync('node', ['-e', script]);
  print(result.stdout);
}
