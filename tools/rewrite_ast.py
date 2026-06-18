import re

with open('lib/core/math_engine/ast_render_node.dart', 'r') as f:
    content = f.read()

# Replace imports
old_imports = """import 'dart:io';
import 'package:flutter/material.dart';"""

new_imports = """import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';"""

content = content.replace(old_imports, new_imports)

# Replace MathList buildWidget
old_mathlist = """    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );"""

new_mathlist = """    return MathListWidget(children: children);"""

content = content.replace(old_mathlist, new_mathlist)

# Replace FractionNode
old_fraction = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final subStyle = style.copyWith(fontSize: style.fontSize! * 0.82);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: numerator.buildWidget(cursor, subStyle, color, onCursorChanged)),
            Container(height: 1.5, color: color, margin: const EdgeInsets.symmetric(vertical: 2.0)),
            Center(child: denominator.buildWidget(cursor, subStyle, color, onCursorChanged)),
          ],
        ),
      ),
    );
  }"""

new_fraction = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final subStyle = style.copyWith(fontSize: style.fontSize! * 0.82);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FractionWidget(
        color: color,
        numerator: numerator.buildWidget(cursor, subStyle, color, onCursorChanged),
        denominator: denominator.buildWidget(cursor, subStyle, color, onCursorChanged),
      ),
    );
  }"""

content = content.replace(old_fraction, new_fraction)

# Replace RootNode
old_root = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final subStyle = style.copyWith(fontSize: style.fontSize! * 0.95);
    final degStyle = style.copyWith(fontSize: style.fontSize! * 0.5);
    
    Widget degWidget;
    if (hasDegreeSlot) {
      degWidget = degree.buildWidget(cursor, degStyle, color, onCursorChanged);
    } else if (degreeText != null) {
      degWidget = Text(degreeText!, style: degStyle.copyWith(color: color));
    } else {
      degWidget = const SizedBox(width: 4); // invisible spacing for sqrt
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: Offset(0, style.fontSize! * 0.1),
          child: degWidget,
        ),
        Text('√', style: style.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: style.fontSize! * 1.1)),
        Transform.translate(
          offset: Offset(0, style.fontSize! * 0.1),
          child: Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: color, width: 1.5))),
            padding: const EdgeInsets.only(top: 2.0, left: 1.0, right: 2.0),
            child: radicand.buildWidget(cursor, subStyle, color, onCursorChanged),
          ),
        ),
      ],
    );
  }"""

new_root = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final subStyle = style.copyWith(fontSize: style.fontSize! * 0.95);
    final degStyle = style.copyWith(fontSize: style.fontSize! * 0.5);
    
    Widget degWidget;
    if (hasDegreeSlot) {
      degWidget = degree.buildWidget(cursor, degStyle, color, onCursorChanged);
    } else if (degreeText != null) {
      degWidget = Text(degreeText!, style: degStyle.copyWith(color: color));
    } else {
      degWidget = const SizedBox(width: 4); // invisible spacing for sqrt
    }

    return RootWidget(
      color: color,
      fontSize: style.fontSize!,
      degree: degWidget,
      radicand: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 2.0),
        child: radicand.buildWidget(cursor, subStyle, color, onCursorChanged),
      ),
    );
  }"""

content = content.replace(old_root, new_root)

# Replace PowerNode
old_power = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final superStyle = style.copyWith(fontSize: style.fontSize! * 0.7);
    return Transform.translate(
      offset: Offset(0.0, -style.fontSize! * 0.4),
      child: exponent.buildWidget(cursor, superStyle, color, onCursorChanged),
    );
  }"""

new_power = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final superStyle = style.copyWith(fontSize: style.fontSize! * 0.7);
    return PowerWidget(
      child: exponent.buildWidget(cursor, superStyle, color, onCursorChanged),
    );
  }"""

content = content.replace(old_power, new_power)

# Replace IntegralNode
old_integral = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final limitStyle = style.copyWith(fontSize: style.fontSize! * 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            upper.buildWidget(cursor, limitStyle, color, onCursorChanged),
            Text('∫', style: style.copyWith(fontSize: style.fontSize! * 1.5, color: color)),
            lower.buildWidget(cursor, limitStyle, color, onCursorChanged),
          ],
        ),
        body.buildWidget(cursor, style, color, onCursorChanged),
        Text(' dx', style: style.copyWith(color: color)),
      ],
    );
  }"""

new_integral = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final limitStyle = style.copyWith(fontSize: style.fontSize! * 0.6);
    return MathListWidget(
      children: [
        LimitsWidget(
          upper: upper.buildWidget(cursor, limitStyle, color, onCursorChanged),
          main: Text('∫', style: style.copyWith(fontSize: style.fontSize! * 1.5, color: color)),
          lower: lower.buildWidget(cursor, limitStyle, color, onCursorChanged),
        ),
        body.buildWidget(cursor, style, color, onCursorChanged),
        Text(' dx', style: style.copyWith(color: color)),
      ],
    );
  }"""

