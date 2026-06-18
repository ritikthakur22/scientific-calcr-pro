class UnitCategory {
  final String name;
  final List<String> units;
  final Map<String, double> baseConversion; // Conversion factor to base unit

  const UnitCategory({
    required this.name,
    required this.units,
    required this.baseConversion,
  });
}

class UnitConverterHelper {
  static const List<UnitCategory> categories = [
    UnitCategory(
      name: 'Length',
      units: ['Meters (m)', 'Kilometers (km)', 'Centimeters (cm)', 'Millimeters (mm)', 'Inches (in)', 'Feet (ft)', 'Miles (mi)'],
      baseConversion: {
        'Meters (m)': 1.0,
        'Kilometers (km)': 1000.0,
        'Centimeters (cm)': 0.01,
        'Millimeters (mm)': 0.001,
        'Inches (in)': 0.0254,
        'Feet (ft)': 0.3048,
        'Miles (mi)': 1609.34,
      },
    ),
    UnitCategory(
      name: 'Mass',
      units: ['Grams (g)', 'Kilograms (kg)', 'Milligrams (mg)', 'Pounds (lb)', 'Ounces (oz)'],
      baseConversion: {
        'Grams (g)': 1.0,
        'Kilograms (kg)': 1000.0,
        'Milligrams (mg)': 0.001,
        'Pounds (lb)': 453.592,
        'Ounces (oz)': 28.3495,
      },
    ),
    UnitCategory(
      name: 'Area',
      units: ['Square Meters (m²)', 'Square Kilometers (km²)', 'Square Feet (ft²)', 'Acres (ac)', 'Hectares (ha)'],
      baseConversion: {
        'Square Meters (m²)': 1.0,
        'Square Kilometers (km²)': 1000000.0,
        'Square Feet (ft²)': 0.092903,
        'Acres (ac)': 4046.86,
        'Hectares (ha)': 10000.0,
      },
    ),
    UnitCategory(
      name: 'Volume',
      units: ['Liters (L)', 'Milliliters (mL)', 'Cubic Meters (m³)', 'Gallons (gal)', 'Cups'],
      baseConversion: {
        'Liters (L)': 1.0,
        'Milliliters (mL)': 0.001,
        'Cubic Meters (m³)': 1000.0,
        'Gallons (gal)': 3.78541,
        'Cups': 0.236588,
      },
    ),
    UnitCategory(
      name: 'Temperature',
      units: ['Celsius (°C)', 'Fahrenheit (°F)', 'Kelvin (K)'],
      baseConversion: {}, // Temperature uses formula conversions instead of single multipliers
    ),
    UnitCategory(
      name: 'Speed',
      units: ['Meters/Second (m/s)', 'Kilometers/Hour (km/h)', 'Miles/Hour (mph)', 'Knots (kt)'],
      baseConversion: {
        'Meters/Second (m/s)': 1.0,
        'Kilometers/Hour (km/h)': 0.277778,
        'Miles/Hour (mph)': 0.44704,
        'Knots (kt)': 0.514444,
      },
    ),
    UnitCategory(
      name: 'Pressure',
      units: ['Pascals (Pa)', 'Bar', 'Atmospheres (atm)', 'PSI'],
      baseConversion: {
        'Pascals (Pa)': 1.0,
        'Bar': 100000.0,
        'Atmospheres (atm)': 101325.0,
        'PSI': 6894.76,
      },
    ),
    UnitCategory(
      name: 'Energy',
      units: ['Joules (J)', 'Kilojoules (kJ)', 'Calories (cal)', 'Kilocalories (kcal)', 'Watt-Hours (Wh)', 'Kilowatt-Hours (kWh)'],
      baseConversion: {
        'Joules (J)': 1.0,
        'Kilojoules (kJ)': 1000.0,
        'Calories (cal)': 4.184,
        'Kilocalories (kcal)': 4184.0,
        'Watt-Hours (Wh)': 3600.0,
        'Kilowatt-Hours (kWh)': 3600000.0,
      },
    ),
  ];

  static double convert(String category, String fromUnit, String toUnit, double value) {
    if (category == 'Temperature') {
      return _convertTemperature(fromUnit, toUnit, value);
    }

    final cat = categories.firstWhere((element) => element.name == category);
    final fromBaseMultiplier = cat.baseConversion[fromUnit]!;
    final toBaseMultiplier = cat.baseConversion[toUnit]!;

    // Convert value to base unit, then convert base unit to target unit
    double valInBase = value * fromBaseMultiplier;
    return valInBase / toBaseMultiplier;
  }

  static double _convertTemperature(String fromUnit, String toUnit, double value) {
    double tempInC = value;

    // Convert from source to Celsius
    if (fromUnit == 'Fahrenheit (°F)') {
      tempInC = (value - 32) * 5 / 9;
    } else if (fromUnit == 'Kelvin (K)') {
      tempInC = value - 273.15;
    }

    // Convert from Celsius to target
    if (toUnit == 'Celsius (°C)') {
      return tempInC;
    } else if (toUnit == 'Fahrenheit (°F)') {
      return (tempInC * 9 / 5) + 32;
    } else if (toUnit == 'Kelvin (K)') {
      return tempInC + 273.15;
    }

    return value;
  }
}
