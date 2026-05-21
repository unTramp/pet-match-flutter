import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants.dart';
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
  late final List<Locale> _supportedLocales = AppLanguage.values
      .map((lang) => Locale(lang.code))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLocaleController.instance,
      builder: (context, language, _) {
        return MaterialApp.router(
          title: kAppTitle,
          locale: Locale(language.code),
          supportedLocales: _supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
        );
      },
    );
  }
}
