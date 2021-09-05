import 'package:flutter/material.dart';

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  AnimatedAppBar({
    required this.child,
    required this.controller,
    required this.visible,
    required this.direction,
  });

  final Widget child;
  final AnimationController controller;
  final bool visible;
  final TextDirection direction;

  @override
  Size get preferredSize => (child as PreferredSizeWidget).preferredSize;

  @override
  Widget build(BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    return direction == TextDirection.ltr
        ? SlideTransition(
            position:
                Tween<Offset>(begin: Offset.zero, end: Offset(0, -1)).animate(
              CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
            ),
            child: child,
          )
        : SlideTransition(
            position:
                Tween<Offset>(begin: Offset.zero, end: Offset(0, 1)).animate(
              CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
            ),
            child: child,
          );
  }
}
