import 'package:flutter/material.dart';

/// Placeholder inks. Phase 5 replaces these timings and colors from the art note.
abstract final class InkTheme {
  static const paper = Color(0xFFF6F3EE);
  static const ink = Color(0xFF1C1B19);
  static const quiet = Color(0xFFC5BEB4);
  static const wall = Color(0xFF2A2826);
  static const target = Color(0xFFE23B3B);
  static const anchor = Color(0xFF1C1B19);
  static const inks = <Color>[
    Color(0xFF0B7A3B),
    Color(0xFFE07A12),
    Color(0xFF8C2F39),
    Color(0xFF1D4E89),
  ];

  static const drawDuration = Duration(milliseconds: 280);
}
