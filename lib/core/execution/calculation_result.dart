class CalculationResult {
  final String jobId;
  final bool success;
  final dynamic data; // Can be double, List<double>, List<Map<String, dynamic>> (for complex roots), List<List<double>> (for matrices)
  final String? error;
  final int executionTimeMs;

  CalculationResult({
    required this.jobId,
    required this.success,
    this.data,
    this.error,
    this.executionTimeMs = 0,
  });
}
