import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlinkingCursor extends StatefulWidget {
  const BlinkingCursor({super.key});
  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    if (!Platform.environment.containsKey('FLUTTER_TEST')) _controller.repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 2.0, height: 20.0, color: Colors.blueAccent),
    );
  }
}

class MathCursor {
  MathList list;
  int index;
  MathCursor(this.list, this.index);
}

class MathList {
  MathNode? parent;
  List<MathNode> nodes = [];

  MathList({this.parent});

  MathList clone(MathNode? newParent) {
    var res = MathList(parent: newParent);
    res.nodes = nodes.map((n) => n.clone(res)).toList();
    return res;
  }

  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    if (nodes.isEmpty) {
      bool isCursorHere = (cursor.list == this && cursor.index == 0);
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onCursorChanged(MathCursor(this, 0)),
        child: Container(
          width: isCursorHere ? 2.0 : 12.0,
          height: isCursorHere ? 20.0 : 16.0,
          decoration: isCursorHere ? null : BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 1.0),
            color: color.withOpacity(0.1),
          ),
          child: isCursorHere ? const BlinkingCursor() : null,
        ),
      );
    }

    List<Widget> children = [];
    for (int i = 0; i <= nodes.length; i++) {
      int idx = i;
      bool isCursorHere = (cursor.list == this && cursor.index == i);
      
      Widget gap = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onCursorChanged(MathCursor(this, idx));
        },
        child: Container(
          width: isCursorHere ? 2.0 : 0.0,
          color: Colors.transparent,
          child: isCursorHere ? const BlinkingCursor() : null,
        ),
      );
      children.add(gap);

      if (i < nodes.length) {
        children.add(nodes[i].buildWidget(cursor, style, color, onCursorChanged));
      }
    }
    return MathListWidget(children: children);
  }

  String toMathString() {
    return nodes.map((n) => n.toMathString()).join('');
  }
}

abstract class MathNode {
  MathList? parentList;
  MathNode(this.parentList);

  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged);
  String toMathString();
  MathNode clone(MathList? newParent);
  
  List<MathList> get slots => [];
}

class CharNode extends MathNode {
  String char;
  CharNode(this.char, {MathList? parentList}) : super(parentList);

  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (parentList != null) {
          int idx = parentList!.nodes.indexOf(this);
          onCursorChanged(MathCursor(parentList!, idx + 1));
        }
      },
      child: Text(char, style: style.copyWith(color: color)),
    );
  }

  @override
  String toMathString() => char;

  @override
  MathNode clone(MathList? newParent) => CharNode(char, parentList: newParent);
}

class FractionNode extends MathNode {
  late MathList numerator;
  late MathList denominator;

  FractionNode({MathList? parentList}) : super(parentList) {
    numerator = MathList(parent: this);
    denominator = MathList(parent: this);
  }

  @override
  List<MathList> get slots => [numerator, denominator];

  @override
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
  }

  @override
  String toMathString() => '(${numerator.toMathString()})/(${denominator.toMathString()})';

  @override
  MathNode clone(MathList? newParent) {
    var res = FractionNode(parentList: newParent);
    res.numerator = numerator.clone(res);
    res.denominator = denominator.clone(res);
    return res;
  }
}

class RootNode extends MathNode {
  late MathList degree;
  late MathList radicand;
  bool hasDegreeSlot;
  String? degreeText;

  RootNode({this.hasDegreeSlot = false, this.degreeText, MathList? parentList}) : super(parentList) {
    degree = MathList(parent: this);
    radicand = MathList(parent: this);
  }

  @override
  List<MathList> get slots => hasDegreeSlot ? [degree, radicand] : [radicand];

  @override
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
  }

  @override
  String toMathString() {
    if (hasDegreeSlot) {
      return 'nth_root(${degree.toMathString()}, ${radicand.toMathString()})';
    } else if (degreeText == '3') {
      return 'cbrt(${radicand.toMathString()})';
    } else {
      return 'sqrt(${radicand.toMathString()})';
    }
  }

  @override
  MathNode clone(MathList? newParent) {
    var res = RootNode(hasDegreeSlot: hasDegreeSlot, degreeText: degreeText, parentList: newParent);
    res.degree = degree.clone(res);
    res.radicand = radicand.clone(res);
    return res;
  }
}

