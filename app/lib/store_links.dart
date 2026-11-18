import 'package:flutter/foundation.dart';

/// Where the home ♥ button sends people: this app's own store page.
abstract final class StoreLinks {
  /// Bundle ID on iOS and application ID on Android. Permanent once uploaded.
  static const appId = 'com.ivanskyi.ends';

  /// Numeric Apple ID from App Store Connect (App Information → Apple ID).
  /// It exists only after the app record is created. Fill it in before submitting.
  static const appStoreId = '';

  static final appStore = Uri.parse('https://apps.apple.com/app/id$appStoreId');
  static final playStore = Uri.parse('https://play.google.com/store/apps/details?id=$appId');

  /// Apple devices get the App Store, everything else gets Google Play.
  static Uri forPlatform(TargetPlatform platform) => switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => appStore,
    _ => playStore,
  };
}
