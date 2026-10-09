import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'table/table_page.dart';
import 'theme/ink_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LinesApp());
}

class LinesApp extends StatelessWidget {
  const LinesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: InkTheme.inks.first, surface: InkTheme.paper),
        scaffoldBackgroundColor: InkTheme.paper,
        useMaterial3: true,
      ),
      home: TablePage(seed: DateTime.now().millisecondsSinceEpoch & 0x7fffffff),
    );
  }
}
