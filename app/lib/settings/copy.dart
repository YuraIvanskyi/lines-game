import 'package:flutter/widgets.dart';

import 'app_settings.dart';

class Copy {
  const Copy({
    required this.classic,
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
    required this.start,
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
    required this.noGrowth,
    required this.tapEnd,
    required this.passPhone,
    required this.hint,
    required this.rematch,
    required this.home,
    required this.turnOf,
    required this.lostOf,
    required this.leaveTitle,
    required this.leaveBody,
    required this.stay,
    required this.leave,
    required this.back,
    required this.restart,
    required this.restartOf,
    required this.restartBody,
    required this.cancel,
    required this.sound,
    required this.soundOn,
    required this.soundOff,
    required this.languages,
    required this.save,
  });

  final String classic;
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
  final String start;
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
  final String noGrowth;
  final String tapEnd;
  final String passPhone;
  final String hint;
  final String rematch;
  final String home;
  final String turnOf;
  final String lostOf;
  final String leaveTitle;
  final String leaveBody;
  final String stay;
  final String leave;
  final String back;
  final String restart;
  final String restartOf;
  final String restartBody;
  final String cancel;
  final String sound;
  final String soundOn;
  final String soundOff;
  final String languages;
  final String save;

  String player(int number) => '$playerName $number';

  String turn(String name) => turnOf.replaceAll('{name}', name);

  String lostPlayer(String name) => lostOf.replaceAll('{name}', name);

  String restartAsk(String name) => restartOf.replaceAll('{name}', name);

  static Copy forLanguage(AppLanguage language) {
    return switch (language) {
      AppLanguage.english => english,
      AppLanguage.ukrainian => ukrainian,
    };
  }

  static const english = Copy(
    classic: 'Classic',
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
    start: 'Start',
    playerName: 'Player',
    creator: 'Creator',
    creatorName: 'Yurii Ivanskyi',
    thanks: 'Thanks',
    thanksBody: 'To my best friend Bohdan, with whom a paper version of this game first appeared during our school years.',
    tech: 'Tech',
    techLines: [
      'Flutter and Dart.',
      'The match rules are a pure Dart package, separate from the screens.',
      'The board is painted in Flutter.',
      'Sounds play through audioplayers, with a haptic on each cue.',
    ],
    assets: 'Assets',
    assetLines: [
      'Nunito, a variable font by The Nunito Project Authors. SIL Open Font License\u00A01.1.',
      'Material Icons by Google. Apache License\u00A02.0.',
      'Short original cues for a growth, an illegal tap, a turn pass, and a loss.',
    ],
    whichEnd: 'Which end?',
    noGrowth: 'No growth left.',
    tapEnd: 'Tap the ring or the square.',
    passPhone: 'Pass the phone',
    hint: 'Tap a gold ring. The circle is the head, the square is the tail.',
    rematch: 'Rematch',
    home: 'Home',
    turnOf: "{name}'s turn",
    lostOf: '{name} lost',
    leaveTitle: 'Leave this game?',
    leaveBody: 'Stay keeps this match. Leave returns home.',
    stay: 'Stay',
    leave: 'Leave',
    back: 'Back',
    restart: 'Restart',
    restartOf: '{name} wants to restart?',
    restartBody: 'This starts the current game over.',
    cancel: 'Cancel',
    sound: 'Sound',
    soundOn: 'Sound on',
    soundOff: 'Sound off',
    languages: 'Languages',
    save: 'Save',
  );

  static const ukrainian = Copy(
    classic: 'Класика',
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
    start: 'Старт',
    playerName: 'Гравець',
    creator: 'Автор',
    creatorName: 'Yurii Ivanskyi',
    thanks: 'Подяка',
    thanksBody: 'Моєму найкращому другу Богдану, з яким паперова версія цієї гри вперше з’явилася ще в шкільні роки.',
    tech: 'Технології',
    techLines: [
      'Flutter і Dart.',
      'Правила партії — чистий пакет Dart, окремо від екранів.',
      'Поле малюється у Flutter.',
      'Звуки грають через audioplayers, і кожна подія має тактильний відгук.',
    ],
    assets: 'Матеріали',
    assetLines: [
      'Nunito — варіативний шрифт The Nunito Project Authors. SIL Open Font License\u00A01.1.',
      'Material Icons від Google. Apache License\u00A02.0.',
      'Короткі авторські сигнали росту, хибного дотику, передачі ходу й поразки.',
    ],
    whichEnd: 'Який кінець?',
    noGrowth: 'Подовжити вже нікуди.',
    tapEnd: 'Торкніться кільця або квадрата.',
    passPhone: 'Передайте телефон',
    hint: 'Торкніться золотого кільця. Коло — голова, квадрат — хвіст.',
    rematch: 'Ще раз',
    home: 'На головну',
    turnOf: 'Хід: {name}',
    lostOf: 'Поразка: {name}',
    leaveTitle: 'Вийти з цієї гри?',
    leaveBody: '«Залишитись» зберігає цю партію. «Вийти» повертає на головну.',
    stay: 'Залишитись',
    leave: 'Вийти',
    back: 'Назад',
    restart: 'Заново',
    restartOf: '{name} хоче почати спочатку?',
    restartBody: 'Поточна гра почнеться з початку.',
    cancel: 'Скасувати',
    sound: 'Звук',
    soundOn: 'Звук увімкнено',
    soundOff: 'Звук вимкнено',
    languages: 'Мови',
    save: 'Зберегти',
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
