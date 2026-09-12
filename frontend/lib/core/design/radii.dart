import 'package:flutter/material.dart';

class AppRadii {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double round = 999;

  static const BorderRadius button = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius buttonCompact = BorderRadius.all(Radius.circular(md));
  static const BorderRadius input = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius cardCompact = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheet = BorderRadius.vertical(top: Radius.circular(xxl));
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(round));
  static const BorderRadius badge = BorderRadius.all(Radius.circular(round));
  static const BorderRadius avatar = BorderRadius.all(Radius.circular(round));
  static const BorderRadius fab = BorderRadius.all(Radius.circular(round));
}

extension BorderRadiusExtensions on BorderRadius {
  BorderRadius copyWithTop(double radius) => BorderRadius.vertical(top: Radius.circular(radius));
  BorderRadius copyWithBottom(double radius) => BorderRadius.vertical(bottom: Radius.circular(radius));
}