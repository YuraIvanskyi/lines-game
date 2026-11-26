import 'package:flutter/widgets.dart';
import 'package:rules/rules.dart';

import 'app_settings.dart';

class Copy {
  const Copy({
    required this.classic,
    required this.colorNames,
    required this.takenOf,
    required this.colorOf,
    required this.soon,
    required this.starBonus,
    required this.againOf,
    required this.tipStars,
    required this.starsRule,
    required this.classicRule,
    required this.stars,
    required this.play,
    required this.howTo,
    required this.players,
    required this.settings,
    required this.info,
    required this.store,
    required this.exit,
    required this.letsGo,
    required this.tipEnds,
    required this.tipTap,
    required this.tipLoss,
    required this.lost,
    required this.gameMode,
    required this.playersOf,
    required this.mode,
    required this.opponent,
    required this.sameScreen,
    required this.computer,
    required this.difficulty,
    required this.easy,
    required this.hard,
    required this.yourMove,
    required this.thinking,
    required this.online,
    required this.playerName,
    required this.creator,
    required this.creatorName,
    required this.thanks,
    required this.thanksBody,
    required this.tech,
    required this.techLines,
    required this.assets,
    required this.assetLines,
    required this.whichEnd,
    required this.winsOf,
    required this.othersWin,
    required this.tapEnd,
    required this.passPhone,
    required this.rematch,
    required this.home,
    required this.turnOf,
    required this.lostOf,
    required this.leaveTitle,
    required this.leaveBody,
    required this.keepPlaying,
    required this.leave,
    required this.back,
    required this.restart,
    required this.restartOf,
    required this.restartBody,
    required this.startOver,
    required this.sound,
    required this.soundOn,
    required this.soundOff,
    required this.languages,
    required this.save,
    required this.legal,
    required this.privacyPolicy,
    required this.termsOfUse,
    required this.support,
    required this.licenses,
  });

  final String classic;
  final List<String> colorNames;
  final String takenOf;
  final String colorOf;
  final String soon;
  final String starBonus;
  final String againOf;
  final String tipStars;
  final String starsRule;
  final String classicRule;
  final String stars;
  final String play;
  final String howTo;
  final String players;
  final String settings;
  final String info;
  final String store;
  final String exit;
  final String letsGo;
  final String tipEnds;
  final String tipTap;
  final String tipLoss;
  final String lost;
  final String gameMode;
  final String playersOf;
  final String mode;
  final String opponent;
  final String sameScreen;
  final String computer;
  final String difficulty;
  final String easy;
  final String hard;
  final String yourMove;
  final String thinking;
  final String online;
  final String playerName;
  final String creator;
  final String creatorName;
  final String thanks;
  final String thanksBody;
  final String tech;
  final List<String> techLines;
  final String assets;
  final List<String> assetLines;
  final String whichEnd;
  final String winsOf;
  final String othersWin;
  final String tapEnd;
  final String passPhone;
  final String rematch;
  final String home;
  final String turnOf;
  final String lostOf;
  final String leaveTitle;
  final String leaveBody;
  final String keepPlaying;
  final String leave;
  final String back;
  final String restart;
  final String restartOf;
  final String restartBody;
  final String startOver;
  final String sound;
  final String soundOn;
  final String soundOff;
  final String languages;
  final String save;
  final String legal;
  final String privacyPolicy;
  final String termsOfUse;
  final String support;
  final String licenses;

  String difficultyName(Difficulty level) => level == Difficulty.easy ? easy : hard;

  /// Menu name of a mode. Modes the copy doesn't know keep the rules package's name.
  String modeName(GameMode mode) => switch (mode.id) {
    classicModeId => classic,
    starsModeId => stars,
    _ => mode.name,
  };

  /// One line on how a mode plays.
  String modeRule(GameMode mode) => mode.stars > 0 ? starsRule : classicRule;

  String again(String name) => againOf.replaceAll('{name}', name);

  /// What a screen reader says for a seat's color button.
  String colorLabel(int color) => colorOf.replaceAll('{color}', colorNames[color]);

  /// A palette color another seat already has.
  String taken(int color, String name) => takenOf.replaceAll('{color}', colorNames[color]).replaceAll('{name}', name);

