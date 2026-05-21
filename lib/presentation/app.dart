import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class PetMatchApp extends StatefulWidget {
  const PetMatchApp({super.key});

  @override
  State<PetMatchApp> createState() => _PetMatchAppState();
}

class _PetMatchAppState extends State<PetMatchApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: kAppTitle,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