content = content.replace(old_integral, new_integral)

# Replace SumNode
old_sum = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final limitStyle = style.copyWith(fontSize: style.fontSize! * 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            upper.buildWidget(cursor, limitStyle, color, onCursorChanged),
            Text('Σ', style: style.copyWith(fontSize: style.fontSize! * 1.5, color: color)),
            lower.buildWidget(cursor, limitStyle, color, onCursorChanged),
          ],
        ),
        body.buildWidget(cursor, style, color, onCursorChanged),
      ],
    );
  }"""

new_sum = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final limitStyle = style.copyWith(fontSize: style.fontSize! * 0.6);
    return MathListWidget(
      children: [
        LimitsWidget(
          upper: upper.buildWidget(cursor, limitStyle, color, onCursorChanged),
          main: Text('Σ', style: style.copyWith(fontSize: style.fontSize! * 1.5, color: color)),
          lower: lower.buildWidget(cursor, limitStyle, color, onCursorChanged),
        ),
        body.buildWidget(cursor, style, color, onCursorChanged),
      ],
    );
  }"""

content = content.replace(old_sum, new_sum)

# Replace MatrixNode
old_matrix = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(vertical: BorderSide(color: color, width: 1.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: cells.map((row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map((cell) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: cell.buildWidget(cursor, style, color, onCursorChanged),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }"""

new_matrix = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    return MatrixLayoutWidget(
      child: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(vertical: BorderSide(color: color, width: 1.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: cells.map((row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: row.map((cell) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: cell.buildWidget(cursor, style, color, onCursorChanged),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }"""

content = content.replace(old_matrix, new_matrix)

# Replace FunctionNode
old_func = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$name(', style: style.copyWith(color: color)),
        argument.buildWidget(cursor, style, color, onCursorChanged),
        Text(')', style: style.copyWith(color: color)),
      ],
    );
  }"""

new_func = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    return MathListWidget(
      children: [
        Text('$name(', style: style.copyWith(color: color)),
        argument.buildWidget(cursor, style, color, onCursorChanged),
        Text(')', style: style.copyWith(color: color)),
      ],
    );
  }"""

content = content.replace(old_func, new_func)

# Replace LogBaseNode
old_log = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final subStyle = style.copyWith(fontSize: style.fontSize! * 0.6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('log', style: style.copyWith(color: color)),
        Transform.translate(
          offset: Offset(0, style.fontSize! * 0.3),
          child: base.buildWidget(cursor, subStyle, color, onCursorChanged),
        ),
        Text('(', style: style.copyWith(color: color)),
        argument.buildWidget(cursor, style, color, onCursorChanged),
        Text(')', style: style.copyWith(color: color)),
      ],
    );
  }"""

new_log = """  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final subStyle = style.copyWith(fontSize: style.fontSize! * 0.6);
    return MathListWidget(
      children: [
        Text('log', style: style.copyWith(color: color)),
        SubscriptWidget(
          child: base.buildWidget(cursor, subStyle, color, onCursorChanged),
        ),
        Text('(', style: style.copyWith(color: color)),
        argument.buildWidget(cursor, style, color, onCursorChanged),
        Text(')', style: style.copyWith(color: color)),
      ],
    );
  }"""

content = content.replace(old_log, new_log)

layout_classes = """

class MathListWidget extends MultiChildRenderObjectWidget {
  MathListWidget({Key? key, required List<Widget> children}) : super(key: key, children: children);
  @override
  RenderMathList createRenderObject(BuildContext context) => RenderMathList();
}

class MathListParentData extends ContainerBoxParentData<RenderBox> {}

