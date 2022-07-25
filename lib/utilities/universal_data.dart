import 'dart:ui';

import 'package:flutter/material.dart';

class UniversalData {
  static const screenColor = Colors.black87;
  static const whiteColor = Colors.white;
  static const hintTextColor = Colors.white70;
  static const greyColor = Colors.grey;
  static const lightBule = Colors.lightBlue;
  static const userActiveColor = Color.fromARGB(255, 115, 224, 121);
  static const divideColor = Color.fromARGB(255, 131, 131, 131);
  static const textFieldColor = Color.fromARGB(101, 102, 102, 102);
  static const senderColor = Color.fromARGB(137, 3, 168, 244);
  static const reciverColor = Color.fromARGB(166, 73, 73, 73);

  static const floatingButtonGradient = RadialGradient(
    colors: [lightBule, Color.fromARGB(255, 124, 194, 252)],
    tileMode: TileMode.mirror,
  );

  static const appBarGradient = LinearGradient(
      colors: [lightBule, Color.fromARGB(255, 124, 194, 252)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);
}
