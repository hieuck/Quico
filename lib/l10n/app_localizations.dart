import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _strings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    final langCode = locale.languageCode;
    try {
      final jsonStr = await rootBundle.loadString('lib/l10n/app_$langCode.arb');
      _strings = json.decode(jsonStr) as Map<String, dynamic>;
      return true;
    } catch (_) {
      final jsonStr = await rootBundle.loadString('lib/l10n/app_en.arb');
      _strings = json.decode(jsonStr) as Map<String, dynamic>;
      return false;
    }
  }

  String _t(String key, [Map<String, String>? params]) {
    String? value = _strings[key] as String?;
    if (value == null) return key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value!.replaceAll('{$entry.key}', entry.value);
      }
    }
    return value!;
  }

  String get appName => _t('appName');
  String get tagline => _t('tagline');
  String get appDescription => _t('appDescription');
  String get start => _t('start');
  String get createStore => _t('createStore');
  String get storeInfo => _t('storeInfo');
  String get storeName => _t('storeName');
  String get businessType => _t('businessType');
  String get businessTypeOptional => _t('businessTypeOptional');
  String get currencyVND => _t('currencyVND');
  String get storeReady => _t('storeReady');
  String get home => _t('home');
  String get orders => _t('orders');
  String get products => _t('products');
  String get reports => _t('reports');
  String get more => _t('more');
  String get newOrder => _t('newOrder');
  String get manualOrder => _t('manualOrder');
  String get voiceOrder => _t('voiceOrder');
  String get textOrder => _t('textOrder');
  String get screenshotOrder => _t('screenshotOrder');
  String get selectProducts => _t('selectProducts');
  String get orderByVoice => _t('orderByVoice');
  String get pasteOrder => _t('pasteOrder');
  String get chatScreenshot => _t('chatScreenshot');
  String get readyToSell => _t('readyToSell');
  String get revenueToday => _t('revenueToday');
  String get ordersToday => _t('ordersToday');
  String get grossProfit => _t('grossProfit');
  String get quickActions => _t('quickActions');
  String get lowStock => _t('lowStock');
  String get recentOrders => _t('recentOrders');
  String get noProductsYet => _t('noProductsYet');
  String get noOrdersYet => _t('noOrdersYet');
  String get noStore => _t('noStore');
  String get addFirstProduct => _t('addFirstProduct');
  String get productName => _t('productName');
  String get salePrice => _t('salePrice');
  String get costPrice => _t('costPrice');
  String get stockQuantity => _t('stockQuantity');
  String get lowStockThreshold => _t('lowStockThreshold');
  String get skuOptional => _t('skuOptional');
  String get addPhoto => _t('addPhoto');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');
  String get delete => _t('delete');
  String get edit => _t('edit');
  String get deactivate => _t('deactivate');
  String get confirmDelete => _t('confirmDelete');
  String get paid => _t('paid');
  String get unpaid => _t('unpaid');
  String get partial => _t('partial');
  String get cash => _t('cash');
  String get bankTransfer => _t('bankTransfer');
  String get search => _t('search');
  String get total => _t('total');
  String get subtotal => _t('subtotal');
  String get discount => _t('discount');
  String get completeOrder => _t('completeOrder');
  String get saveDraft => _t('saveDraft');
  String get orderCode => _t('orderCode');
  String get customer => _t('customer');
  String get paymentStatus => _t('paymentStatus');
  String get paymentMethod => _t('paymentMethod');
  String get addProduct => _t('addProduct');
  String get importMenu => _t('importMenu');
  String get exportBackup => _t('exportBackup');
  String get importBackup => _t('importBackup');
  String get settings => _t('settings');
  String get storeSettings => _t('storeSettings');
  String get bankAccounts => _t('bankAccounts');
  String get inventory => _t('inventory');
  String get expenses => _t('expenses');
  String get receipt => _t('receipt');
  String get noData => _t('noData');
  String get error => _t('error');
  String get loading => _t('loading');
  String get retry => _t('retry');
  String get confirmOrder => _t('confirmOrder');
  String get confirmOrderBody => _t('confirmOrderBody');
  String get cancelOrder => _t('cancelOrder');
  String get cancelOrderConfirm => _t('cancelOrderConfirm');
  String get cancelOrderBody => _t('cancelOrderBody');
  String get orderCreated => _t('orderCreated');
  String get orderFailed => _t('orderFailed');
  String get saveFailed => _t('saveFailed');
  String get noProducts => _t('noProducts');
  String get noCustomers => _t('noCustomers');
  String get noExpenses => _t('noExpenses');
  String get aiOrder => _t('aiOrder');
  String get photoLibrary => _t('photoLibrary');
  String get takePhoto => _t('takePhoto');
  String get orderReview => _t('orderReview');
  String orderSource(String source) => _t('orderSource', {'source': source});
  String get originalText => _t('originalText');
  String get matched => _t('matched');
  String get needsReview => _t('needsReview');
  String get newProduct => _t('newProduct');
  String get receiptFooter => _t('receiptFooter');
  String get cancelled => _t('cancelled');
  String get refunded => _t('refunded');
  String get draft => _t('draft');
  String get screenshots => _t('screenshots');
  String get version => _t('version');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