class RenderMathList extends RenderBox with ContainerRenderObjectMixin<RenderBox, MathListParentData>, RenderBoxContainerDefaultsMixin<RenderBox, MathListParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MathListParentData) {
      child.parentData = MathListParentData();
    }
  }

  @override
  void performLayout() {
    double width = 0;
    double aboveBaseline = 0;
    double belowBaseline = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints, parentUsesSize: true);
      double childBaseline = child.getDistanceToActualBaseline(TextBaseline.alphabetic) ?? child.size.height;
      aboveBaseline = math.max(aboveBaseline, childBaseline);
      belowBaseline = math.max(belowBaseline, child.size.height - childBaseline);
      final childParentData = child.parentData as MathListParentData;
      childParentData.offset = Offset(width, 0); 
      width += child.size.width;
      child = childParentData.nextSibling;
    }

    double height = aboveBaseline + belowBaseline;
    size = constraints.constrain(Size(width, height));

    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as MathListParentData;
      double childBaseline = child.getDistanceToActualBaseline(TextBaseline.alphabetic) ?? child.size.height;
      double yOffset = aboveBaseline - childBaseline;
      childParentData.offset = Offset(childParentData.offset.dx, yOffset);
      child = childParentData.nextSibling;
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double aboveBaseline = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      double childBaseline = child.getDistanceToActualBaseline(TextBaseline.alphabetic) ?? child.size.height;
      final childParentData = child.parentData as MathListParentData;
      aboveBaseline = math.max(aboveBaseline, childParentData.offset.dy + childBaseline);
      child = childParentData.nextSibling;
    }
    return aboveBaseline;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class FractionParentData extends ContainerBoxParentData<RenderBox> {}

class FractionWidget extends MultiChildRenderObjectWidget {
  final Color color;
  FractionWidget({Key? key, required Widget numerator, required Widget denominator, required this.color}) 
      : super(key: key, children: [numerator, denominator]);
  @override
  RenderFraction createRenderObject(BuildContext context) => RenderFraction(color: color);
  @override
  void updateRenderObject(BuildContext context, RenderFraction renderObject) {
    renderObject.color = color;
  }
}

class RenderFraction extends RenderBox with ContainerRenderObjectMixin<RenderBox, FractionParentData>, RenderBoxContainerDefaultsMixin<RenderBox, FractionParentData> {
  Color color;
  RenderFraction({required this.color});

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FractionParentData) {
      child.parentData = FractionParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox numerator = firstChild!;
    RenderBox denominator = (numerator.parentData as FractionParentData).nextSibling!;

    numerator.layout(constraints, parentUsesSize: true);
    denominator.layout(constraints, parentUsesSize: true);

    double width = math.max(numerator.size.width, denominator.size.width) + 8.0;
    double height = numerator.size.height + denominator.size.height + 4.0;

    size = constraints.constrain(Size(width, height));

    final numPD = numerator.parentData as FractionParentData;
    numPD.offset = Offset((width - numerator.size.width) / 2, 0);

    final denPD = denominator.parentData as FractionParentData;
    denPD.offset = Offset((width - denominator.size.width) / 2, numerator.size.height + 4.0);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    RenderBox numerator = firstChild!;
    return numerator.size.height + 4.0;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
    RenderBox numerator = firstChild!;
    double lineY = offset.dy + numerator.size.height + 2.0;
    Paint paint = Paint()..color = color..strokeWidth = 1.5;
    context.canvas.drawLine(Offset(offset.dx + 2, lineY), Offset(offset.dx + size.width - 2, lineY), paint);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class PowerWidget extends SingleChildRenderObjectWidget {
  PowerWidget({Key? key, required Widget child}) : super(key: key, child: child);
  @override
  RenderPower createRenderObject(BuildContext context) => RenderPower();
}

class RenderPower extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height * 1.5));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double childBaseline = child!.getDistanceToActualBaseline(baseline) ?? child!.size.height;
    return childBaseline + child!.size.height * 0.5;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }
}

class SubscriptWidget extends SingleChildRenderObjectWidget {
  SubscriptWidget({Key? key, required Widget child}) : super(key: key, child: child);
  @override
  RenderSubscript createRenderObject(BuildContext context) => RenderSubscript();
}

class RenderSubscript extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height * 1.5));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double childBaseline = child!.getDistanceToActualBaseline(baseline) ?? child!.size.height;
    return childBaseline - child!.size.height * 0.3;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset + Offset(0, size.height - child!.size.height));
  }
}

class RootWidget extends MultiChildRenderObjectWidget {
  final Color color;
  final double fontSize;
  RootWidget({Key? key, required Widget degree, required Widget radicand, required this.color, required this.fontSize}) 
      : super(key: key, children: [degree, radicand]);
  @override
  RenderRoot createRenderObject(BuildContext context) => RenderRoot(color: color, fontSize: fontSize);
  @override
  void updateRenderObject(BuildContext context, RenderRoot renderObject) {
    renderObject.color = color;
    renderObject.fontSize = fontSize;
  }
}

