import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Cues for a committed growth, a rejected tap, a turn pass, and a loss.
abstract class GameFeel {
  const GameFeel();

  void growth();
  void illegal();
  void passTurn();
  void loss();
  void dispose() {}
}

class SilentFeel extends GameFeel {
  const SilentFeel();

  @override
  void growth() {}

  @override
  void illegal() {}

  @override
  void passTurn() {}

  @override
  void loss() {}
}

class DeviceFeel extends GameFeel {
  final Map<String, AudioPlayer> _players = {};

  @override
  void growth() {
    HapticFeedback.lightImpact();
    _play('growth');
  }

  @override
  void illegal() {
    HapticFeedback.heavyImpact();
    _play('illegal');
  }

  @override
  void passTurn() {
    HapticFeedback.selectionClick();
    _play('pass');
  }

  @override
  void loss() {
    HapticFeedback.mediumImpact();
    _play('loss');
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }

  void _play(String name) {
    final player = _players.putIfAbsent(name, AudioPlayer.new);
    player.play(AssetSource('sounds/$name.wav')).catchError((_) {});
  }
}
