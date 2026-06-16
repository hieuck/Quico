import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_db.dart' as db;

class AppBootstrap {
  static Future<ProviderContainer> initialize() async {
    final container = ProviderContainer(
      overrides: [],
    );
    final database = container.read(db.appDatabaseProvider);
    await database.initialize();
    return container;
  }
}
