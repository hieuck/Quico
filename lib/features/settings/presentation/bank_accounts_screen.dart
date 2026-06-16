import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../l10n/l10n_extension.dart';

class BankAccountsScreen extends ConsumerStatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  ConsumerState<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends ConsumerState<BankAccountsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _bankCodeCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _bankCodeCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = ref.read(appDatabaseProvider);
    final settings = await (db.select(db.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
    if (settings == null) return;

    final now = DateTimeUtils.nowMillis();
    db.into(db.bankAccounts).insert(BankAccountsCompanion.insert(
      id: IdGenerator.newId(),
      storeId: settings.value,
      bankCode: _bankCodeCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim(),
      accountNumber: _accountNumberCtrl.text.trim(),
      accountName: _accountNameCtrl.text.trim(),
      createdAt: now,
      updatedAt: now,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account added')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bankAccounts)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _bankNameCtrl, decoration: const InputDecoration(labelText: 'Ten ngan hang')),
            const SizedBox(height: 12),
            TextFormField(controller: _bankCodeCtrl, decoration: const InputDecoration(labelText: 'Ma ngan hang (VD: VCB)')),
            const SizedBox(height: 12),
            TextFormField(controller: _accountNumberCtrl, decoration: const InputDecoration(labelText: 'So tai khoan'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextFormField(controller: _accountNameCtrl, decoration: const InputDecoration(labelText: 'Account Holder')),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Add Account'))),
          ],
        ),
      ),
    );
  }
}
