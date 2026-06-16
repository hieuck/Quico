import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_provider.dart';
import 'app_bootstrap.dart';
import 'router.dart' as router;
import 'theme.dart';
import '../l10n/l10n_extension.dart';

class QuicoApp extends ConsumerWidget {
  const QuicoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.watch(router.routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: context.l10n.appName,
      locale: locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: routerConfig,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
    );
  }
}
