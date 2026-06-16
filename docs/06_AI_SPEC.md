# 06_AI_SPEC.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này mô tả toàn bộ yêu cầu AI của Quico.

Mục tiêu:

* Lên đơn bằng giọng nói.
* Lên đơn bằng văn bản tự nhiên.
* Lên đơn từ ảnh chụp tin nhắn.
* Nhập sản phẩm từ ảnh menu.
* Khớp sản phẩm thông minh.
* Luôn cho người dùng xác nhận trước khi lưu dữ liệu thật.
* Không làm app phụ thuộc hoàn toàn vào cloud AI.

AI trong Quico phải giúp người bán thao tác nhanh hơn, nhưng không được thay thế quyền kiểm soát của người dùng.

---

# AI Product Principle

Quico AI hoạt động theo nguyên tắc:

```txt
Recognize → Parse → Match → Review → Confirm → Save
```

Không có AI flow nào được phép bỏ qua bước `Review`.

---

# Scope For Version 1

AI features bắt buộc trong v1:

* Voice-to-order.
* Text-to-order.
* Screenshot/chat-to-order.
* Menu image import.
* Product matching.
* AI order review.
* Local-first business assistant cơ bản.

AI features không bắt buộc trong v1:

* Cloud LLM.
* Chatbot hội thoại dài.
* Dự đoán doanh thu nâng cao.
* Tự động đặt hàng nhà cung cấp.
* Đồng bộ AI đa thiết bị.

---

# Non-Negotiable Rules

## 1. AI Must Not Auto-Complete Sales

AI không được tự động:

* Hoàn tất đơn.
* Trừ kho.
* Ghi doanh thu.
* Tạo sản phẩm hàng loạt.
* Sửa dữ liệu cũ.

Người dùng phải xác nhận.

---

## 2. Manual Flow Must Always Work

Nếu AI lỗi, app vẫn phải cho phép:

* Tạo đơn thủ công.
* Thêm sản phẩm thủ công.
* Nhập đơn bằng text thủ công.
* Chỉnh sửa kết quả AI.

AI không được làm hỏng POS chính.

---

## 3. Offline-First Preference

V1 ưu tiên:

* Device speech recognition.
* Local OCR.
* Rule-based parser.

Không được bắt buộc người dùng đăng nhập cloud để bán hàng.

---

## 4. Vietnamese-First

AI phải ưu tiên tiếng Việt.

Phải hỗ trợ các dạng nói/viết phổ biến:

```txt
2 cà phê sữa
hai cà phê sữa
2 cafe sữa
2 cf sữa
1 trà đào 35k
ba bánh mì mỗi cái 20 nghìn
```

---

## 5. Confirm Uncertainty

Nếu AI không chắc:

* Đánh dấu `Cần kiểm tra`.
* Không cho hoàn tất đơn nếu còn lỗi nghiêm trọng.
* Cho phép người dùng chọn sản phẩm hoặc tạo sản phẩm mới.

---

# AI Architecture

Required components:

```txt
AI Order Input
├─ SpeechToTextService
├─ OcrService
├─ OrderTextParser
├─ MenuTextParser
├─ ProductMatchingService
├─ AiOrderReviewService
└─ AiBusinessAssistantService
```

---

# Required Interfaces

## SpeechToTextService

```dart
abstract class SpeechToTextService {
  Future<SpeechTranscriptionResult> listenAndTranscribe();
}
```

Result model:

```dart
class SpeechTranscriptionResult {
  final String text;
  final double? confidence;
  final Duration? duration;
  final String? locale;
  final bool isFinal;

  const SpeechTranscriptionResult({
    required this.text,
    this.confidence,
    this.duration,
    this.locale,
    required this.isFinal,
  });
}
```

---

## OcrService

```dart
abstract class OcrService {
  Future<OcrResult> extractTextFromImage(String imagePath);
}
```

Result model:

```dart
class OcrResult {
  final String text;
  final List<OcrBlock> blocks;
  final double? confidence;

  const OcrResult({
    required this.text,
    required this.blocks,
    this.confidence,
  });
}

class OcrBlock {
  final String text;
  final double? confidence;

  const OcrBlock({
    required this.text,
    this.confidence,
  });
}
```

