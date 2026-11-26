import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rules/rules.dart';

import '../settings/copy.dart';
import '../settings/game_setup.dart';
import '../theme/arcade_shell.dart';
import '../theme/ink_theme.dart';
import 'play_snippet.dart';

/// Everything PLAY uses, on one page: the mode as picture cards, then who you play against,
/// then the seats. Nothing is stored until Save, which also returns to the menu.
class GameModePage extends StatefulWidget {
  const GameModePage({
    super.key,
    this.modes = gameModes,
    required this.setup,
    required this.onSave,
    required this.onBack,
  });

  final List<GameMode> modes;
  final GameSetup setup;
  final Future<void> Function(GameSetup setup) onSave;
  final VoidCallback onBack;

  @override
  State<GameModePage> createState() => _GameModePageState();
}

class _GameModePageState extends State<GameModePage> {
  late String _modeId = widget.modes.any((mode) => mode.id == widget.setup.modeId)
      ? widget.setup.modeId
      : widget.modes.first.id;
  late Opponent _opponent = widget.setup.opponent;
  late int _count = widget.setup.playerCount;
  late Difficulty _difficulty = widget.setup.difficulty;
  late List<int> _colors = cleanColors(widget.setup.colors);

  /// The seat whose color palette is open, if any.
  int? _paletteSeat;
  final _paletteKeys = List.generate(maxPlayers, (_) => GlobalKey());
  final List<TextEditingController> _names = [];
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_names.isNotEmpty) return;
    final copy = AppCopy.of(context);
    for (var i = 0; i < maxPlayers; i++) {
      final stored = widget.setup.names[i];
      _names.add(TextEditingController(text: stored.isEmpty ? copy.player(i + 1) : stored));
    }
  }

  @override
  void dispose() {
    for (final name in _names) {
      name.dispose();
    }
    super.dispose();
  }

  void _change(VoidCallback change) => setState(change);

  /// Stores the setup, then returns to the menu that opened this page.
  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    final copy = AppCopy.of(context);
    // A name left at its default keeps following the app language.
    final names = [
      for (var i = 0; i < maxPlayers; i++)
        _names[i].text.trim() == copy.player(i + 1) ? '' : clipName(_names[i].text),
    ];
    await widget.onSave(
      GameSetup(
        modeId: _modeId,
        opponent: _opponent,
        playerCount: _count,
        names: names,
        difficulty: _difficulty,
        colors: _colors,
      ),
    );
    if (mounted) widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ArcadeBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(alignment: Alignment.centerLeft, child: PopBackButton(onPressed: widget.onBack, label: copy.back)),
                    PopTitle(copy.gameMode, size: 40),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PopBlock(title: copy.mode, child: _modeCards(copy)),
                            const SizedBox(height: 12),
                            PopBlock(title: copy.opponent, child: _opponents(copy)),
                            if (_opponent == Opponent.computer) ...[
                              const SizedBox(height: 12),
                              PopBlock(title: copy.difficulty, child: _difficulties(copy)),
                            ],
                            const SizedBox(height: 12),
                            PopBlock(title: copy.players, child: _players(copy)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PopButton(label: copy.save, color: InkTheme.greenFace, onPressed: _save),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Two cards per row, each with a live board showing how the mode plays.
  Widget _modeCards(Copy copy) {
    const gap = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - gap) / 2;
        final rows = [
          for (var i = 0; i < widget.modes.length; i += 2) widget.modes.sublist(i, (i + 2).clamp(0, widget.modes.length)),
        ];
        return Column(
          children: [
            for (final row in rows)
              Padding(
                padding: EdgeInsets.only(bottom: row == rows.last ? 0 : gap),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final mode in row) ...[
                        if (mode != row.first) const SizedBox(width: gap),
                        SizedBox(width: width, child: _modeCard(copy, mode)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _modeCard(Copy copy, GameMode mode) {
    final selected = mode.id == _modeId;
    final name = copy.modeName(mode);
    return PopTile(
      label: name,
      selected: selected,
      showCheck: true,
      color: selected ? InkTheme.sun : InkTheme.blueFace,
      radius: 20,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      onPressed: () => _change(() => _modeId = mode.id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(aspectRatio: 1, child: PlaySnippet(demo: mode.stars > 0 ? starsDemo : tapDemo)),
          const SizedBox(height: 8),
          OutlineLabel(name.toUpperCase(), size: 18),
          const SizedBox(height: 4),
          Text(
            copy.modeRule(mode),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? InkTheme.ink : InkTheme.cloud,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _opponents(Copy copy) {
    return _TileRow(
      children: [
        _choice(Icons.people, copy.sameScreen, _opponent == Opponent.samePhone, () => _opponent = Opponent.samePhone),
        _choice(Icons.computer, copy.computer, _opponent == Opponent.computer, () => _opponent = Opponent.computer),
        _choice(Icons.public, copy.online, false, () {}, tag: copy.soon),
      ],
    );
  }

  Widget _difficulties(Copy copy) {
    return _TileRow(
      children: [
        for (final level in Difficulty.values)
          _choice(
            level == Difficulty.easy ? Icons.sentiment_satisfied_alt : Icons.local_fire_department,
            copy.difficultyName(level),
            _difficulty == level,
            () => _difficulty = level,
          ),
      ],
    );
  }

  /// An icon over a short label. A [tag] marks a choice that is not open yet.
  Widget _choice(IconData icon, String label, bool selected, VoidCallback pick, {String? tag}) {
    return PopTile(
      label: label,
      selected: selected,
      enabled: tag == null,
      tag: tag,
      color: selected ? InkTheme.sun : InkTheme.blueFace,
      onPressed: () => _change(pick),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: InkTheme.cloud, shadows: _halo),
          const SizedBox(height: 6),
          // One word per line, shrunk as a block, so a long word ("КОМП’ЮТЕР") never breaks mid-word.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: OutlineLabel(label.toUpperCase().replaceAll(' ', '\n'), size: 13, stroke: 2, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  /// The player count (when everyone shares the phone), then one row per seat.
  Widget _players(Copy copy) {
    final vsComputer = _opponent == Opponent.computer;
    final seats = vsComputer ? 2 : _count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!vsComputer) ...[
          _TileRow(
            children: [
              for (var count = minPlayers; count <= maxPlayers; count++)
                PopTile(
                  label: '$count',
                  selected: _count == count,
                  color: _count == count ? InkTheme.sun : InkTheme.blueFace,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () => _change(() => _count = count),
                  child: Center(child: OutlineLabel('$count', size: 24)),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        for (var i = 0; i < seats; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == seats - 1 ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                vsComputer && i == 1 ? _computerSeat(copy) : _nameField(copy, i),
                _palette(copy, i, seats),
              ],
            ),
          ),
      ],
    );
  }

  /// The name a seat shows right now, for "taken by" labels.
  String _seatName(Copy copy, int seat) {
    if (_opponent == Opponent.computer && seat == 1) return copy.computer;
    final typed = clipName(_names[seat].text);
    return typed.isEmpty ? copy.player(seat + 1) : typed;
  }

  /// A round button in the seat's color. It opens that seat's palette.
  Widget _swatch(Copy copy, int seat) {
    final open = _paletteSeat == seat;
    return Semantics(
      button: true,
      expanded: open,
      label: copy.colorLabel(_colors[seat]),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _change(() => _paletteSeat = open ? null : seat);
          if (!open) _reveal(seat);
        },
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutBack,
              width: open ? 34 : 30,
              height: open ? 34 : 30,
              decoration: BoxDecoration(
                color: InkTheme.palette[_colors[seat]],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.5),
              ),
              child: Icon(open ? Icons.expand_less : Icons.palette, size: 16, color: InkTheme.cloud, shadows: _halo),
            ),
          ),
        ),
      ),
    );
  }

  /// Scrolls a freshly opened palette into view once it has finished growing.
  void _reveal(int seat) {
    Future<void>.delayed(const Duration(milliseconds: 240), () {
      final context = _paletteKeys[seat].currentContext;
      if (!mounted || _paletteSeat != seat || context == null || !context.mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  /// The colors under a seat, four to a row. Picking one another seat holds swaps the two.
  Widget _palette(Copy copy, int seat, int seats) {
    final open = _paletteSeat == seat;
    return AnimatedSize(
      key: _paletteKeys[seat],
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !open
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const columns = 4;
                  const gap = 8.0;
                  final cell = (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var color = 0; color < InkTheme.palette.length; color++)
                        SizedBox(width: cell, child: _paletteColor(copy, seat, seats, color)),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _paletteColor(Copy copy, int seat, int seats, int color) {
    final mine = _colors[seat] == color;
    final holder = _colors.indexOf(color);
    final heldByOther = holder >= 0 && holder != seat && holder < seats;
    return Semantics(
      button: true,
      selected: mine,
      label: heldByOther ? copy.taken(color, _seatName(copy, holder)) : copy.colorNames[color],
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _change(() {
          _colors = pickColor(_colors, seat, color);
          _paletteSeat = null;
        }),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: InkTheme.palette[color],
                    shape: BoxShape.circle,
                    border: Border.all(color: mine ? InkTheme.cloud : Colors.black, width: 3),
                    boxShadow: mine ? const [BoxShadow(color: Colors.black, spreadRadius: 3)] : null,
                  ),
                  child: mine ? const Icon(Icons.check_rounded, size: 24, color: InkTheme.cloud, shadows: _halo) : null,
                ),
                if (heldByOther)
                  Positioned(
                    right: -5,
                    bottom: -3,
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: InkTheme.ink,
                        shape: BoxShape.circle,
                        border: Border.all(color: InkTheme.cloud, width: 2),
                      ),
                      child: Text(
                        '${holder + 1}',
                        style: const TextStyle(color: InkTheme.cloud, fontSize: 11, fontWeight: FontWeight.w900, height: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameField(Copy copy, int seat) {
    final ink = InkTheme.palette[_colors[seat]];
    return TextField(
      controller: _names[seat],
      textAlign: TextAlign.center,
      inputFormatters: [LengthLimitingTextInputFormatter(maxNameLength)],
      onChanged: (_) => _change(() {}),
      style: const TextStyle(fontWeight: FontWeight.w700, color: InkTheme.ink),
      cursorColor: ink,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.lerp(ink, Colors.white, 0.68),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: _swatch(copy, seat),
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        suffixIcon: const SizedBox.shrink(),
        suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        enabledBorder: _seatBorder(InkTheme.ink),
        focusedBorder: _seatBorder(ink),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  /// The computer's seat: its name is fixed, so it reads like a field without being one.
  Widget _computerSeat(Copy copy) {
    final ink = InkTheme.palette[_colors[1]];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(ink, Colors.white, 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InkTheme.ink, width: 3),
      ),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            _swatch(copy, 1),
            Expanded(
              child: Text(
                copy.computer,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: InkTheme.ink),
              ),
            ),
            const SizedBox(width: 48, child: ExcludeSemantics(child: Icon(Icons.computer, color: InkTheme.ink, size: 22))),
          ],
        ),
      ),
    );
  }
}

/// Equal-width tiles in one row.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

const _halo = <Shadow>[
  Shadow(color: Colors.black, offset: Offset(-1.2, 0)),
  Shadow(color: Colors.black, offset: Offset(1.2, 0)),
  Shadow(color: Colors.black, offset: Offset(0, -1.2)),
  Shadow(color: Colors.black, offset: Offset(0, 1.2)),
];

OutlineInputBorder _seatBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: 3),
  );
}
