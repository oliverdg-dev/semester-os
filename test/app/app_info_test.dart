import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semester_os/app/app_info.dart';

void main() {
  test('AppInfo.version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([0-9.]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(AppInfo.version, version);
  });

  test('pubspec pins the Flutter version recorded in .fvmrc', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final pinned = RegExp(
      r'^\s+flutter:\s*([0-9.]+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(File('.fvmrc').readAsStringSync(), contains('"$pinned"'));
  });
}
