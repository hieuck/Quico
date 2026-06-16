import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show File;
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/validators.dart';
import '../../../core/database/app_database.dart' ;
import '../../../core/local_storage/image_storage_service.dart';
import '../../../core/local_storage/local_file_storage.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import '../../../l10n/l10n_extension.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _lowStockCtrl = TextEditingController(text: '5');
  String? _imagePath;
  bool _loading = false;
  bool get _editing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) _loadProduct();
  }

  Future<void> _loadProduct() async {
    final database = ref.read(appDatabaseProvider);
    final repo = ProductRepository(db);
    final product = await repo.getProductById(widget.productId!);
    if (product != null) {
      _nameCtrl.text = product.name;
      _skuCtrl.text = product.sku ?? '';
      _salePriceCtrl.text = product.salePrice.toString();
      _costPriceCtrl.text = product.costPrice.toString();
      _stockCtrl.text = product.stockQuantity.toString();
      _lowStockCtrl.text = product.lowStockThreshold.toString();
      _imagePath = product.imagePath;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _salePriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _stockCtrl.dispose();
    _lowStockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final service = ImageStorageService(LocalFileStorage());
      final path = await service.saveProductImage(picked.path, IdGenerator.newId());
      if (path != null) {
        setState(() => _imagePath = path);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final database = ref.read(appDatabaseProvider);
      final repo = ProductRepository(db);
      final storeId = await (database.select(database.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
      if (storeId == null) return;

      if (_editing) {
        await repo.updateProduct(UpdateProductInput(
          id: widget.productId!,
          name: _nameCtrl.text.trim(),
          sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
          costPrice: int.tryParse(_costPriceCtrl.text) ?? 0,
          salePrice: int.tryParse(_salePriceCtrl.text) ?? 0,
          stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
          lowStockThreshold: int.tryParse(_lowStockCtrl.text) ?? 5,
          imagePath: _imagePath,
        ));
      } else {
        await repo.createProduct(CreateProductInput(
          storeId: storeId.value,
          name: _nameCtrl.text.trim(),
          sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
          costPrice: int.tryParse(_costPriceCtrl.text) ?? 0,
          salePrice: int.tryParse(_salePriceCtrl.text) ?? 0,
          stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
          lowStockThreshold: int.tryParse(_lowStockCtrl.text) ?? 5,
          imagePath: _imagePath,
        ));
      }
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.saveFailed)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Product' : context.l10n.addProduct)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity),
                      )
                    : const Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.add_photo_alternate, size: 32), Text('Add Photo')],
                      )),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Ten san pham'), validator: Validators.productName),
            const SizedBox(height: 12),
            TextFormField(controller: _skuCtrl, decoration: const InputDecoration(labelText: 'Ma SKU (khong bat buoc)')),
            const SizedBox(height: 12),
            TextFormField(controller: _salePriceCtrl, decoration: InputDecoration(labelText: context.l10n.salePrice), keyboardType: TextInputType.number, validator: (v) => Validators.salePrice(int.tryParse(v ?? ''))),
            const SizedBox(height: 12),
            TextFormField(controller: _costPriceCtrl, decoration: const InputDecoration(labelText: 'Gia von (khong bat buoc)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextFormField(controller: _stockCtrl, decoration: InputDecoration(labelText: context.l10n.inventory), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextFormField(controller: _lowStockCtrl, decoration: const InputDecoration(labelText: 'Canh bao ton kho toi thieu'), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const CircularProgressIndicator() : Text(_editing ? context.l10n.save : context.l10n.addProduct),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
