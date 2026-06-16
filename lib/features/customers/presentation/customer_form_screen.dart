import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_db.dart' as db;
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../l10n/l10n_extension.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final database = ref.read(db.appDatabaseProvider);
    final settings = await (database.select(database.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
    if (settings == null) return;

    final now = DateTimeUtils.nowMillis();
    database.into(database.customers).insert(CustomersCompanion.insert(
      id: IdGenerator.newId(),
      storeId: settings.value,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isNotEmpty ? db.Value(_phoneCtrl.text.trim()) : Value.absent(),
      note: _noteCtrl.text.trim().isNotEmpty ? db.Value(_noteCtrl.text.trim()) : Value.absent(),
      createdAt: now,
      updatedAt: now,
    ));

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: context.l10n.customer), validator: (v) => v == null || v.trim().isEmpty ? 'Nhap ten' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'So dien thoai (khong bat buoc)'), keyboardType: TextInputType.phone),
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
