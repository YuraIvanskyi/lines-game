import 'package:flutter/material.dart';

/// Arcade kit. Values match `idea/art-direction.md`.
abstract final class InkTheme {
  static const skyTop = Color(0xFF0B4FBE);
  static const skyBottom = Color(0xFF08347A);
  static const sun = Color(0xFFFFC107);
  static const sunDeep = Color(0xFFF39C12);
  static const sunLip = Color(0xFFC47D00);
  static const blueFace = Color(0xFF1E88E5);
  static const blueDeep = Color(0xFF1565C0);
  static const blueLip = Color(0xFF0D47A1);
  static const greenFace = Color(0xFF43C94A);
  static const greenDeep = Color(0xFF2E9E34);
  static const greenLip = Color(0xFF1B7A24);
  static const pinkFace = Color(0xFFFF4D8D);
  static const pinkDeep = Color(0xFFE23478);
  static const pinkLip = Color(0xFFB51A58);
  static const paper = Color(0xFFB8F3E8);
  static const field = Color(0xFF0E3A86);
  static const panel = Color(0xFF12356E);
  static const ink = Color(0xFF102A4C);
  static const cloud = Color(0xFFFFFFFF);
  static const foam = Color(0x332B7BFF);
  static const sunGlow = Color(0x33FFC107);
  static const muted = Color(0xFFD6ECFF);
  static const mute = Color(0xFF7C8AA3);
  static const quiet = Color(0xFF3D7AD6);
  static const wall = Color(0xFF071E4A);
  static const target = Color(0xFFFFC107);
  static const anchor = Color(0xFFFFFFFF);
  static const inks = <Color>[
    pinkFace,
    Color(0xFF3DDC97),
    Color(0xFFFFC83D),
    Color(0xFF7EC8FF),
  ];

  static const quietRadius = 0.10;
  static const wallExtent = 0.62;
  static const wallRadius = 0.14;
  static const dotRadius = 0.20;
  static const strokeWidth = 0.18;

  /// Black margin outside a chain line and dot.
  static const chainOutline = 0.03;
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
