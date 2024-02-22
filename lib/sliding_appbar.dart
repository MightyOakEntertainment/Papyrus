import 'package:flutter/material.dart';

class SlidingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SlidingAppBar({super.key,
    required this.appBar,
    required this.visible,
  });

  final PreferredSizeWidget appBar;
  final bool visible;

  @override
  Size get preferredSize => appBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // when visible is true appbar will show with animation and visa versa
      height: visible ? appBar.preferredSize.height : 0,
      duration: const Duration(milliseconds: 400),
      child: appBar,
    );
  }
}