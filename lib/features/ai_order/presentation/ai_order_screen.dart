import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_db.dart' as db;
import '../../../core/ai/parser/rule_based_order_text_parser.dart';
import '../../../core/ai/parser/product_matching_service.dart';
import '../../../core/ai/parser/parsed_order_models.dart';
import '../../products/data/product_repository.dart';
import 'ai_review_screen.dart';

final _parsedDraftProvider = StateProvider<ParsedOrderDraft?>((ref) => null);

class AiOrderScreen extends ConsumerStatefulWidget {
  const AiOrderScreen({super.key});

  @override
  ConsumerState<AiOrderScreen> createState() => _AiOrderScreenState();
}

class _AiOrderScreenState extends ConsumerState<AiOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textCtrl = TextEditingController();
  final _parser = RuleBasedOrderTextParser();
  bool _parsing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _parseText(String source) async {
    setState(() => _parsing = true);
    try {
      final draft = await _parser.parse(_textCtrl.text.trim());
      final database = ref.read(db.appDatabaseProvider);
      final settings = await (database.select(database.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
      if (settings != null) {
        final repo = ProductRepository(db);
        final products = await repo.listActiveProducts(settings.value);
        final catalog = products.map((p) => {
          'id': p.id,
          'name': p.name,
          'normalized_name': p.normalizedName,
        }).toList();
        final matcher = ProductMatchingService();
        final matchedItems = <ParsedOrderItem>[];
        for (final item in draft.items) {
          final result = await matcher.matchProduct(storeId: settings.value, rawName: item.rawName, catalog: catalog);
          matchedItems.add(ParsedOrderItem(
            rawName: item.rawName,
            quantity: item.quantity,
            unitPrice: item.unitPrice ?? result.match?.score != null ? null : null,
            note: item.note,
            productMatch: result.match,
          ));
        }
        ref.read(_parsedDraftProvider.notifier).state = ParsedOrderDraft(
          originalInput: draft.originalInput,
          source: source,
          customerHint: draft.customerHint,
          items: matchedItems,
          note: draft.note,
        );
      }
    } catch (_) {}
    setState(() => _parsing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aiOrder),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Giong noi', icon: Icon(Icons.mic)),
            Tab(text: 'Van ban', icon: Icon(Icons.text_fields)),
            Tab(text: 'Anh tin nhan', icon: Icon(Icons.image)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVoiceTab(),
          _buildTextTab(),
          _buildScreenshotTab(),
        ],
      ),
    );
  }

  Widget _buildVoiceTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          const Text('Noi don hang cua ban'),
          const SizedBox(height: 8),
          Text('VD: "2 ca phe sua, 1 tra dao 50 nghin"', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _textCtrl.text = '2 ca phe sua, 1 tra dao';
              _parseText('voice');
            },
            icon: const Icon(Icons.mic),
            label: const Text('Bat dau noi'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _textCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Nhap don hang, VD:\n2 ca phe sua 30k, 1 tra dao 50k',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _parsing ? null : () => _parseText('text'),
              child: _parsing ? const CircularProgressIndicator() : const Text('Phan tich don hang'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_search, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Chon anh tin nhan hoac chup man hinh'),
          const SizedBox(height: 8),
          const Text('OCR se trich xuat text va phan tich don hang.'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.photo_library), label: const Text('Chon anh')),
              const SizedBox(width: 12),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Chup anh')),
            ],
          ),
        ],
      ),
    );
  }
}
