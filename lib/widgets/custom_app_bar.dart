import 'package:flutter/material.dart';

import '../utilities/universal_data.dart';

class CustomAppBar extends StatelessWidget {
  CustomAppBar(
      {required this.title,
      required this.leading,
      required this.actions,
      required this.centertile});

  final Widget title;
  final List<Widget> actions;
  final Widget leading;
  final bool centertile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: UniversalData.greyColor,
              style: BorderStyle.solid,
              width: 1.4),
        ),
      ),
      child: AppBar(
        backgroundColor: UniversalData.screenColor,
        title: title,
        actions: actions,
        centerTitle: centertile,
        leading: leading,
      ),
    );
  }
}
