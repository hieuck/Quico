import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart' ;
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../l10n/l10n_extension.dart';

const _categories = ['Nguyen lieu', 'Nhan cong', 'Mat bang', 'Van chuyen', 'Marketing', 'Khac'];

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _category = _categories[0];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = int.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    final database = ref.read(appDatabaseProvider);
    final settings = await ((await database.database).query('app_settings')..where((t) => t.key.equals('active_store_id')));
    if (settings == null) return;

    final now = DateTimeUtils.nowMillis();
    (await database.database).insert('expenses', {
      id: IdGenerator.newId(),
      storeId: settings.value,
      category: _category,
      amount: amount,
      note: _noteCtrl.text.trim().isNotEmpty ? Value(_noteCtrl.text.trim()) : null,
      spentAt: now,
      createdAt: now,
      updatedAt: now,
    ));

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Danh muc'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v ?? _categories[0]),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _amountCtrl, decoration: const InputDecoration(labelText: 'So tien'), keyboardType: TextInputType.number, validator: (v) => (v == null || int.tryParse(v) == null || int.parse(v) <= 0) ? 'Nhap so tien hop le' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _noteCtrl, decoration: InputDecoration(labelText: context.l10n.costPrice), maxLines: 2),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(context.l10n.save))),
          ],
        ),
      ),
    );
  }
}
