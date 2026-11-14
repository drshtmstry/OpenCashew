import 'dart:math';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BalancedTagRowParentData extends ContainerBoxParentData<RenderBox> {}

class RenderBalancedTagRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BalancedTagRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BalancedTagRowParentData> {
  RenderBalancedTagRow({
    List<RenderBox>? children,
  }) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BalancedTagRowParentData) {
      child.parentData = BalancedTagRowParentData();
    }
  }

  @override
  void performLayout() {
    double width = constraints.maxWidth;
    double currentX = 0;
    double maxHeight = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as BalancedTagRowParentData;
      child.layout(
        BoxConstraints(
          maxWidth: max(0.0, width - currentX),
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true,
      );

      if (currentX + child.size.width <= width || currentX == 0) {
        childParentData.offset = Offset(currentX, 0);
        currentX += child.size.width + 4;
        maxHeight = max(maxHeight, child.size.height);
      } else {
        childParentData.offset = Offset(width + 1000, 0);
      }

      child = childParentData.nextSibling;
    }

    size = constraints.constrain(Size(currentX, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as BalancedTagRowParentData;
      if (childParentData.offset.dx < constraints.maxWidth) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class BalancedTagRow extends MultiChildRenderObjectWidget {
  BalancedTagRow({
    Key? key,
    List<Widget> children = const <Widget>[],
  }) : super(key: key, children: children);

  @override
  RenderBalancedTagRow createRenderObject(BuildContext context) {
    return RenderBalancedTagRow();
  }
}

class TransactionIconTag extends StatelessWidget {
  const TransactionIconTag({
    required this.tag,
    this.onTap,
    super.key,
  });

  final TransactionTag tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color chipColor = tag.colour != null
        ? HexColor(tag.colour)
        : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsetsDirectional.only(end: 4),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 5,
        vertical: 1.5,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.18),
        borderRadius: BorderRadiusDirectional.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.emojiIconName != null || tag.iconName != null) ...[
            CategoryIcon(
              categoryPk: '-1',
              size: 12,
              category: null,
              label: false,
              labelShorten: false,
              outline: false,
              emojiIconName: tag.emojiIconName,
              iconName: tag.iconName,
              colorIconName: tag.colour,
              noBackground: true,
              margin: EdgeInsetsDirectional.zero,
            ),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: TextFont(
              text: tag.name,
              fontSize: 11,
              textColor: getColor(context, 'black').withOpacity(0.75),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCustomTagsRow extends StatelessWidget {
  const TransactionCustomTagsRow({
    required this.transactionPk,
    super.key,
  });

  final String transactionPk;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionTag>>(
      stream: database.watchTagsForTransaction(transactionPk),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        List<TransactionTag> tags = snapshot.data!;
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 2.0),
          child: BalancedTagRow(
            children: tags.map((t) => TransactionIconTag(tag: t)).toList(),
          ),
        );
      },
    );
  }
}
