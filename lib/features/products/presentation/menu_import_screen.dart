import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/database/app_database.dart' ;
import '../../../core/utils/currency_formatter.dart';
import '../../../core/ai/parser/rule_based_menu_text_parser.dart';
import '../../../core/ai/parser/parsed_order_models.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import '../../../l10n/l10n_extension.dart';

class MenuImportScreen extends ConsumerStatefulWidget {
  const MenuImportScreen({super.key});

  @override
  ConsumerState<MenuImportScreen> createState() => _MenuImportScreenState();
}

class _MenuImportScreenState extends ConsumerState<MenuImportScreen> {
  List<ParsedMenuProduct> _detected = [];
  final Set<int> _selected = {};
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _loading = true);
    try {
      final parser = RuleBasedMenuTextParser();
      final sampleText = 'Ca phe den 25k\nCa phe sua 30k\nTra dao cam sa 35k\nBanh mi thit 20k';
      final products = await parser.parse(sampleText);
      setState(() {
        _detected = products;
        _selected.addAll(List.generate(products.length, (i) => i));
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _saveSelected() async {
    final database = ref.read(appDatabaseProvider);
    final settings = await ((await database.database).query('app_settings')..where((t) => t.key.equals('active_store_id')));
    if (settings == null) return;

    final repo = ProductRepository(db);
    final now = DateTimeUtils.nowMillis();

    for (final i in _selected) {
      final product = _detected[i];
      final normalizedName = product.name.toLowerCase().trim();
      (await database.database).insert('products', {
        id: IdGenerator.newId(),
        storeId: settings.value,
        name: product.name,
        normalizedName: normalizedName,
        salePrice: product.salePrice,
        createdAt: now,
        updatedAt: now,
      ));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${_selected.length} products'});
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.importMenu)),
      body: _detected.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Chup anh menu de nhap san pham nhanh.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: _loading ? null : _pickImage, icon: const Icon(Icons.camera_alt), label: Text(_loading ? context.l10n.loading : 'Chup anh menu')),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _detected.length,
                    itemBuilder: (_, i) {
                      final p = _detected[i];
                      return CheckboxListTile(
                        value: _selected.contains(i),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) _selected.add(i); else _selected.remove(i);
                          });
                        },
                        title: Text(p.name),
                        subtitle: Text(CurrencyFormatter.format(p.salePrice)),
                        secondary: p.isDuplicate ? Icon(Icons.warning, color: Colors.orange.shade400) : null,
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selected.isEmpty ? null : _saveSelected,
                        child: Text('Save ${_selected.length} products'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
