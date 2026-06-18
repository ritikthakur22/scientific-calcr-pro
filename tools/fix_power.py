with open('lib/core/math_engine/ast_render_node.dart', 'r') as f:
    content = f.read()

# Replace PowerWidget usage
old_power_usage = """    return PowerWidget(
      child: exponent.buildWidget(cursor, superStyle, color, onCursorChanged),
    );"""
new_power_usage = """    return PowerWidget(
      fontSize: style.fontSize!,
      child: exponent.buildWidget(cursor, superStyle, color, onCursorChanged),
    );"""
content = content.replace(old_power_usage, new_power_usage)

# Replace SubscriptWidget usage
old_sub_usage = """        SubscriptWidget(
          child: base.buildWidget(cursor, subStyle, color, onCursorChanged),
        ),"""
new_sub_usage = """        SubscriptWidget(
          fontSize: style.fontSize!,
          child: base.buildWidget(cursor, subStyle, color, onCursorChanged),
        ),"""
content = content.replace(old_sub_usage, new_sub_usage)

# Replace PowerWidget class
old_power_class = """class PowerWidget extends SingleChildRenderObjectWidget {
  PowerWidget({Key? key, required Widget child}) : super(key: key, child: child);
  @override
  RenderPower createRenderObject(BuildContext context) => RenderPower();
}

class RenderPower extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height * 1.8));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double childBaseline = child!.getDistanceToActualBaseline(baseline) ?? child!.size.height;
    return childBaseline + child!.size.height * 0.8;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }
}"""
new_power_class = """class PowerWidget extends SingleChildRenderObjectWidget {
  final double fontSize;
  PowerWidget({Key? key, required this.fontSize, required Widget child}) : super(key: key, child: child);
  @override
  RenderPower createRenderObject(BuildContext context) => RenderPower(fontSize: fontSize);
  @override
  void updateRenderObject(BuildContext context, RenderPower renderObject) {
    renderObject.fontSize = fontSize;
  }
}

class RenderPower extends RenderProxyBox {
  double fontSize;
  RenderPower({required this.fontSize});

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height + fontSize * 0.8));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double childBaseline = child!.getDistanceToActualBaseline(baseline) ?? child!.size.height;
    return childBaseline + fontSize * 0.6;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }
}"""
content = content.replace(old_power_class, new_power_class)

# Replace SubscriptWidget class
old_sub_class = """class SubscriptWidget extends SingleChildRenderObjectWidget {
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
}"""
new_sub_class = """class SubscriptWidget extends SingleChildRenderObjectWidget {
  final double fontSize;
  SubscriptWidget({Key? key, required this.fontSize, required Widget child}) : super(key: key, child: child);
  @override
  RenderSubscript createRenderObject(BuildContext context) => RenderSubscript(fontSize: fontSize);
  @override
  void updateRenderObject(BuildContext context, RenderSubscript renderObject) {
    renderObject.fontSize = fontSize;
  }
}

class RenderSubscript extends RenderProxyBox {
  double fontSize;
  RenderSubscript({required this.fontSize});

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height + fontSize * 0.5));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double childBaseline = child!.getDistanceToActualBaseline(baseline) ?? child!.size.height;
    return childBaseline - fontSize * 0.3;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset + Offset(0, size.height - child!.size.height));
  }
}"""
content = content.replace(old_sub_class, new_sub_class)

with open('lib/core/math_engine/ast_render_node.dart', 'w') as f:
    f.write(content)

