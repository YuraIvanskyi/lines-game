import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rules/rules.dart';

import 'home/home_page.dart';
import 'home/how_to_page.dart';
import 'home/info_page.dart';
import 'home/settings_page.dart';
import 'home/setup_page.dart';
import 'leave_app.dart';
import 'settings/app_settings.dart';
import 'settings/copy.dart';
import 'table/table_page.dart';
import 'theme/game_feel.dart';
import 'theme/ink_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final settingsStore = SharedPrefsSettingsStore();
  final settings = await settingsStore.load();
  runApp(LinesApp(settingsStore: settingsStore, initialSettings: settings));
}

class LinesApp extends StatefulWidget {
  const LinesApp({super.key, this.seed, this.mode = classicMode, this.onExit, this.settingsStore, this.initialSettings});

  final int? seed;
  final GameMode mode;
  final VoidCallback? onExit;
  final SettingsStore? settingsStore;
  final AppSettings? initialSettings;

  @override
  State<LinesApp> createState() => _LinesAppState();
}

enum _Place { home, howTo, setup, settings, info, table }

class _LinesAppState extends State<LinesApp> {
  _Place _place = _Place.home;
  List<Player> _players = defaultPlayers;
  late int _tableSeed = widget.seed ?? DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
  late AppSettings _settings = widget.initialSettings ?? AppSettings.defaults;
  late final SettingsStore _store = widget.settingsStore ?? MemorySettingsStore();
  late final DeviceFeel _feel = DeviceFeel(soundOn: () => _settings.sound);

  @override
  void dispose() {
    _feel.dispose();
    super.dispose();
  }

  void _playDefault() {
    final copy = Copy.forLanguage(_settings.language);
    setState(() {
      _players = [
        Player(id: 'p1', name: copy.player(1)),
        Player(id: 'p2', name: copy.player(2)),
      ];
      _tableSeed = _nextSeed();
      _place = _Place.table;
    });
  }

  void _playCustom(List<Player> players) {
    setState(() {
      _players = players;
      _tableSeed = _nextSeed();
      _place = _Place.table;
    });
  }

  int _nextSeed() => widget.seed ?? DateTime.now().microsecondsSinceEpoch & 0x7fffffff;

  void _home() => setState(() => _place = _Place.home);

  void _saveSettings(AppSettings next) {
    unawaited(_persist(next));
  }

  Future<void> _persist(AppSettings next) async {
    await _store.save(next);
    if (!mounted) return;
    setState(() => _settings = next);
  }

  @override
  Widget build(BuildContext context) {
    return AppCopy(
      copy: Copy.forLanguage(_settings.language),
      child: MaterialApp(
        title: 'ENDS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Nunito',
          colorScheme: ColorScheme.fromSeed(seedColor: InkTheme.skyTop, surface: InkTheme.paper),
          scaffoldBackgroundColor: InkTheme.skyTop,
          useMaterial3: true,
        ),
        home: PopScope(
          canPop: _place == _Place.home,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _home();
          },
          child: switch (_place) {
            _Place.home => HomePage(
              onPlay: _playDefault,
              onSetup: () => setState(() => _place = _Place.setup),
              onHowTo: () => setState(() => _place = _Place.howTo),
              onSettings: () => setState(() => _place = _Place.settings),
              onInfo: () => setState(() => _place = _Place.info),
              onStore: () {},
              onExit: widget.onExit ?? leaveApp,
            ),
            _Place.howTo => HowToPage(onDone: _home),
            _Place.settings => SettingsPage(settings: _settings, onBack: _home, onSave: _saveSettings),
            _Place.info => InfoPage(onBack: _home),
            _Place.setup => SetupPage(
              mode: widget.mode,
              onBack: _home,
              onStart: _playCustom,
            ),
            _Place.table => TablePage(
              seed: _tableSeed,
              mode: widget.mode,
              players: _players,
              onHome: _home,
              feel: _feel,
            ),
          },
        ),
      ),
    );
  }
}