---

## OrderTextParser

```dart
abstract class OrderTextParser {
  Future<ParsedOrderDraft> parse(String input);
}
```

---

## MenuTextParser

```dart
abstract class MenuTextParser {
  Future<List<ParsedMenuProduct>> parse(String input);
}
```

---

## ProductMatchingService

```dart
abstract class ProductMatchingService {
  Future<ProductMatchResult> matchProduct({
    required String storeId,
    required String rawName,
  });
}
```

---

# Core AI Data Models

## ParsedOrderDraft

```dart
class ParsedOrderDraft {
  final String originalInput;
  final OrderInputSource source;
  final String? customerHint;
  final List<ParsedOrderItem> items;
  final String? note;
  final List<AiWarning> warnings;

  const ParsedOrderDraft({
    required this.originalInput,
    required this.source,
    required this.items,
    this.customerHint,
    this.note,
    this.warnings = const [],
  });
}
```

---

## ParsedOrderItem

```dart
class ParsedOrderItem {
  final String rawName;
  final int quantity;
  final int? unitPrice;
  final String? note;
  final ProductMatch? productMatch;
  final List<AiWarning> warnings;

  const ParsedOrderItem({
    required this.rawName,
    required this.quantity,
    this.unitPrice,
    this.note,
    this.productMatch,
    this.warnings = const [],
  });
}
```

---

## ProductMatch

```dart
class ProductMatch {
  final String? productId;
  final String productName;
  final ProductMatchConfidence confidence;
  final double score;

  const ProductMatch({
    required this.productId,
    required this.productName,
    required this.confidence,
    required this.score,
  });
}
```

---

## ProductMatchConfidence

```dart
enum ProductMatchConfidence {
  exact,
  high,
  medium,
  low,
  unknown,
}
```

---

## OrderInputSource

```dart
enum OrderInputSource {
  manual,
  voice,
  text,
  screenshot,
}
```

---

## AiWarning

```dart
class AiWarning {
  final AiWarningType type;
  final String message;
  final bool blocking;

  const AiWarning({
    required this.type,
    required this.message,
    required this.blocking,
  });
}
```

Warning types:

```dart
enum AiWarningType {
  unknownProduct,
  lowConfidenceProduct,
  missingPrice,
  invalidQuantity,
  duplicateItem,
  unclearText,
  ocrLowConfidence,
  speechLowConfidence,
}
```

---

# Feature 1: Voice-to-Order

## Purpose

Cho phép người bán đọc đơn hàng bằng tiếng Việt và chuyển thành đơn nháp.

---

## User Flow

```txt
Home / POS
↓
Tap "Nói đơn"
↓
Request microphone + speech permission if needed
↓
Listen
↓
Transcribe speech to text
↓
Show recognized text
↓
Parse text into order draft
↓
Match products
↓
Show AI Order Review
↓
User confirms
↓
Save order
```

---

## Example Inputs

```txt
2 cà phê sữa, 1 trà đào
hai trà sữa size L
bán cho chị Lan 3 bánh mì mỗi cái 20 nghìn
2 cafe sữa 30k, 1 nước cam 25k
cho khách 1 bún bò, 2 trà đá
```

---

## Expected Output Example

Input:

```txt
2 cà phê sữa 30k, 1 trà đào 35k
```

Output:

```json
{
  "source": "voice",
  "customer_hint": null,
  "items": [
    {
      "raw_name": "cà phê sữa",
      "quantity": 2,
      "unit_price": 30000
    },
    {
      "raw_name": "trà đào",
      "quantity": 1,
      "unit_price": 35000
    }
  ],
  "note": null,
  "warnings": []
}
```

---

## Voice Recognition Requirements

The implementation must:

* Request permission only when user uses voice feature.
* Support Vietnamese locale where available.
* Show real-time or final transcription if package supports it.
* Let user retry.
* Let user edit recognized text before parsing if needed.

---

## Voice Error Handling

If microphone permission denied:

```txt
Quico cần quyền micro để tạo đơn bằng giọng nói.
Bạn vẫn có thể nhập đơn bằng văn bản hoặc tạo đơn thủ công.
```

