import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/l10n_extension.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.more)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(context.l10n.customer),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/customers'),
          ),
          ListTile(
            leading: const Icon(Icons.money_off),
            title: Text(context.l10n.expenses),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/expenses'),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(context.l10n.inventory),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/inventory'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: Text(context.l10n.bankAccounts),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/bank-accounts'),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Sao luu & phuc hoi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: Text(context.l10n.storeSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/store'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(context.l10n.appName),
            subtitle: Text('Phien ban 1.0.0'),
          ),
        ],
      ),
    );
  }
}
