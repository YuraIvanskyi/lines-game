import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public pages that App Store review expects to reach from inside the app.
/// Served by GitHub Pages from the public `ends-site` repo (sibling folder `../ends-site`).
abstract final class LegalLinks {
  static const base = 'https://yuraivanskyi.github.io/ends-site';
  static final privacyPolicy = Uri.parse('$base/privacy.html');
  static final termsOfUse = Uri.parse('$base/terms.html');
  static final support = Uri.parse('$base/support.html');
}

typedef LinkOpener = Future<void> Function(Uri url);

Future<void> openLink(Uri url) async {
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (error) {
    debugPrint('Could not open $url: $error');
  }
}