Actions:

* Open Settings.
* Use Text Order.
* Create Manual Order.

If speech recognition fails:

```txt
Không nhận được giọng nói.
Bạn có thể thử lại hoặc nhập bằng văn bản.
```

Actions:

* Retry.
* Use Text Order.
* Create Manual Order.

---

## Voice Acceptance Criteria

Voice-to-order is complete only when:

* User can tap microphone.
* App requests required permission.
* App records/transcribes Vietnamese speech.
* Recognized text is displayed.
* Text is parsed into order items.
* Product matching runs.
* Review screen appears.
* User can edit result.
* User can complete order.
* Failure states have fallback.
* Unit/widget tests cover parser and review flow.

---

# Feature 2: Text-to-Order

## Purpose

Cho phép người bán nhập hoặc dán nội dung đơn hàng bằng tiếng Việt tự nhiên.

---

## User Flow

```txt
Home / AI Order
↓
Tap "Nhập text"
↓
Enter or paste order text
↓
Tap "Phân tích đơn"
↓
Parse text
↓
Match products
↓
Show AI Order Review
↓
User confirms
↓
Save order
```

---

## Supported Text Patterns

Quantity before product:

```txt
2 cà phê sữa
3 bánh mì
```

Vietnamese number words:

```txt
hai cà phê sữa
ba trà đào
một bánh mì
```

Price with `k`:

```txt
2 trà đào 35k
```

Price with `nghìn`:

```txt
1 bánh mì 20 nghìn
```

Price with `ngàn`:

```txt
1 nước cam 25 ngàn
```

Price with full number:

```txt
1 trà sữa 35000
```

Customer hint:

```txt
bán cho chị Lan 2 cà phê sữa
khách Nam lấy 3 bánh mì
```

Notes:

```txt
2 trà đào ít đá
1 cà phê sữa không đường
```

Multiple separators:

```txt
2 cà phê sữa, 1 trà đào
2 cà phê sữa + 1 trà đào
2 cà phê sữa và 1 trà đào
```

---

## Parser Requirements

The parser must detect:

* Product name.
* Quantity.
* Unit price if present.
* Customer hint if obvious.
* Notes if obvious.
* Duplicate items.

The parser must normalize:

* `k` → `000`
* `nghìn` → `000`
* `ngàn` → `000`
* Vietnamese number words → integer
* Vietnamese accented/unaccented product names.

---

## Vietnamese Number Words

Must support at least:

```txt
một = 1
mốt = 1
hai = 2
ba = 3
bốn = 4
tư = 4
năm = 5
lăm = 5
sáu = 6
bảy = 7
bẩy = 7
tám = 8
chín = 9
mười = 10
```

V1 does not need complex large-number natural language parsing beyond common order quantities.

---

## Text-to-Order Error Handling

If no item detected:

```txt
Quico chưa nhận ra sản phẩm nào.
Bạn có thể sửa nội dung hoặc tạo đơn thủ công.
```

If price missing and product not matched:

```txt
Sản phẩm này chưa có trong danh sách và chưa có giá.
Vui lòng chọn sản phẩm hoặc nhập giá.
```

---

## Text Acceptance Criteria

Text-to-order is complete only when:

* User can enter text.
* Parser detects common Vietnamese order patterns.
* Existing products are matched.
* Unknown products are marked.
* Missing price is handled.
* Review screen appears.
* User can edit before saving.
* Parser has unit tests for common patterns.

---

# Feature 3: Screenshot / Chat-to-Order

## Purpose

Cho phép người bán chuyển ảnh chụp tin nhắn khách hàng thành đơn nháp.

---

## User Flow

```txt
Home / AI Order
↓
Tap "Ảnh tin nhắn"
↓
Choose image or take photo
↓
OCR extracts text
↓
Show OCR text preview
↓
Parse text
↓
Match products
↓
Show AI Order Review
↓
User confirms
↓
Save order
```

---

## Supported Sources

The app must support:

* Select image from photo library.
* Take photo using camera.
* Use screenshot from chat app.

---

## OCR Requirements

OCR must:

