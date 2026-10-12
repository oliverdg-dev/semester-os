import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class SemesterOsApp extends StatefulWidget {
  const SemesterOsApp({super.key, this.router});

  /// Tests may inject a router; the app builds its own.
  final GoRouter? router;

  @override
  State<SemesterOsApp> createState() => _SemesterOsAppState();
}

class _SemesterOsAppState extends State<SemesterOsApp> {
  late final GoRouter _router = widget.router ?? buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SemesterOS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
