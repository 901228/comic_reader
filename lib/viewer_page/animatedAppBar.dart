import 'package:flutter/material.dart';

enum BarAlignment { top, bottom, left, right }

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
  final BarAlignment direction;

  @override
  Size get preferredSize => (child as PreferredSizeWidget).preferredSize;

  @override
  Widget build(BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    if (direction == BarAlignment.top)
      return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: Offset(0, -1)).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    else if (direction == BarAlignment.bottom)
      return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: Offset(0, 1)).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    else if (direction == BarAlignment.left)
      return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: Offset(-1, 0)).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    else if (direction == BarAlignment.right)
      return SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: Offset(1, 0)).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    else
      return Center(child: CircularProgressIndicator());
  }
}