* Work on-device where possible.
* Extract Vietnamese text as best effort.
* Return raw text.
* Return blocks if available.
* Handle multi-line text.

Example chat screenshot text:

```txt
Chị lấy giúp em:
2 trà đào
1 bánh mì thịt
ship qua địa chỉ cũ nhé
```

Expected parsed result:

```json
{
  "source": "screenshot",
  "items": [
    {
      "raw_name": "trà đào",
      "quantity": 2
    },
    {
      "raw_name": "bánh mì thịt",
      "quantity": 1
    }
  ],
  "note": "ship qua địa chỉ cũ nhé"
}
```

---

## OCR Review Requirement

Before parsing or before saving, user must be able to see the OCR text.

Minimum:

* Show extracted text.
* Allow user to edit extracted text.
* Then parse edited text.

This is important because OCR can be wrong.

---

## OCR Error Handling

If image cannot be read:

```txt
Không đọc được ảnh này.
Bạn có thể thử ảnh khác, sửa ảnh rõ hơn hoặc nhập đơn bằng văn bản.
```

Actions:

* Try another image.
* Use Text Order.
* Create Manual Order.

If OCR text is too short:

```txt
Ảnh này không có đủ nội dung để tạo đơn.
```

Actions:

* Choose another image.
* Enter text manually.

---

## Screenshot Acceptance Criteria

Screenshot-to-order is complete only when:

* User can select image.
* User can take photo.
* OCR extracts text.
* User can review/edit OCR text.
* Parser converts OCR text into order draft.
* Product matching runs.
* Review screen appears.
* User can edit before saving.
* OCR failure has fallback.
* Tests cover OCR text parsing with representative samples.

---

# Feature 4: Menu Image Import

## Purpose

Cho phép người dùng chụp ảnh menu/bảng giá và tạo danh sách sản phẩm nhanh.

---

## User Flow

```txt
Products
↓
Tap "Import Menu"
↓
Choose/take menu photo
↓
OCR extracts text
↓
MenuTextParser detects product names and prices
↓
Show detected products review
↓
User edits/selects items
↓
Save selected products
```

---

## Example Menu Text

```txt
Cà phê đen 25k
Cà phê sữa 30k
Trà đào cam sả 35k
Bánh mì thịt 20k
```

Expected output:

```json
[
  {
    "name": "Cà phê đen",
    "sale_price": 25000
  },
  {
    "name": "Cà phê sữa",
    "sale_price": 30000
  },
  {
    "name": "Trà đào cam sả",
    "sale_price": 35000
  },
  {
    "name": "Bánh mì thịt",
    "sale_price": 20000
  }
]
```

---

## Menu Parser Requirements

The parser must detect:

* Product name.
* Sale price.
* Possible duplicate product.
* Lines that are not products.

Supported price patterns:

```txt
25k
25.000
25,000
25 nghìn
25 ngàn
25000
```

---

## Menu Import Review Screen

Each detected product must show:

* Product name.
* Sale price.
* Duplicate warning if matched with existing product.
* Checkbox selected by default.
* Edit action.

User can:

* Edit name.
* Edit price.
* Unselect item.
* Save selected items.

---

## Duplicate Handling

If detected product matches existing product:

* Mark as duplicate.
* Do not auto-update existing product.
* Let user choose:

  * Skip.
  * Create new anyway.
  * Update existing price.

Default behavior:

```txt
Skip duplicate
```

---

## Menu Import Acceptance Criteria

Menu import is complete only when:

* User can choose/take menu image.
* OCR extracts text.
* Parser detects products and prices.
* User can review/edit detected products.
* Duplicate products are detected.
* No product is saved without confirmation.
* Selected products are saved to local database.
* Tests cover common menu formats.

---

# Feature 5: Product Matching

## Purpose

Khớp sản phẩm được AI/OCR/parser nhận diện với sản phẩm có sẵn trong database.

---

# Matching Pipeline

Product matching must follow this order:

```txt
1. Exact name match
2. Normalized exact match
3. SKU/barcode match if input contains code
4. Contains/starts-with match
5. Fuzzy match
6. Unknown product
```

---

## Text Normalization

Normalize both input and product names.

Rules:

