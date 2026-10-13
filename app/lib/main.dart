import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rules/rules.dart';

import 'home/home_page.dart';
import 'home/how_to_page.dart';
import 'home/setup_page.dart';
import 'table/table_page.dart';
import 'theme/game_feel.dart';
import 'theme/ink_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LinesApp());
}

class LinesApp extends StatefulWidget {
  const LinesApp({super.key, this.seed, this.mode = classicMode});

  final int? seed;
  final GameMode mode;

  @override
  State<LinesApp> createState() => _LinesAppState();
}

enum _Place { home, howTo, setup, table }

class _LinesAppState extends State<LinesApp> {
  _Place _place = _Place.home;
  bool _howToSeen = false;
  List<Player> _players = defaultPlayers;
  late int _tableSeed = widget.seed ?? DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
  final GameFeel _feel = DeviceFeel();

  @override
  void dispose() {
    _feel.dispose();
    super.dispose();
  }

  void _playDefault() {
    setState(() {
      _players = defaultPlayers;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
            showFirstGameNote: !_howToSeen,
            onPlay: _playDefault,
            onSetup: () => setState(() => _place = _Place.setup),
            onHowTo: () => setState(() => _place = _Place.howTo),
            onSkipHowTo: () => setState(() => _howToSeen = true),
          ),
          _Place.howTo => HowToPage(
            onDone: () => setState(() {
              _howToSeen = true;
              _place = _Place.home;
            }),
          ),
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
    );
  }
}
