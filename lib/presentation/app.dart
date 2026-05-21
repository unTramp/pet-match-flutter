import 'package:flutter/material.dart';

import '../core/locale/app_locale_controller.dart';
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
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocaleController.instance,
      builder: (context, language, _) {
        return MaterialApp.router(
          title: 'Pet Match AI',
          locale: Locale(language.code),
          supportedLocales: const [Locale('ru'), Locale('en')],
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
        );
      },
    );
  }
}
