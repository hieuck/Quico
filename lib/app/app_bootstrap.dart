import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';

class AppBootstrap {
  static Future<ProviderContainer> initialize() async {
    final container = ProviderContainer(
      overrides: [],
    );
    final database = container.read(appDatabaseProvider);
    await database.initialize();
    return container;
  }
}