* Lowercase.
* Trim.
* Remove Vietnamese diacritics.
* Replace multiple spaces with one.
* Remove common punctuation.
* Normalize common abbreviations.

Examples:

```txt
"Cà phê sữa đá" -> "ca phe sua da"
"cafe sữa" -> "cafe sua"
"cf sữa" -> "cafe sua"
"trà-đào" -> "tra dao"
```

---

## Abbreviation Dictionary

V1 must support common abbreviations:

```txt
cf -> cafe
cafe -> cà phê
caphe -> cà phê
ts -> trà sữa
td -> trà đào
size l -> size lớn
size m -> size vừa
size s -> size nhỏ
```

Abbreviation dictionary must be implemented in a centralized utility, not scattered across parser code.

---

## Confidence Levels

Use:

```txt
exact
high
medium
low
unknown
```

Recommended thresholds:

```txt
exact: exact normalized match (strings identical after normalization)
high: score >= 0.90
medium: score >= 0.75
low: score >= 0.55
unknown: score < 0.55
```

## Matching Algorithm

Use normalized token overlap scoring:

1. Normalize both input and product name (lowercase, remove diacritics, trim, collapse spaces, remove punctuation).
2. Tokenize by space.
3. Compute intersection of tokens between input and product name.
4. Score = `2 * |intersection| / (|input_tokens| + |product_tokens|)`

This gives a Jaccard-like score between 0.0 and 1.0.

Process:
- If exact normalized match → `exact`.
- Else if score >= 0.90 → `high`.
- Apply abbreviation expansion before scoring (e.g., `cf` → `cafe` → `cà phê` via centralized dictionary).
- If abbreviation expansion produces multiple candidates, take the highest score.

Example:
```txt
Input: "cf sua"
Product: "Cà phê sữa"
Normalized input: "cf sua"
Abbreviation expanded: "cafe sua" → "ca phe sua"
Normalized product: "ca phe sua"
Tokens: ["ca", "phe", "sua"] ∩ ["ca", "phe", "sua"] = 3/3 = 1.0 → exact
```

No external fuzzy string library is required for v1.

---

## Match Behavior

### exact

User sees:

```txt
Đã khớp
```

Can complete order.

### high

User sees:

```txt
Đã khớp
```

Can complete order.

### medium

User sees:

```txt
Cần kiểm tra
```

Can complete only after user confirms.

### low

User sees:

```txt
Cần chọn sản phẩm
```

Must select or create product.

### unknown

User sees:

```txt
Sản phẩm mới
```

Must select existing product or quick-create.

---

# Feature 6: AI Order Review

## Purpose

Tất cả đơn do AI tạo phải qua màn hình review.

---

## Required Review Data

The review screen must show:

* Source: voice/text/screenshot.
* Original input text.
* Detected items.
* Product match status.
* Quantity.
* Unit price.
* Line total.
* Warnings.
* Customer hint if detected.
* Note if detected.

---

## Required User Actions

User must be able to:

* Edit product.
* Edit quantity.
* Edit unit price.
* Remove item.
* Add item.
* Select existing product for unknown item.
* Quick-create product for unknown item.
* Save as draft.
* Complete order.
* Cancel.

---

## Blocking Conditions

Complete Order button must be disabled if:

* No items.
* Any item has invalid quantity.
* Any item has unknown product and no unit price.
* Any item has blocking warning.
* Total amount cannot be calculated.

---

## Non-Blocking Conditions

User may still complete order if:

* Product match confidence is medium but user confirms.
* Product does not exist but user enters name and price.
* Stock is low but negative stock is allowed.
* OCR confidence is low but user manually edits result.

---

# Feature 7: AI Business Assistant

## Purpose

Cho phép người dùng hỏi nhanh dữ liệu kinh doanh bằng tiếng Việt.

V1 assistant có thể rule-based, không cần LLM.

---

## Supported Questions V1

Must support:

```txt
Hôm nay bán được bao nhiêu?
Hôm nay có bao nhiêu đơn?
Tháng này doanh thu bao nhiêu?
Tháng này lãi bao nhiêu?
Món nào bán chạy nhất?
Sản phẩm nào sắp hết hàng?
Khách nào mua nhiều nhất?
Còn đơn nào chưa thanh toán?
```

