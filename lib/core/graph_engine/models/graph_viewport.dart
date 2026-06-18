import 'dart:ui';

class GraphViewport {
  double minX;
  double maxX;
  double minY;
  double maxY;
  final Size size;

  GraphViewport({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.size,
  });

  double get width => size.width;
  double get height => size.height;

  /// Converts mathematical X to screen pixel X
  double toPixelX(double x) {
    return ((x - minX) / (maxX - minX)) * width;
  }

  /// Converts mathematical Y to screen pixel Y
  double toPixelY(double y) {
    return height - (((y - minY) / (maxY - minY)) * height);
  }

  /// Converts screen pixel X to mathematical X
  double toMathX(double px) {
    return minX + (px / width) * (maxX - minX);
  }

  /// Converts screen pixel Y to mathematical Y
  double toMathY(double py) {
    return maxY - (py / height) * (maxY - minY);
  }

  /// Shift viewport by pixel deltas
  void pan(double dx, double dy) {
    double mathDx = (dx / width) * (maxX - minX);
    double mathDy = (dy / height) * (maxY - minY);
    minX -= mathDx;
    maxX -= mathDx;
    minY += mathDy;
    maxY += mathDy;
  }

  /// Zoom viewport around a focal point (in screen pixels)
  void zoom(double scaleFactor, Offset focalPoint) {
    // Math coordinates of the focal point before zoom
    double fx = toMathX(focalPoint.dx);
    double fy = toMathY(focalPoint.dy);

    double newRangeX = (maxX - minX) * scaleFactor;
    double newRangeY = (maxY - minY) * scaleFactor;

    // Maintain position of focal point in math coordinates
    double ratioX = (focalPoint.dx) / width;
    double ratioY = (height - focalPoint.dy) / height;

    minX = fx - ratioX * newRangeX;
    maxX = minX + newRangeX;
    minY = fy - ratioY * newRangeY;
    maxY = minY + newRangeY;
  }
}
