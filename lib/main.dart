import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/config/theme.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeMode = await AppTheme.loadThemeMode();

  runApp(
    ProviderScope(
      overrides: [],
      child: GymApp(initialThemeMode: themeMode),
    ),
  );
}
