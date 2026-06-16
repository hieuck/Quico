import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/database/app_database.dart' ;
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _storeName = '';
  String _businessType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tao cua hang')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thong tin cua hang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ten cua hang', hintText: 'VD: Quan cafe ABC'),
                validator: Validators.storeName,
                onChanged: (v) => setState(() => _storeName = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _businessType.isEmpty ? null : _businessType,
                decoration: const InputDecoration(labelText: 'Loai hinh kinh doanh (khong bat buoc)'),
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Quan an / do uong')),
                  DropdownMenuItem(value: 'online', child: Text('Shop online')),
                  DropdownMenuItem(value: 'retail', child: Text('Tap hoa / ban le')),
                  DropdownMenuItem(value: 'Other', child: Text('Khac')),
                ],
                onChanged: (v) => setState(() => _businessType = v ?? ''),
              ),
              const SizedBox(height: 16),
              const Text('Don vi tien: VND', style: TextStyle(color: Colors.grey)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createStore,
                  child: const Text('Tao cua hang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createStore() {
    if (!_formKey.currentState!.validate()) return;
    final name = _storeName.trim();
    if (name.isEmpty) return;

    final database = ref.read(appDatabaseProvider);
    final now = DateTimeUtils.nowMillis();
    final storeId = IdGenerator.newId();

    database.into(database.stores).insert(StoresCompanion.insert(
      id: storeId,
      name: name,
      businessType: _businessType.isNotEmpty ? Value(_businessType) : Value.absent(),
      currency: 'VND',
      createdAt: now,
      updatedAt: now,
    ));

    database.into(database.appSettings).insert(AppSettingsCompanion.insert(
      key: 'active_store_id',
      value: storeId,
      updatedAt: now,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cua hang da san sang!')),
    );
    context.go('/');
  }
}
