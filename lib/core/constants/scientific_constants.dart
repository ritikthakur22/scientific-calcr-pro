class ScientificConstant {
  final String symbol;
  final String name;
  final double value;
  final String unit;
  final String category;

  const ScientificConstant({
    required this.symbol,
    required this.name,
    required this.value,
    required this.unit,
    required this.category,
  });
}

class ScientificConstants {
  static const List<ScientificConstant> list = [
    // --- Physics ---
    ScientificConstant(
      symbol: 'c',
      name: 'Speed of Light',
      value: 299792458.0,
      unit: 'm/s',
      category: 'Physics',
    ),
    ScientificConstant(
      symbol: 'G',
      name: 'Newtonian Gravitational Constant',
      value: 6.6743e-11,
      unit: 'm³/(kg·s²)',
      category: 'Physics',
    ),
    ScientificConstant(
      symbol: 'h',
      name: 'Planck Constant',
      value: 6.62607015e-34,
      unit: 'J·s',
      category: 'Physics',
    ),
    ScientificConstant(
      symbol: 'g',
      name: 'Standard Gravitational Acceleration',
      value: 9.80665,
      unit: 'm/s²',
      category: 'Physics',
    ),
    ScientificConstant(
      symbol: 'μ₀',
      name: 'Vacuum Magnetic Permeability',
      value: 1.25663706212e-6,
      unit: 'N/A²',
      category: 'Physics',
    ),
    ScientificConstant(
      symbol: 'ε₀',
      name: 'Vacuum Electric Permittivity',
      value: 8.8541878128e-12,
      unit: 'F/m',
      category: 'Physics',
    ),
    
    // --- Chemistry ---
    ScientificConstant(
      symbol: 'N_A',
      name: 'Avogadro Constant',
      value: 6.02214076e23,
      unit: 'mol⁻¹',
      category: 'Chemistry',
    ),
    ScientificConstant(
      symbol: 'R',
      name: 'Molar Gas Constant',
      value: 8.314462618,
      unit: 'J/(mol·K)',
      category: 'Chemistry',
    ),
    ScientificConstant(
      symbol: 'k_B',
      name: 'Boltzmann Constant',
      value: 1.380649e-23,
      unit: 'J/K',
      category: 'Chemistry',
    ),
    ScientificConstant(
      symbol: 'e',
      name: 'Elementary Charge',
      value: 1.602176634e-19,
      unit: 'C',
      category: 'Chemistry',
    ),
    ScientificConstant(
      symbol: 'F',
      name: 'Faraday Constant',
      value: 96485.33212,
      unit: 'C/mol',
      category: 'Chemistry',
    ),
    ScientificConstant(
      symbol: 'm_e',
      name: 'Electron Mass',
      value: 9.1093837015e-31,
      unit: 'kg',
      category: 'Chemistry',
    ),
    ScientificConstant(
      symbol: 'm_p',
      name: 'Proton Mass',
      value: 1.67262192369e-27,
      unit: 'kg',
      category: 'Chemistry',
    ),

    // --- Mathematics ---
    ScientificConstant(
      symbol: 'π',
      name: 'Pi',
      value: 3.141592653589793,
      unit: 'dimensionless',
      category: 'Mathematics',
    ),
    ScientificConstant(
      symbol: 'e',
      name: 'Euler Number',
      value: 2.718281828459045,
      unit: 'dimensionless',
      category: 'Mathematics',
    ),
    ScientificConstant(
      symbol: 'φ',
      name: 'Golden Ratio',
      value: 1.618033988749894,
      unit: 'dimensionless',
      category: 'Mathematics',
    ),
  ];
}