class PowerNode extends MathNode {
  late MathList exponent;

  PowerNode({MathList? parentList}) : super(parentList) {
    exponent = MathList(parent: this);
  }

  @override
  List<MathList> get slots => [exponent];

  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final superStyle = style.copyWith(fontSize: style.fontSize! * 0.7);
    return PowerWidget(
      fontSize: style.fontSize!,
      child: exponent.buildWidget(cursor, superStyle, color, onCursorChanged),
    );
  }

  @override
  String toMathString() => '^(${exponent.toMathString()})';

  @override
  MathNode clone(MathList? newParent) {
    var res = PowerNode(parentList: newParent);
    res.exponent = exponent.clone(res);
    return res;
  }
}

class IntegralNode extends MathNode {
  late MathList lower;
  late MathList upper;
  late MathList body;

  IntegralNode({MathList? parentList}) : super(parentList) {
    lower = MathList(parent: this);
    upper = MathList(parent: this);
    body = MathList(parent: this);
  }

  @override
  List<MathList> get slots => [lower, upper, body];

  @override
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
  }

  @override
  String toMathString() => 'INT_EVALµ${body.toMathString()}µ${lower.toMathString()}µ${upper.toMathString()}µ';

  @override
  MathNode clone(MathList? newParent) {
    var res = IntegralNode(parentList: newParent);
    res.lower = lower.clone(res);
    res.upper = upper.clone(res);
    res.body = body.clone(res);
    return res;
  }
}

class SumNode extends MathNode {
  late MathList lower;
  late MathList upper;
  late MathList body;

  SumNode({MathList? parentList}) : super(parentList) {
    lower = MathList(parent: this);
    upper = MathList(parent: this);
    body = MathList(parent: this);
  }

  @override
  List<MathList> get slots => [lower, upper, body];

  @override
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
  }

  @override
  String toMathString() => 'sum(${body.toMathString()}, x, ${lower.toMathString()}, ${upper.toMathString()})';

  @override
  MathNode clone(MathList? newParent) {
    var res = SumNode(parentList: newParent);
    res.lower = lower.clone(res);
    res.upper = upper.clone(res);
    res.body = body.clone(res);
    return res;
  }
}

class MatrixNode extends MathNode {
  int rows;
  int cols;
  late List<List<MathList>> cells;

  MatrixNode({required this.rows, required this.cols, MathList? parentList}) : super(parentList) {
    cells = List.generate(rows, (r) => List.generate(cols, (c) => MathList(parent: this)));
  }

  @override
  List<MathList> get slots => cells.expand((row) => row).toList();

  int getRow(MathList list) {
    for (int r = 0; r < rows; r++) {
      if (cells[r].contains(list)) return r;
    }
    return 0;
  }

  int getCol(MathList list) {
    for (int r = 0; r < rows; r++) {
      int c = cells[r].indexOf(list);
      if (c != -1) return c;
    }
    return 0;
  }

  @override
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
  }

  @override
  String toMathString() {
    var rowsStr = cells.map((row) => '[' + row.map((c) {
      var s = c.toMathString();
      return s.isEmpty ? '0' : s;
    }).join(',') + ']').join(',');
    return '[$rowsStr]';
  }

  @override
  MathNode clone(MathList? newParent) {
    var res = MatrixNode(rows: rows, cols: cols, parentList: newParent);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        res.cells[r][c] = cells[r][c].clone(res);
      }
    }
    return res;
  }
}

class FunctionNode extends MathNode {
  String name;
  late MathList argument;

  FunctionNode(this.name, {MathList? parentList}) : super(parentList) {
    argument = MathList(parent: this);
  }

  @override
  List<MathList> get slots => [argument];

  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    return MathListWidget(
      children: [
        Text('$name(', style: style.copyWith(color: color)),
        argument.buildWidget(cursor, style, color, onCursorChanged),
        Text(')', style: style.copyWith(color: color)),
      ],
    );
  }

  @override
  String toMathString() => '$name(${argument.toMathString()})';

  @override
  MathNode clone(MathList? newParent) {
    var res = FunctionNode(name, parentList: newParent);
    res.argument = argument.clone(res);
    return res;
  }
}

class LogBaseNode extends MathNode {
  late MathList base;
  late MathList argument;

