import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_bootstrap.dart';
import 'app/quico_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = await AppBootstrap.initialize();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const QuicoApp(),
    ),
  );
}