---

## Assistant Flow

```txt
User asks question
↓
Normalize question
↓
Classify intent
↓
Query local SQLite through ReportRepository
↓
Return plain Vietnamese answer
```

---

## Example Answers

Input:

```txt
Hôm nay bán được bao nhiêu?
```

Answer:

```txt
Hôm nay cửa hàng đã bán được 1.250.000đ từ 24 đơn hàng.
```

Input:

```txt
Món nào bán chạy nhất tháng này?
```

Answer:

```txt
Tháng này sản phẩm bán chạy nhất là Trà đào với 86 lượt bán.
```

---

## Assistant Requirements

The assistant must:

* Use local data.
* Not require Internet.
* Not hallucinate numbers.
* Say clearly when there is no data.
* Avoid giving business advice beyond available data in v1.

If unsupported question:

```txt
Quico hiện chưa hỗ trợ câu hỏi này. Bạn có thể xem báo cáo doanh thu, sản phẩm bán chạy hoặc đơn chưa thanh toán.
```

---

# Parser Implementation Strategy

V1 parser should be rule-based.

Reason:

* Predictable.
* Offline-capable.
* Testable.
* No API cost.
* Easier to debug.

Cloud LLM can be added later behind the same parser interface.

---

## Parser Ambiguity Strategy

When the parser cannot confidently determine phrase boundaries, it must apply these rules in order:

1. **Over-include text into product name** rather than drop it. If uncertain whether a word is part of the product name or a note, include it in the name (e.g., `"bún bò Huế"` stays as one product name, not split into `"bún bò"` + note `"Huế"`).
2. **Mark over-included items as `low confidence`** so the review screen flags them.
3. **Never silently discard text** — any unparsed text must become an order note or a warning.
4. **If no quantity is detected, default to 1** and mark as `low confidence`.
5. **If no items are detected at all**, return empty list with a blocking warning. The user must edit the input or switch to manual POS.

This ensures the parser is conservative: it would rather produce an imperfect draft that the user can fix than silently lose data.

## Parser Pipeline

```txt
Raw input
↓
Normalize whitespace
↓
Normalize price tokens
↓
Split into candidate item phrases
↓
Detect quantity
↓
Detect price
↓
Detect product name
↓
Detect notes
↓
Detect customer hint
↓
Match products
↓
Return ParsedOrderDraft
```

---

## Candidate Separators

Parser should split on:

```txt
,
.
;
+
và
xuống dòng
```

But must not split product names incorrectly if possible.

---

## Price Detection

Supported:

```txt
30k
30K
30 nghìn
30 ngàn
30.000
30,000
30000
```

Examples:

```txt
1 trà đào 35k -> unit_price = 35000
2 bánh mì 20 nghìn -> unit_price = 20000
```

---

## Quantity Detection

Supported:

```txt
2 cà phê
x2 cà phê
cà phê x2
hai cà phê
1 phần bún bò
```

Default quantity:

```txt
1
```

if product detected but quantity missing.

---

## Customer Hint Detection

Supported patterns:

```txt
bán cho {name}
khách {name}
chị {name}
anh {name}
cô {name}
chú {name}
```

Customer hint is optional and should not block order creation.

---

## Note Detection

Notes may include:

```txt
ít đá
không đường
nhiều sữa
ship
giao
địa chỉ
lấy sau
```

Notes should be attached to item or order when reasonable.

If uncertain, attach to order note.

---

# Privacy Requirements

AI features must respect local-first privacy.

Rules:

* Do not upload images to unknown external services.
* Do not send sales/customer data to cloud LLM in v1.
* Store OCR extracted text only if needed for order audit/debug.
* Do not store original screenshots unless user explicitly attaches them.
* Do not store microphone audio after transcription.

---

# Data Storage For AI

Orders created from AI should store:

```txt
orders.source
orders.original_input
```

Allowed source values:

```txt
voice
text
screenshot
manual
```

AI parse logs may be stored in:

```txt
ai_parse_logs
```

But this is optional.

If implemented, logs must not contain image binary or audio files.

