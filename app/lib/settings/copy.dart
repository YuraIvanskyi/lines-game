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
    required this.saved,
    required this.legal,
    required this.privacyPolicy,
    required this.termsOfUse,
    required this.support,
    required this.licenses,
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
  final String saved;
  final String legal;
  final String privacyPolicy;
  final String termsOfUse;
  final String support;
  final String licenses;

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
    whichEnd: 'Which end?',
    noGrowth: 'No growth left.',
    tapEnd: 'Tap the ring or the square.',
    passPhone: 'Pass the phone',
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
    saved: 'Saved',
    legal: 'Legal',
    privacyPolicy: 'Privacy Policy',
    termsOfUse: 'Terms of Use',
    support: 'Support',
    licenses: 'Licenses',
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
    whichEnd: 'Який кінець?',
    noGrowth: 'Подовжити вже нікуди.',
    tapEnd: 'Торкніться кільця або квадрата.',
    passPhone: 'Передайте телефон',
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
    saved: 'Збережено',
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
