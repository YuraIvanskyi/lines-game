import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rules/rules.dart';

import 'home/home_page.dart';
import 'home/how_to_page.dart';
import 'home/info_page.dart';
import 'home/game_mode_page.dart';
import 'home/settings_page.dart';
import 'leave_app.dart';
import 'settings/app_settings.dart';
import 'settings/copy.dart';
import 'settings/game_setup.dart';
import 'table/table_page.dart';
import 'theme/game_feel.dart';
import 'theme/ink_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final settingsStore = SharedPrefsSettingsStore();
  final settings = await settingsStore.load();
  final setupStore = SharedPrefsGameSetupStore();
  final setup = await setupStore.load();
  runApp(
    LinesApp(
      settingsStore: settingsStore,
      initialSettings: settings,
      setupStore: setupStore,
      initialSetup: setup,
    ),
  );
}

class LinesApp extends StatefulWidget {
  const LinesApp({super.key, this.seed, this.mode = classicMode, this.onExit, this.settingsStore, this.initialSettings, this.setupStore, this.initialSetup});

  final int? seed;
  final GameMode mode;
  final VoidCallback? onExit;
  final SettingsStore? settingsStore;
  final AppSettings? initialSettings;
  final GameSetupStore? setupStore;
  final GameSetup? initialSetup;

  @override
  State<LinesApp> createState() => _LinesAppState();
}

enum _Place { home, howTo, gameMode, settings, info, table }

class _LinesAppState extends State<LinesApp> {
  _Place _place = _Place.home;
  List<Player> _players = defaultPlayers;
  Map<String, Bot> _bots = const {};
  late int _tableSeed = widget.seed ?? DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
  late AppSettings _settings = widget.initialSettings ?? AppSettings.defaults;
  late final SettingsStore _store = widget.settingsStore ?? MemorySettingsStore();
  late GameSetup _setup = widget.initialSetup ?? GameSetup.defaults;
  late final GameSetupStore _setupStore = widget.setupStore ?? MemoryGameSetupStore();
  late final DeviceFeel _feel = DeviceFeel(soundOn: () => _settings.sound);

  @override
  void dispose() {
    _feel.dispose();
    super.dispose();
  }

  void _play() {
    setState(() {
      _players = _setup.players(Copy.forLanguage(_settings.language));
      _bots = _setup.bots();
      _tableSeed = _nextSeed();
      _place = _Place.table;
    });
  }

  int _nextSeed() => widget.seed ?? DateTime.now().microsecondsSinceEpoch & 0x7fffffff;

  void _home() => setState(() => _place = _Place.home);


  Future<void> _persistSetup(GameSetup next) async {
    await _setupStore.save(next);
    if (!mounted) return;
    setState(() => _setup = next);
  }

  Future<void> _persist(AppSettings next) async {
    await _store.save(next);
    if (!mounted) return;
    setState(() => _settings = next);
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.forLanguage(_settings.language);
    return AppCopy(
      copy: copy,
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
              modeLabel: widget.mode.id == classicModeId ? copy.classic : widget.mode.name,
              setup: _setup,
              onPlay: _play,
              onHowTo: () => setState(() => _place = _Place.howTo),
              onGameMode: () => setState(() => _place = _Place.gameMode),
              onSettings: () => setState(() => _place = _Place.settings),
              onInfo: () => setState(() => _place = _Place.info),
              onStore: () {},
              onExit: widget.onExit ?? leaveApp,
            ),
            _Place.howTo => HowToPage(onDone: _home),
            _Place.settings => SettingsPage(settings: _settings, onBack: _home, onSave: _persist),
            _Place.info => InfoPage(onBack: _home),
            _Place.gameMode => GameModePage(mode: widget.mode, setup: _setup, onBack: _home, onSave: _persistSetup),
            _Place.table => TablePage(
              seed: _tableSeed,
              mode: widget.mode,
              players: _players,
              bots: _bots,
              onHome: _home,
              feel: _feel,
            ),
          },
        ),
      ),
    );
  }
}
