enum JobType {
  evaluate,
  derivative,
  integral,
  solveLinear,
  solveQuadratic,
  solveCubic,
  solveQuartic,
  matrixDet,
  matrixInv,
  matrixRank,
  matrixMul,
  casSimplify,
  casFactor,
  casDiff,
  casIntegrate,
  casSolve,
}

class CalculationJob {
  final String id;
  final JobType type;
  final String expression;
  final Map<String, double> variables;
  final Map<String, dynamic> extra;

  CalculationJob({
    required this.id,
    required this.type,
    this.expression = '',
    this.variables = const {},
    this.extra = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'expression': expression,
      'variables': variables,
      'extra': extra,
    };
  }
}
