import 'dart:io';

import 'package:flutter/services.dart';

void leaveApp() {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
    return;
  }
  exit(0);
}