class RenderRoot extends RenderBox with ContainerRenderObjectMixin<RenderBox, FractionParentData>, RenderBoxContainerDefaultsMixin<RenderBox, FractionParentData> {
  Color color;
  double fontSize;
  RenderRoot({required this.color, required this.fontSize});

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FractionParentData) {
      child.parentData = FractionParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox degree = firstChild!;
    RenderBox radicand = (degree.parentData as FractionParentData).nextSibling!;

    degree.layout(constraints, parentUsesSize: true);
    radicand.layout(constraints, parentUsesSize: true);

    double rootSymbolWidth = fontSize * 0.8;
    double degreeWidth = degree.size.width;
    double rootSpacing = math.max(degreeWidth, fontSize * 0.3) + rootSymbolWidth;
    
    double radicandTopPadding = 2.0;
    double overlineHeight = 1.5;

    double width = rootSpacing + radicand.size.width + 2.0;
    double radicandTop = math.max(degree.size.height - fontSize * 0.5, overlineHeight + radicandTopPadding);
    double height = radicandTop + radicand.size.height;

    size = constraints.constrain(Size(width, height));

    final degreePD = degree.parentData as FractionParentData;
    degreePD.offset = Offset(0, radicandTop - degree.size.height * 0.5);

    final radPD = radicand.parentData as FractionParentData;
    radPD.offset = Offset(rootSpacing, radicandTop);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    RenderBox radicand = (firstChild!.parentData as FractionParentData).nextSibling!;
    final radPD = radicand.parentData as FractionParentData;
    double radBaseline = radicand.getDistanceToActualBaseline(baseline) ?? radicand.size.height;
    return radPD.offset.dy + radBaseline;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox degree = firstChild!;
    RenderBox radicand = (degree.parentData as FractionParentData).nextSibling!;
    final radPD = radicand.parentData as FractionParentData;
    
    defaultPaint(context, offset);

    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    double rootSpacing = radPD.offset.dx;
    double startX = offset.dx + rootSpacing - fontSize * 0.8;
    double midX = offset.dx + rootSpacing - fontSize * 0.4;
    double topY = offset.dy + radPD.offset.dy - 2.0;
    double bottomY = offset.dy + radPD.offset.dy + radicand.size.height - 2.0;
    
    Path path = Path();
    path.moveTo(startX, bottomY - fontSize * 0.4);
    path.lineTo(midX, bottomY);
    path.lineTo(offset.dx + rootSpacing, topY);
    path.lineTo(offset.dx + rootSpacing + radicand.size.width + 2.0, topY);
    
    context.canvas.drawPath(path, paint);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class LimitsWidget extends MultiChildRenderObjectWidget {
  LimitsWidget({Key? key, required Widget upper, required Widget main, required Widget lower}) 
      : super(key: key, children: [upper, main, lower]);
  @override
  RenderLimits createRenderObject(BuildContext context) => RenderLimits();
}

class RenderLimits extends RenderBox with ContainerRenderObjectMixin<RenderBox, FractionParentData>, RenderBoxContainerDefaultsMixin<RenderBox, FractionParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FractionParentData) {
      child.parentData = FractionParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox upper = firstChild!;
    RenderBox main = (upper.parentData as FractionParentData).nextSibling!;
    RenderBox lower = (main.parentData as FractionParentData).nextSibling!;

    upper.layout(constraints, parentUsesSize: true);
    main.layout(constraints, parentUsesSize: true);
    lower.layout(constraints, parentUsesSize: true);

    double width = math.max(upper.size.width, math.max(main.size.width, lower.size.width));
    double height = upper.size.height + main.size.height + lower.size.height;

    size = constraints.constrain(Size(width, height));

    final upperPD = upper.parentData as FractionParentData;
    upperPD.offset = Offset((width - upper.size.width) / 2, 0);

    final mainPD = main.parentData as FractionParentData;
    mainPD.offset = Offset((width - main.size.width) / 2, upper.size.height);

    final lowerPD = lower.parentData as FractionParentData;
    lowerPD.offset = Offset((width - lower.size.width) / 2, upper.size.height + main.size.height);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    RenderBox upper = firstChild!;
    RenderBox main = (upper.parentData as FractionParentData).nextSibling!;
    final mainPD = main.parentData as FractionParentData;
    double mainBaseline = main.getDistanceToActualBaseline(baseline) ?? main.size.height;
    return mainPD.offset.dy + mainBaseline;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class MatrixLayoutWidget extends SingleChildRenderObjectWidget {
  MatrixLayoutWidget({Key? key, required Widget child}) : super(key: key, child: child);
  @override
  RenderMatrixLayout createRenderObject(BuildContext context) => RenderMatrixLayout();
}

class RenderMatrixLayout extends RenderProxyBox {
  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return size.height / 2 + 6.0; 
  }
}
"""

content += layout_classes

with open('lib/core/math_engine/ast_render_node.dart', 'w') as f:
    f.write(content)

