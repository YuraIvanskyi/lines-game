import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public pages that App Store review expects to reach from inside the app.
/// Replace these with the live URLs before submitting a build.
abstract final class LegalLinks {
  static final privacyPolicy = Uri.parse('https://example.com/ends/privacy');
  static final termsOfUse = Uri.parse('https://example.com/ends/terms');
  static final support = Uri.parse('https://example.com/ends/support');
}

typedef LinkOpener = Future<void> Function(Uri url);

Future<void> openLink(Uri url) async {
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (error) {
    debugPrint('Could not open $url: $error');
  }
}
