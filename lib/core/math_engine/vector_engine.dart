import 'dart:math' as math;

class Vector {
  final List<double> components;

  Vector(this.components) {
    if (components.length != 2 && components.length != 3) {
      throw ArgumentError("Vector must be 2D or 3D.");
    }
  }

  int get dimension => components.length;

  double get dx => components[0];
  double get dy => components[1];
  double get dz => dimension == 3 ? components[2] : 0.0;

  double magnitude() {
    double sum = components.fold(0.0, (prev, val) => prev + val * val);
    return math.sqrt(sum);
  }

  Vector unit() {
    double mag = magnitude();
    if (mag == 0) throw ArgumentError("Cannot find unit vector of zero vector.");
    return Vector(components.map((val) => val / mag).toList());
  }

  double dot(Vector other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Vectors must have the same dimension for dot product.");
    }
    double sum = 0.0;
    for (int i = 0; i < dimension; i++) {
      sum += components[i] * other.components[i];
    }
    return sum;
  }

  Vector cross(Vector other) {
    if (dimension != 3 || other.dimension != 3) {
      throw ArgumentError("Cross product is only defined for 3D vectors.");
    }
    return Vector([
      dy * other.dz - dz * other.dy,
      dz * other.dx - dx * other.dz,
      dx * other.dy - dy * other.dx,
    ]);
  }

  double angleBetween(Vector other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Vectors must have the same dimension.");
    }
    double magProd = magnitude() * other.magnitude();
    if (magProd == 0) return 0.0;
    double cosTheta = dot(other) / magProd;
    // Clamp to [-1.0, 1.0] to prevent rounding errors causing NaN in acos
    cosTheta = cosTheta.clamp(-1.0, 1.0);
    return math.acos(cosTheta); // Returns angle in radians
  }

  Vector add(Vector other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Vectors must have the same dimension.");
    }
    return Vector(List.generate(dimension, (i) => components[i] + other.components[i]));
  }

  Vector subtract(Vector other) {
    if (dimension != other.dimension) {
      throw ArgumentError("Vectors must have the same dimension.");
    }
    return Vector(List.generate(dimension, (i) => components[i] - other.components[i]));
  }

  Vector scale(double scalar) {
    return Vector(components.map((val) => val * scalar).toList());
  }

  @override
  String toString() {
    return '[${components.map((v) => v.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '')).join(", ")}]';
  }
}
