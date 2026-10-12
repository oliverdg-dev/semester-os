import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads every font in the bundled FontManifest (IBM Plex Sans and Material
/// icons) so golden images show real glyphs instead of the test font.
Future<void> loadAppFonts() async {
  final manifest = await rootBundle.loadString('FontManifest.json');
  for (final family in jsonDecode(manifest) as List<dynamic>) {
    final entry = family as Map<String, dynamic>;
    final loader = FontLoader(entry['family'] as String);
    for (final font in entry['fonts'] as List<dynamic>) {
      final asset = (font as Map<String, dynamic>)['asset'] as String;
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