  String player(int number) => '$playerName $number';

  String playerCount(int count) => playersOf.replaceAll('{count}', '$count');

  String turn(String name) => turnOf.replaceAll('{name}', name);

  String lostPlayer(String name) => lostOf.replaceAll('{name}', name);

  String restartAsk(String name) => restartOf.replaceAll('{name}', name);

  /// Who wins when [loser] is stuck: the one other seat, or everyone else.
  String winners(List<String> others) => others.length == 1 ? winsOf.replaceAll('{name}', others.single) : othersWin;

  static Copy forLanguage(AppLanguage language) {
    return switch (language) {
      AppLanguage.english => english,
      AppLanguage.ukrainian => ukrainian,
    };
  }

  static const english = Copy(
    classic: 'Classic',
    colorNames: ['Pink', 'Mint', 'Gold', 'Sky', 'Orange', 'Violet', 'Lime', 'Orchid'],
    takenOf: '{color}, taken by {name}',
    colorOf: 'Color: {color}',
    soon: 'Soon',
    starBonus: 'Star! One more move.',
    againOf: '{name} goes again!',
    tipStars: 'Stars mode: land on a star and you move again right away.',
    starsRule: 'Land on a star to move again.',
    classicRule: 'Grow the line. No move left? You lose.',
    stars: 'Stars',
    play: 'Play',
    howTo: 'How to play',
    players: 'Players',
    settings: 'Settings',
    info: 'Info',
    store: 'Store',
    exit: 'Exit',
    letsGo: "Let's go",
    tipEnds: 'Grow the line from either end. The ring is the head. The square is the tail.',
    tipTap: 'Tap a marked dot.',
    tipLoss: 'The player who cannot grow loses.',
    lost: 'LOST',
    gameMode: 'Game mode',
    playersOf: '{count} players',
    mode: 'Mode',
    opponent: 'Opponent',
    sameScreen: 'Same phone',
    computer: 'Computer',
    difficulty: 'Difficulty',
    easy: 'Easy',
    hard: 'Hard',
    yourMove: 'Your move',
    thinking: 'Thinking…',
    online: 'Online',
    playerName: 'Player',
    creator: 'Creator',
    creatorName: 'Yurii Ivanskyi',
    thanks: 'Thanks',
    thanksBody: 'To my best friend Bohdan, with whom a paper version of this game first appeared during our school years.',
    tech: 'Tech',
    techLines: [
      'Flutter and Dart.',
      'audioplayers. MIT License.',
      'shared_preferences, url_launcher. BSD 3-Clause License.',
      'Settings are stored on this device only. The app collects no personal data and has no ads, accounts or analytics.',
    ],
    assets: 'Assets',
    assetLines: [
      'Nunito, a variable font by The Nunito Project Authors. SIL Open Font License\u00A01.1.',
      'Material Icons by Google. Apache License\u00A02.0.',
      'Sound effects: original, created for this app.',
    ],
    whichEnd: 'Which end should grow?',
    winsOf: '{name} wins!',
    othersWin: 'Everyone else wins!',
    tapEnd: 'Tap the ring or the square.',
    passPhone: 'Pass the phone',
    rematch: 'Rematch',
    home: 'Home',
    turnOf: "{name}'s turn",
    lostOf: '{name} is boxed in!',
    leaveTitle: 'Leaving so soon?',
    leaveBody: "This game isn't over yet. If you leave now, it won't be saved.",
    keepPlaying: 'Keep playing',
    leave: 'Leave',
    back: 'Back',
    restart: 'Restart',
    restartOf: 'Start over, {name}?',
    restartBody: 'The line gets wiped and the game starts fresh on this same board.',
    startOver: 'Start over',
    sound: 'Sound',
    soundOn: 'Sound on',
    soundOff: 'Sound off',
    languages: 'Languages',
    save: 'Save',
    legal: 'Legal',
    privacyPolicy: 'Privacy Policy',
    termsOfUse: 'Terms of Use',
    support: 'Support',
    licenses: 'Licenses',
  );

