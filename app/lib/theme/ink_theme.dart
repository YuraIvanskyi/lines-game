import 'package:flutter/material.dart';

/// Pop theme. Values match `idea/art-direction.md`.
abstract final class InkTheme {
  static const skyTop = Color(0xFF6B4DFF);
  static const skyBottom = Color(0xFFFF6BB5);
  static const sun = Color(0xFFFFE14A);
  static const paper = Color(0xFFFFF6E4);
  static const ink = Color(0xFF24143A);
  static const cloud = Color(0xFFFFFFFF);
  static const foam = Color(0x33FFFFFF);
  static const sunGlow = Color(0x55FFE14A);
  static const muted = Color(0xFFF3E9FF);
  static const quiet = Color(0xFFE7DCFF);
  static const wall = Color(0xFF3A2770);
  static const target = Color(0xFFFF2D78);
  static const anchor = Color(0xFF24143A);
  static const inks = <Color>[
    Color(0xFFFF4D8D),
    Color(0xFF3DDC97),
    Color(0xFFFFC83D),
    Color(0xFF5B8CFF),
  ];

  static const quietRadius = 0.08;
  static const wallExtent = 0.62;
  static const wallRadius = 0.14;
  static const dotRadius = 0.16;
  static const strokeWidth = 0.14;
  static const markWidth = 0.07;
  static const headRadius = 0.28;
  static const tailExtent = 0.50;
  static const tailRadius = 0.08;
  static const targetWidth = 0.055;
  static const targetRadiusMin = 0.20;
  static const targetRadiusMax = 0.26;
  static const pendingRadius = 0.32;
  static const hitReach = 0.48;
  static const endScaleStart = 0.86;
  static const passScaleStart = 0.96;
  static const lossScaleStart = 0.92;

  static const drawDuration = Duration(milliseconds: 280);
  static const drawCurve = Curves.easeOutCubic;
  static const pulseDuration = Duration(milliseconds: 900);
  static const pulseCurve = Curves.easeInOut;
  static const endDuration = Duration(milliseconds: 180);
  static const endCurve = Curves.easeOutBack;
  static const passDuration = Duration(milliseconds: 200);
  static const passCurve = Curves.easeOutCubic;
  static const lossDuration = Duration(milliseconds: 320);
  static const lossCurve = Curves.easeOutBack;
}