  LogBaseNode({MathList? parentList}) : super(parentList) {
    base = MathList(parent: this);
    argument = MathList(parent: this);
  }

  @override
  List<MathList> get slots => [base, argument];

  @override
  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    final subStyle = style.copyWith(fontSize: style.fontSize! * 0.6);
    return MathListWidget(
      children: [
        Text('log', style: style.copyWith(color: color)),
        SubscriptWidget(
          fontSize: style.fontSize!,
          child: base.buildWidget(cursor, subStyle, color, onCursorChanged),
        ),
        Text('(', style: style.copyWith(color: color)),
        argument.buildWidget(cursor, style, color, onCursorChanged),
        Text(')', style: style.copyWith(color: color)),
      ],
    );
  }

  @override
  String toMathString() => '(ln(${argument.toMathString()}) / ln(${base.toMathString()}))';

  @override
  MathNode clone(MathList? newParent) {
    var res = LogBaseNode(parentList: newParent);
    res.base = base.clone(res);
    res.argument = argument.clone(res);
    return res;
  }
}

class MathAST {
  late MathList root;
  late MathCursor cursor;

  MathAST() {
    root = MathList(parent: null);
    cursor = MathCursor(root, 0);
  }

  MathAST clone() {
    var ast = MathAST();
    ast.root = root.clone(null);
    ast.cursor = _findCursor(root, cursor, ast.root) ?? MathCursor(ast.root, 0);
    return ast;
  }

  MathCursor? _findCursor(MathList oldL, MathCursor oldC, MathList newL) {
    if (oldL == oldC.list) return MathCursor(newL, oldC.index);
    for (int i = 0; i < oldL.nodes.length; i++) {
      var oSlots = oldL.nodes[i].slots;
      var nSlots = newL.nodes[i].slots;
      for (int s = 0; s < oSlots.length; s++) {
        var res = _findCursor(oSlots[s], oldC, nSlots[s]);
        if (res != null) return res;
      }
    }
    return null;
  }

  void insert(String text) {
    if (text == '/') {
      _insertAndEnter(FractionNode(), 0);
    } else if (text == '∫(') {
      _insertAndEnter(IntegralNode(), 0);
    } else if (text == 'sum(') {
      _insertAndEnter(SumNode(), 0);
    } else if (text == '^') {
      _insertAndEnter(PowerNode(), 0);
    } else if (text == '^2') {
      var pow = PowerNode();
      pow.exponent.nodes.add(CharNode('2', parentList: pow.exponent));
      _insertNode(pow);
    } else if (text == '^3') {
      var pow = PowerNode();
      pow.exponent.nodes.add(CharNode('3', parentList: pow.exponent));
      _insertNode(pow);
    } else if (text == '^-1') {
      var pow = PowerNode();
      pow.exponent.nodes.add(CharNode('-', parentList: pow.exponent));
      pow.exponent.nodes.add(CharNode('1', parentList: pow.exponent));
      _insertNode(pow);
    } else if (text == '√(') {
      _insertAndEnter(RootNode(), 0);
    } else if (text == 'cbrt(') {
      var root = RootNode(degreeText: '3');
      _insertAndEnter(root, 0);
    } else if (text == 'nth_root(') {
      var root = RootNode(hasDegreeSlot: true);
      _insertAndEnter(root, 0);
    } else if (text == 'log_base(') {
      _insertAndEnter(LogBaseNode(), 0);
    } else if (text == 'matrix(') {
      _insertAndEnter(MatrixNode(rows: 3, cols: 3), 0);
    } else if (text == 'vector(') {
      _insertAndEnter(MatrixNode(rows: 3, cols: 1), 0);
    } else if (text.endsWith('(')) {
      var funcName = text.substring(0, text.length - 1);
      _insertAndEnter(FunctionNode(funcName), 0);
    } else if (text == '10^') {
      _insertNode(CharNode('1'));
      _insertNode(CharNode('0'));
      _insertAndEnter(PowerNode(), 0);
    } else if (text == 'e^') {
      _insertNode(CharNode('e'));
      _insertAndEnter(PowerNode(), 0);
    } else if (text == '*10^') {
      _insertNode(CharNode('×'));
      _insertNode(CharNode('1'));
      _insertNode(CharNode('0'));
      _insertAndEnter(PowerNode(), 0);
    } else {
      for (int i = 0; i < text.length; i++) {
        _insertNode(CharNode(text[i]));
      }
    }
  }