  static const ukrainian = Copy(
    classic: 'Класика',
    colorNames: ['Рожевий', 'М’ятний', 'Золотий', 'Блакитний', 'Помаранчевий', 'Фіолетовий', 'Лаймовий', 'Бузковий'],
    takenOf: '{color}, зараз у: {name}',
    colorOf: 'Колір: {color}',
    soon: 'Скоро',
    starBonus: 'Зірка! Ще один хід.',
    againOf: '{name} ходить ще раз!',
    tipStars: 'Режим «Зірки»: дійшли до зірки — ходите ще раз.',
    starsRule: 'Став лінію на зірку — і ходи ще раз.',
    classicRule: 'Подовжуй лінію. Немає ходу — поразка.',
    stars: 'Зірки',
    play: 'Грати',
    howTo: 'Як грати',
    players: 'Гравці',
    settings: 'Налаштування',
    info: 'Інфо',
    store: 'Крамниця',
    exit: 'Вихід',
    letsGo: 'Поїхали',
    tipEnds: 'Подовжуйте лінію з будь-якого кінця. Кільце — голова. Квадрат — хвіст.',
    tipTap: 'Торкніться позначеної точки.',
    tipLoss: 'Програє той, хто не може подовжити лінію.',
    lost: 'ПРОГРАШ',
    gameMode: 'Режим гри',
    playersOf: '{count} гравці',
    mode: 'Режим',
    opponent: 'Суперник',
    sameScreen: 'Один телефон',
    computer: 'Комп’ютер',
    difficulty: 'Складність',
    easy: 'Легко',
    hard: 'Важко',
    yourMove: 'Ваш хід',
    thinking: 'Думає…',
    online: 'Онлайн',
    playerName: 'Гравець',
    creator: 'Автор',
    creatorName: 'Yurii Ivanskyi',
    thanks: 'Подяка',
    thanksBody: 'Моєму найкращому другу Богдану, з яким паперова версія цієї гри вперше з’явилася ще в шкільні роки.',
    tech: 'Технології',
    techLines: [
      'Flutter і Dart.',
      'audioplayers. Ліцензія MIT.',
      'shared_preferences, url_launcher. Ліцензія BSD 3-Clause.',
      'Налаштування зберігаються лише на цьому пристрої. Застосунок не збирає особистих даних, не має реклами, облікових записів і аналітики.',
    ],
    assets: 'Матеріали',
    assetLines: [
      'Nunito — варіативний шрифт The Nunito Project Authors. SIL Open Font License\u00A01.1.',
      'Material Icons від Google. Apache License\u00A02.0.',
      'Звукові ефекти: авторські, створені для цього застосунку.',
    ],
    whichEnd: 'Який кінець подовжити?',
    winsOf: 'Перемога: {name}!',
    othersWin: 'Перемагають усі інші!',
    tapEnd: 'Торкніться кільця або квадрата.',
    passPhone: 'Передайте телефон',
    rematch: 'Ще раз',
    home: 'На головну',
    turnOf: 'Хід: {name}',
    lostOf: '{name} у пастці!',
    leaveTitle: 'Уже йдете?',
    leaveBody: 'Гра ще не закінчилася. Якщо вийти зараз, її не буде збережено.',
    keepPlaying: 'Грати далі',
    leave: 'Вийти',
    back: 'Назад',
    restart: 'Заново',
    restartOf: '{name}, почати заново?',
    restartBody: 'Лінію буде стерто, і гра почнеться наново на цьому ж полі.',
    startOver: 'Почати знову',
    sound: 'Звук',
    soundOn: 'Звук увімкнено',
    soundOff: 'Звук вимкнено',
    languages: 'Мови',
    save: 'Зберегти',
    legal: 'Правова інформація',
    privacyPolicy: 'Конфіденційність',
    termsOfUse: 'Умови використання',
    support: 'Підтримка',
    licenses: 'Ліцензії',
  );
}

class AppCopy extends InheritedWidget {
  const AppCopy({super.key, required this.copy, required super.child});

  final Copy copy;

  static Copy of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppCopy>();
    return scope?.copy ?? Copy.english;
  }

  @override
  bool updateShouldNotify(AppCopy oldWidget) => oldWidget.copy != copy;
}
