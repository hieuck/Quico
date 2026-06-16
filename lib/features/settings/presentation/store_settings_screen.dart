import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart' ;
import '../../../l10n/l10n_extension.dart';

class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final database = ref.read(appDatabaseProvider);
    final settings = await (await database.database).query('app_settings');
    if (settings != null) {
      final store = await (await database.database).query('stores');
      if (store != null) _nameCtrl.text = store.name;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.storeSettings)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Ten cua hang')),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () async {
                    final database = ref.read(appDatabaseProvider);
                    final settings = await (await database.database).query('app_settings');
                    if (settings != null) {
                      await (database.update(database.stores),
                          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
                        ),
                      );
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved'});
                    }
                  },
                  child: Text(context.l10n.save),
                )),
              ],
            ),
    );
  }
}