  void _insertNode(MathNode node) {
    node.parentList = cursor.list;
    cursor.list.nodes.insert(cursor.index, node);
    cursor.index++;
  }

  void _insertAndEnter(MathNode node, int slotIndex) {
    _insertNode(node);
    cursor.list = node.slots[slotIndex];
    cursor.index = 0;
  }

  void backspace() {
    if (cursor.index > 0) {
      var node = cursor.list.nodes[cursor.index - 1];
      if (node.slots.isNotEmpty) {
        cursor.list = node.slots.last;
        cursor.index = cursor.list.nodes.length;
      } else {
        cursor.list.nodes.removeAt(cursor.index - 1);
        cursor.index--;
      }
    } else if (cursor.list.parent != null) {
      var parentNode = cursor.list.parent!;
      var parentList = parentNode.parentList!;
      int pIndex = parentList.nodes.indexOf(parentNode);
      parentList.nodes.removeAt(pIndex);
      cursor.list = parentList;
      cursor.index = pIndex;
    }
  }

  void clear() {
    root.nodes.clear();
    cursor.list = root;
    cursor.index = 0;
  }

  void moveLeft() {
    if (cursor.index > 0) {
      var leftNode = cursor.list.nodes[cursor.index - 1];
      if (leftNode.slots.isNotEmpty) {
        cursor.list = leftNode.slots.last;
        cursor.index = cursor.list.nodes.length;
      } else {
        cursor.index--;
      }
    } else if (cursor.list.parent != null) {
      var pNode = cursor.list.parent!;
      var pList = pNode.parentList!;
      int slotIdx = pNode.slots.indexOf(cursor.list);
      if (slotIdx > 0) {
        cursor.list = pNode.slots[slotIdx - 1];
        cursor.index = cursor.list.nodes.length;
      } else {
        cursor.list = pList;
        cursor.index = pList.nodes.indexOf(pNode);
      }
    }
  }

  void moveRight() {
    if (cursor.index < cursor.list.nodes.length) {
      var rightNode = cursor.list.nodes[cursor.index];
      if (rightNode.slots.isNotEmpty) {
        cursor.list = rightNode.slots.first;
        cursor.index = 0;
      } else {
        cursor.index++;
      }
    } else if (cursor.list.parent != null) {
      var pNode = cursor.list.parent!;
      var pList = pNode.parentList!;
      int slotIdx = pNode.slots.indexOf(cursor.list);
      if (slotIdx < pNode.slots.length - 1) {
        cursor.list = pNode.slots[slotIdx + 1];
        cursor.index = 0;
      } else {
        cursor.list = pList;
        cursor.index = pList.nodes.indexOf(pNode) + 1;
      }
    }
  }

  void moveUp() {
    if (cursor.list.parent != null) {
      var pNode = cursor.list.parent!;
      if (pNode is FractionNode && cursor.list == pNode.denominator) {
        cursor.list = pNode.numerator;
        cursor.index = cursor.list.nodes.length;
        return;
      }
      if (pNode is MatrixNode) {
        int r = pNode.getRow(cursor.list);
        int c = pNode.getCol(cursor.list);
        if (r > 0) {
          cursor.list = pNode.cells[r - 1][c];
          cursor.index = cursor.list.nodes.length;
          return;
        }
      }
      moveLeft();
    }
  }

  void moveDown() {
    if (cursor.list.parent != null) {
      var pNode = cursor.list.parent!;
      if (pNode is FractionNode && cursor.list == pNode.numerator) {
        cursor.list = pNode.denominator;
        cursor.index = cursor.list.nodes.length;
        return;
      }
      if (pNode is MatrixNode) {
        int r = pNode.getRow(cursor.list);
        int c = pNode.getCol(cursor.list);
        if (r < pNode.rows - 1) {
          cursor.list = pNode.cells[r + 1][c];
          cursor.index = cursor.list.nodes.length;
          return;
        }
      }
      moveRight();
    }
  }

  String toExpression() {
    return root.toMathString();
  }
}


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
}

class SubscriptWidget extends SingleChildRenderObjectWidget {
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