---

# Permission Requirements

Voice-to-order requires:

* Microphone permission.
* Speech recognition permission on iOS.

Screenshot/menu OCR requires:

* Photo library permission for image picking.
* Camera permission for taking photo.

Permission copy must be user-friendly and Vietnamese.

---

# iOS Info.plist Requirements

The app must include:

```txt
NSMicrophoneUsageDescription
NSSpeechRecognitionUsageDescription
NSCameraUsageDescription
NSPhotoLibraryUsageDescription
```

Suggested Vietnamese text:

```txt
Quico cần quyền micro để tạo đơn bằng giọng nói.
Quico cần quyền nhận dạng giọng nói để chuyển lời nói thành đơn hàng.
Quico cần quyền camera để chụp ảnh sản phẩm, menu hoặc tin nhắn.
Quico cần quyền ảnh để chọn ảnh sản phẩm, menu hoặc ảnh tin nhắn.
```

---

# Error Handling Matrix

| Failure              | User Message                     | Required Fallback            |
| -------------------- | -------------------------------- | ---------------------------- |
| Microphone denied    | Không có quyền micro             | Text order/manual order      |
| Speech unavailable   | Không nhận dạng được giọng nói   | Retry/text order             |
| OCR failed           | Không đọc được ảnh               | Try another image/text order |
| Parser found no item | Chưa nhận ra sản phẩm nào        | Edit text/manual order       |
| Unknown product      | Sản phẩm chưa có trong danh sách | Select/create product        |
| Missing price        | Chưa có giá bán                  | Enter price/select product   |
| Low confidence       | Cần kiểm tra lại                 | User confirmation            |
| Database save failed | Không thể lưu đơn                | Retry/manual save            |

---

# Testing Requirements

## Parser Tests

Must test:

```txt
2 cà phê sữa
hai cà phê sữa
2 cà phê sữa 30k
1 trà đào 35 nghìn
3 bánh mì mỗi cái 20k
2 cafe sua + 1 tra dao
bán cho chị Lan 2 trà đào
1 cà phê ít đường
```

---

## Product Matching Tests

Must test:

```txt
Cà phê sữa -> exact
ca phe sua -> normalized exact
cf sữa -> abbreviation match
trà đào -> high match
tra dao cam -> medium/low match depending catalog
unknown product -> unknown
```

---

## OCR Text Parsing Tests

Must test multi-line input:

```txt
Em lấy:
2 trà đào
1 bánh mì thịt
ship địa chỉ cũ
```

Expected:

* 2 items.
* Order note contains shipping note.

---

## Menu Parser Tests

Must test:

```txt
Cà phê đen 25k
Cà phê sữa 30.000
Trà đào cam sả 35 nghìn
Bánh mì thịt 20000
```

Expected:

* 4 products.
* Correct sale prices.

---

## Review Flow Tests

Must test:

* Unknown item blocks complete order.
* Missing price blocks complete order.
* Medium confidence requires confirmation.
* Exact match can complete.
* User can edit quantity.
* User can remove item.

---

# AI Acceptance Criteria

AI implementation is complete only when:

* Voice-to-order works.
* Text-to-order works.
* Screenshot-to-order works.
* Menu image import works.
* OCR text can be reviewed and edited.
* All AI-generated orders go through review screen.
* Product matching supports exact, normalized and fuzzy matching.
* Unknown products are handled.
* Missing prices are handled.
* User can quick-create product from AI result.
* AI failure does not block manual POS.
* Parser has unit tests.
* Product matching has unit tests.
* Review flow has widget or controller tests.
* iOS permissions are configured.
* No cloud AI dependency is required for core selling flow.

---

# Final Instruction For Developer

Implement AI features as required in this document.

Do not treat voice, OCR or text parsing as optional placeholders.

If a provider package fails or blocks iOS build:

1. Replace it with the simplest stable alternative.
2. Preserve the required user-facing feature.
3. Keep the abstraction intact.
4. Record the decision in `BUILD_SPEC.md` under `Decision Log / Technical Debt`.

AI is successful only when it helps a real seller create orders faster while still preserving user control and data integrity.

END OF DOCUMENT
