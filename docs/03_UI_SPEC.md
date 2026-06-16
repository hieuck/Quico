# 03_UI_SPEC.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này mô tả thiết kế giao diện, trải nghiệm người dùng, navigation, design system, user flows, wireframes và yêu cầu UI chi tiết cho Quico.

Mục tiêu:

* Developer có thể triển khai UI mà không phải tự đoán.
* Giao diện phải đủ tốt để dùng thật, không phải demo.
* UI phải tối ưu cho iOS trước nhưng không khóa chặt vào iOS native component.
* Trải nghiệm phải phù hợp với người bán hàng phổ thông.

---

# Design Direction

Quico sử dụng phong cách:

> Hybrid iOS-first

Nghĩa là:

* Ưu tiên cảm giác giống app iPhone.
* Dùng bottom tab navigation.
* Typography rõ ràng, khoảng trắng hợp lý.
* Component đơn giản, bo góc mềm.
* Không quá “enterprise”.
* Không quá nhiều hiệu ứng.
* Không copy UI của Knote hoặc bất kỳ app POS nào.

---

# Design Goals

Quico UI phải đạt các mục tiêu sau:

## 1. Fast Selling

Mọi thao tác bán hàng phải nhanh.

Người dùng phải có thể:

* Mở app.
* Bấm tạo đơn.
* Chọn sản phẩm.
* Thanh toán.
* Chia sẻ hóa đơn.

trong thời gian ngắn nhất.

---

## 2. One-Hand Friendly

Các action chính nên nằm trong vùng dễ chạm bằng ngón cái.

Ưu tiên:

* Bottom tab.
* Floating action button.
* Button lớn.
* Input dễ bấm.
* List item cao vừa đủ.

---

## 3. Low Cognitive Load

Người dùng không rành công nghệ vẫn dùng được.

Tránh:

* Quá nhiều thuật ngữ kỹ thuật.
* Menu nhiều tầng.
* Form dài không cần thiết.
* Dashboard quá dày số liệu.

---

## 4. Confirm AI Output

Tất cả kết quả từ AI/OCR/voice phải được hiển thị để người dùng xác nhận.

Không được tự động:

* Tạo đơn hoàn tất.
* Trừ kho.
* Ghi doanh thu.
* Tạo sản phẩm hàng loạt.

---

## 5. Offline Confidence

Người dùng phải biết rõ app vẫn hoạt động khi mất mạng.

Nếu không có mạng:

* Không được khóa tính năng bán hàng.
* Có thể hiện trạng thái “Đang dùng ngoại tuyến”.
* Sync/cloud không được chặn thao tác chính.

---

# Visual Identity

## Brand Personality

Quico nên tạo cảm giác:

* Nhanh.
* Gọn.
* Thân thiện.
* Đáng tin.
* Hiện đại.
* Không rối.

---

## Color Palette

Primary:

```txt
Blue 600: #2563EB
Blue 500: #3B82F6
Blue 50:  #EFF6FF
```

Success:

```txt
Green 600: #16A34A
Green 500: #22C55E
Green 50:  #F0FDF4
```

Warning:

```txt
Amber 600: #D97706
Amber 500: #F59E0B
Amber 50:  #FFFBEB
```

Error:

```txt
Red 600: #DC2626
Red 500: #EF4444
Red 50:  #FEF2F2
```

Neutral:

```txt
Slate 950: #020617
Slate 900: #0F172A
Slate 700: #334155
Slate 500: #64748B
Slate 300: #CBD5E1
Slate 100: #F1F5F9
Slate 50:  #F8FAFC
White:     #FFFFFF
```

---

# Typography

Use system font:

* iOS: SF Pro
* Android fallback: Roboto
* Web fallback: Inter/system sans-serif

Typography scale:

```txt
Display Large: 32 / 40 / Bold
Title Large:   24 / 32 / Bold
Title Medium:  20 / 28 / Semibold
Title Small:   18 / 24 / Semibold
Body Large:    16 / 24 / Regular
Body Medium:   14 / 20 / Regular
Caption:       12 / 16 / Regular
Button:        16 / 22 / Semibold
```

Rules:

* Money values should use semibold or bold.
* Important numbers must be visually prominent.
* Avoid small font for primary actions.
* Minimum readable body text: 14px.

---

# Spacing

Use 4-point grid.

```txt
xs: 4
sm: 8
md: 12
lg: 16
xl: 24
2xl: 32
3xl: 48
```

Screen horizontal padding:

```txt
Default: 16
Dense POS mode: 12
```

---

# Radius

```txt
Small: 8
Medium: 12
Large: 16
Extra Large: 24
Full: 999
```

Rules:

* Cards: 16
* Buttons: 12–16
* Inputs: 12
* Bottom sheets: 24 top radius
* Product image: 12

---

# Shadows

Use subtle shadows only.

Avoid heavy shadows.

Card shadow:

```txt
Blur: 12
Opacity: 0.08
Offset Y: 4
```

Bottom sheet shadow:

```txt
Blur: 24
Opacity: 0.12
Offset Y: -4
```

---

# Icons

Use a consistent icon set.

Recommended:

* Material Symbols Rounded
* Cupertino Icons where platform-specific

Icon style:

* Rounded
* Simple
* No filled-heavy inconsistent icons

Common icons:

```txt
Dashboard: home
Orders: receipt
Products: inventory_2
AI Order: mic / auto_awesome
Customers: person
Reports: bar_chart
Settings: settings
```

---

# App Navigation

Primary navigation uses bottom tabs.

Tabs:

```txt
1. Home
2. Orders
3. Products
4. Reports
5. More
```

Floating primary action:

```txt
New Sale
```

The floating action should open a quick action sheet:

```txt
- Manual Order
- Voice Order
- Text Order
- Screenshot Order
```

---

# Navigation Map

```txt
App Launch
↓
Onboarding Required?
├─ Yes → Onboarding Flow
└─ No  → Main App

Main App
├─ Home
│  ├─ New Manual Order
│  ├─ Voice Order
│  ├─ Text Order
│  ├─ Screenshot Order
│  └─ Low Stock Products
│
├─ Orders
│  ├─ Order List
│  ├─ Order Detail
│  ├─ Receipt
│  └─ Refund/Cancel
│
├─ Products
│  ├─ Product List
│  ├─ Product Detail
│  ├─ Add Product
│  ├─ Edit Product
│  └─ Import Menu Image
│
├─ Reports
│  ├─ Revenue Report
│  ├─ Profit Report
│  ├─ Product Report
│  └─ Customer Report
│
└─ More
   ├─ Customers
   ├─ Expenses
   ├─ Inventory
   ├─ Bank Accounts
   ├─ Backup
   └─ Settings
```

---

# Global UI Components

## Primary Button

Usage:

* Complete order
* Save product
* Confirm AI order
* Export receipt

Style:

* Filled primary color.
* Minimum height: 48.
* Full width in forms.
* Semibold text.

States:

* Default
* Disabled
* Loading
* Pressed

---

## Secondary Button

Usage:

* Cancel
* Back
* Save draft
* View details

Style:

* Light background.
* Primary text.
* Minimum height: 44.

---

## Destructive Button

Usage:

* Delete product.
* Cancel order.
* Remove item.

Style:

* Red text or red filled only for high-risk confirmation.

---

## Text Input

Fields must have:

* Label.
* Placeholder.
* Validation message.
* Clear error state.

Input height:

```txt
48 minimum
```

Keyboard types:

* Price: number keyboard.
* Phone: phone keyboard.
* Quantity: number keyboard.
* Search: search keyboard.

---

## Money Display

Format VND:

```txt
35.000đ
1.250.000đ
```

Rules:

* Do not use decimal places.
* Use thousand separators.
* Align money values to the right in tables/lists where appropriate.

---

## Empty State

Every major list must have empty state.

Empty state must include:

* Icon/illustration.
* Short title.
* Helpful description.
* Primary action.

Example:

```txt
Chưa có sản phẩm
Thêm sản phẩm đầu tiên để bắt đầu bán hàng.
[Thêm sản phẩm]
```

---

## Loading State

Use skeleton loading for:

* Dashboard cards.
* Product list.
* Order list.
* Reports.

Use spinner only for short blocking actions.

---

## Error State

Error state must:

* Explain what happened in plain language.
* Offer retry or fallback.
* Never expose raw stack traces.

Example:

```txt
Không đọc được ảnh
Bạn có thể thử ảnh khác hoặc nhập đơn thủ công.
[Thử lại] [Nhập thủ công]
```

---

# Screen Specifications

---

# 1. Onboarding Flow

## 1.1 Welcome Screen

Purpose:

Introduce Quico quickly.

Content:

```txt
Quico
Bán hàng dễ như nhắn tin.

Quản lý đơn hàng, sản phẩm, doanh thu và tồn kho ngay trên điện thoại.
```

Primary action:

```txt
Bắt đầu
```

Secondary action:

None.

Layout:

```txt
[Logo]
[Product Name]
[Tagline]
[Short Description]

[Primary Button]
```

Requirements:

* No login required.
* No cloud setup required.
* User should reach store setup immediately.

---

## 1.2 Store Setup Screen

Fields:

* Store name: required.
* Business type: optional.
* Currency: fixed VND.

Business type options:

```txt
Quán ăn / đồ uống
Shop online
Tạp hóa / bán lẻ
Khác
```

Primary action:

```txt
Tạo cửa hàng
```

Validation:

* Store name cannot be empty.
* Store name max length: 80 characters.

---

## 1.3 Onboarding Done Screen

Content:

```txt
Cửa hàng đã sẵn sàng
Bạn có thể thêm sản phẩm hoặc tạo đơn ngay.
```

Actions:

```txt
Thêm sản phẩm
Tạo đơn ngay
```

Default recommended action:

```txt
Thêm sản phẩm
```

---

# 2. Home Screen

Purpose:

Give seller immediate overview and quick actions.

Sections:

1. Greeting/store name.
2. Offline/sync status.
3. Today summary cards.
4. Quick actions.
5. Low stock warning.
6. Recent orders.

---

## Home Layout

```txt
[Store Name]                    [Settings Icon]
[Offline/Ready Status]

[Revenue Today Card]
[Orders Today Card]
[Gross Profit Today Card]

[Quick Actions Grid]
- Tạo đơn
- Nói đơn
- Nhập text
- Ảnh tin nhắn

[Low Stock Alert]
[Recent Orders]
```

---

## Summary Cards

Cards:

```txt
Doanh thu hôm nay
Số đơn hôm nay
Lãi gộp hôm nay
```

Each card must show:

* Label.
* Value.
* Comparison optional for later.

---

## Quick Actions

Actions:

```txt
Tạo đơn
Nói đơn
Nhập đơn bằng text
Ảnh tin nhắn
Thêm sản phẩm
Ghi chi phí
```

Important:

* Voice order must be visually prominent.
* Manual order must always be available.

---

# 3. Orders Screen

Purpose:

Allow users to review, search, filter, and manage orders.

## Order List

Filters:

```txt
Tất cả
Đã thanh toán
Chưa thanh toán
Đã hủy
```

Search:

* Search by order code.
* Search by customer name.
* Search by note.

Order item shows:

```txt
Order code
Time
Customer optional
Total amount
Payment status
Order status
```

Example:

```txt
#DH00021
10:35 · Khách lẻ
85.000đ
Đã thanh toán
```

Actions:

* Tap to view detail.
* Swipe optional: mark paid/cancel.

---

## Order Detail

Sections:

```txt
Header
Customer
Items
Payment
Inventory impact
Notes
Actions
```

Actions:

```txt
Chia sẻ hóa đơn
Xuất PDF
Đánh dấu đã thanh toán
Hủy đơn
```

Rules:

* Cancel completed order requires confirmation.
* Editing completed order must warn user about inventory recalculation.

---

# 4. POS / Manual Order Screen

Purpose:

Create order quickly by selecting products manually.

## Layout

Mobile portrait layout:

```txt
[Search Product]

[Product Categories optional]

[Product List/Grid]
- Product image
- Name
- Price
- Stock

[Cart Summary Sticky Bottom]
Items count | Total
[View Cart / Complete]
```

When cart expanded:

```txt
[Cart Items]
- Product name
- Quantity stepper
- Unit price
- Line total
- Remove

[Discount]
[Customer]
[Payment Method]
[Note]

[Save Unpaid] [Complete Order]
```

---

## Product Card

Fields:

* Image or placeholder.
* Product name.
* Sale price.
* Stock badge.

States:

* Normal.
* Low stock.
* Out of stock.
* Inactive hidden.

Rules:

* If product is out of stock, allow selling only if setting allows negative stock.
* Default v1: warn but allow sale.

---

## Cart Item

Controls:

* Increase quantity.
* Decrease quantity.
* Remove.
* Edit unit price optional.
* Add note optional.

Validation:

* Quantity must be greater than 0.
* Unit price must be >= 0.

---

## Complete Order Flow

Steps:

1. User taps Complete.
2. App validates cart.
3. User chooses payment status.
4. App saves order.
5. Inventory updated.
6. Receipt screen displayed.

Payment status options:

```txt
Đã thanh toán
Chưa thanh toán
Thanh toán một phần
```

Payment methods:

```txt
Tiền mặt
Chuyển khoản
Khác
```

---

# 5. AI Order Screen

Purpose:

Create draft orders from voice, text, or screenshot.

Tabs:

```txt
Giọng nói
Văn bản
Ảnh tin nhắn
```

All AI order methods must lead to:

```txt
AI Order Review Screen
```

No AI-created order can skip review.

---

## 5.1 Voice Order Tab

Layout:

```txt
[Large Microphone Button]

Nói đơn hàng của bạn
Ví dụ: "2 cà phê sữa, 1 trà đào 50 nghìn"

[Recognized Text Box]
[Parse Result Preview]

[Thử lại] [Tiếp tục]
```

States:

* Idle.
* Listening.
* Processing.
* Result.
* Error.

Listening state:

```txt
Đang nghe...
```

Processing state:

```txt
Đang nhận dạng đơn hàng...
```

Error state:

```txt
Không nhận được giọng nói
Bạn có thể thử lại hoặc nhập bằng văn bản.
```

---

## 5.2 Text Order Tab

Layout:

```txt
[Multiline Text Input]

Placeholder:
Nhập đơn hàng, ví dụ:
2 cà phê sữa 30k, 1 trà đào 50k

[Phân tích đơn hàng]
```

Rules:

* Minimum text length: 2 characters.
* Parser result must go to review screen.
* Unknown products must be clearly marked.

---

## 5.3 Screenshot Order Tab

Layout:

```txt
[Image Picker Area]

Chọn ảnh tin nhắn hoặc chụp màn hình đơn hàng.

[Chọn ảnh]
[Chụp ảnh]

[OCR Text Preview]
[Phân tích đơn hàng]
```

States:

* No image selected.
* OCR processing.
* OCR result.
* OCR failed.

OCR failure fallback:

```txt
Không đọc được ảnh này.
Bạn có thể thử ảnh khác hoặc nhập đơn bằng văn bản.
```

---

# 6. AI Order Review Screen

Purpose:

Allow user to verify AI-generated draft before saving.

Layout:

```txt
[Source Label]
Tạo từ: Giọng nói / Văn bản / Ảnh

[Original Text]
Collapsible

[Detected Items]
- Product match status
- Quantity
- Unit price
- Line total

[Customer Hint optional]
[Note optional]

[Warnings]
[Edit Items]
[Save Draft] [Complete Order]
```

---

## Product Match Status

Statuses:

```txt
Matched
Low Confidence
Unknown
```

UI labels:

```txt
Đã khớp
Cần kiểm tra
Sản phẩm mới
```

Rules:

* Low confidence items require user confirmation.
* Unknown items require select product or quick-create.
* Complete Order button disabled until critical issues resolved.

---

# 7. Products Screen

Purpose:

Manage product catalog.

## Product List

Layout:

```txt
[Search Bar]
[Filter Chips]
Tất cả | Sắp hết | Hết hàng | Ngừng bán

[Product List/Grid]
[FAB: Add Product]
```

Product list item:

```txt
[Image]
Product Name
Price
Stock
Status badge
```

Actions:

* Tap to detail.
* Long press optional menu:

  * Edit
  * Duplicate
  * Deactivate

---

## Product Detail

Sections:

```txt
Product Image
Name
SKU/Barcode
Sale Price
Cost Price
Stock
Low Stock Threshold
Status
Recent Inventory Movements
```

Actions:

```txt
Sửa
Điều chỉnh tồn kho
Ngừng bán
Xóa
```

Delete behavior:

* If product has historical orders, use soft delete/deactivate.
* Do not hard delete historical data.

---

## Add/Edit Product

Fields:

* Image.
* Name.
* SKU optional.
* Barcode optional.
* Sale price.
* Cost price.
* Stock quantity.
* Low stock threshold.
* Active status.

Validation:

* Name required.
* Sale price required.
* Sale price must be >= 0.
* Cost price must be >= 0.
* Stock quantity can be 0.
* Low stock threshold must be >= 0.

Actions:

```txt
Lưu sản phẩm
Hủy
```

---

## Menu Image Import

Purpose:

Create products from menu photo.

Flow:

```txt
Products
↓
Import Menu
↓
Choose/Take Photo
↓
OCR
↓
Detected Product Review
↓
Save Selected Products
```

Review screen item:

```txt
Detected name
Detected price
Duplicate warning
Checkbox selected by default
Edit button
```

Rules:

* Never auto-save detected products.
* User must confirm.
* Duplicates should be marked.

---

# 8. Customers Screen

Purpose:

Manage customers and view purchase history.

## Customer List

Layout:

```txt
[Search Customer]
[Add Customer Button]

Customer List:
- Name
- Phone
- Total spent
- Total orders
```

---

## Customer Detail

Sections:

```txt
Name
Phone
Note
Total spent
Total orders
Recent orders
```

Actions:

```txt
Edit Customer
Create Order for Customer
```

---

## Add/Edit Customer

Fields:

* Name required.
* Phone optional.
* Note optional.

Validation:

* Name required.
* Phone should allow Vietnamese phone format but not be too strict.

---

# 9. Inventory Screen

Purpose:

Track and adjust product stock.

Layout:

```txt
[Search Product]
[Low Stock Filter]

Product Stock List:
- Product name
- Current stock
- Low stock threshold
- Status badge
```

Actions:

```txt
Adjust Stock
View Movements
```

---

## Adjust Stock Bottom Sheet

Fields:

* Adjustment type.
* Quantity.
* Note.

Adjustment types:

```txt
Nhập thêm
Giảm tồn
Sửa số lượng thực tế
```

Validation:

* Quantity required.
* Note required for correction.

---

# 10. Expenses Screen

Purpose:

Track business expenses.

## Expense List

Filters:

* Today.
* This week.
* This month.
* Custom.

Expense item:

```txt
Category
Amount
Date
Note
```

---

## Add Expense

Fields:

* Category.
* Amount.
* Date.
* Note optional.

Default categories:

```txt
Nguyên liệu
Nhân công
Mặt bằng
Vận chuyển
Marketing
Khác
```

Validation:

* Amount required.
* Amount must be > 0.
* Category required.

---

# 11. Reports Screen

Purpose:

Show business performance.

## Report Filters

Date filters:

```txt
Hôm nay
Tuần này
Tháng này
Tùy chọn
```

---

## Report Sections

Summary:

```txt
Doanh thu
Lãi gộp
Chi phí
Lãi ròng
Số đơn
Giá trị đơn trung bình
```

Product section:

```txt
Sản phẩm bán chạy
Sản phẩm sắp hết hàng
```

Customer section:

```txt
Khách mua nhiều
Khách còn nợ
```

Charts:

* Simple bar chart optional.
* Lists are acceptable for v1.
* Do not block v1 on complex charts.

---

# 12. Receipt Screen

Purpose:

Display and share order receipt.

Layout:

```txt
[Store Name]
[Order Code]
[Date Time]

[Customer optional]

Items:
Product x Quantity
Unit Price
Line Total

Subtotal
Discount
Total

Payment Status
Payment Method

[Share Image]
[Export PDF]
[Done]
```

Rules:

* Receipt must be readable as screenshot.
* Receipt must fit mobile width.
* Export must not require internet.

---

# 13. Settings / More Screen

More screen items:

```txt
Customers
Expenses
Inventory
Bank Accounts
Backup & Restore
Store Settings
App Info
```

---

## Store Settings

Fields:

* Store name.
* Business type.
* Phone.
* Address.
* Logo.

---

## Bank Accounts

Fields:

* Bank name.
* Bank code.
* Account number.
* Account name.
* Default flag.

Used for:

* Bank transfer info.
* VietQR later.

---

## Backup & Restore

Actions:

```txt
Export backup
Import backup
Export JSON
Export database file
```

Warnings:

* Import may overwrite data.
* Backup should be stored safely.

---

# User Flows

## Flow 1: Manual Sale

```txt
Home
↓
Tap "Tạo đơn"
↓
POS Screen
↓
Select products
↓
Adjust cart
↓
Choose payment
↓
Complete order
↓
Receipt
```

---

## Flow 2: Voice Sale

```txt
Home
↓
Tap "Nói đơn"
↓
Voice Order Screen
↓
Speak order
↓
Speech to text
↓
Parse result
↓
Review
↓
Confirm
↓
Receipt
```

---

## Flow 3: Screenshot Sale

```txt
Home
↓
Tap "Ảnh tin nhắn"
↓
Choose image
↓
OCR
↓
Parse text
↓
Review
↓
Confirm
↓
Receipt
```

---

## Flow 4: Add Product With Image

```txt
Products
↓
Tap Add
↓
Enter product info
↓
Add image
↓
Save
↓
Product appears in POS
```

---

## Flow 5: Import Menu

```txt
Products
↓
Import Menu
↓
Take photo
↓
OCR
↓
Review detected products
↓
Save selected
↓
Product list updated
```

---

## Flow 6: Record Expense

```txt
More
↓
Expenses
↓
Add Expense
↓
Enter category and amount
↓
Save
↓
Reports updated
```

---

# Wireframes

## Home

```txt
┌─────────────────────────────┐
│ Quico Shop             ⚙️   │
│ Sẵn sàng bán hàng           │
├─────────────────────────────┤
│ Doanh thu hôm nay           │
│ 1.250.000đ                  │
├──────────────┬──────────────┤
│ Số đơn       │ Lãi gộp      │
│ 24           │ 420.000đ     │
├─────────────────────────────┤
│ Tạo nhanh                   │
│ [Tạo đơn] [Nói đơn]         │
│ [Nhập text] [Ảnh tin nhắn]  │
├─────────────────────────────┤
│ Sắp hết hàng                │
│ Trà đào còn 3               │
├─────────────────────────────┤
│ Đơn gần đây                 │
│ #DH0021        85.000đ      │
└─────────────────────────────┘
```

---

## POS

```txt
┌─────────────────────────────┐
│ Tạo đơn                     │
│ [Tìm sản phẩm...]           │
├─────────────────────────────┤
│ [Ảnh] Cà phê sữa 30.000đ    │
│ [Ảnh] Trà đào    35.000đ    │
│ [Ảnh] Bánh mì    20.000đ    │
├─────────────────────────────┤
│ 3 món              85.000đ  │
│ [Xem giỏ / Thanh toán]      │
└─────────────────────────────┘
```

---

## AI Review

```txt
┌─────────────────────────────┐
│ Kiểm tra đơn hàng           │
│ Tạo từ: Giọng nói           │
├─────────────────────────────┤
│ Nội dung gốc                │
│ "2 cà phê sữa, 1 trà đào"  │
├─────────────────────────────┤
│ Cà phê sữa                  │
│ SL: 2   Giá: 30.000đ        │
│ Đã khớp                     │
├─────────────────────────────┤
│ Trà đào                     │
│ SL: 1   Giá: 35.000đ        │
│ Cần kiểm tra                │
├─────────────────────────────┤
│ [Lưu nháp] [Hoàn tất đơn]   │
└─────────────────────────────┘
```

---

## Product List

```txt
┌─────────────────────────────┐
│ Sản phẩm                    │
│ [Tìm sản phẩm...]           │
├─────────────────────────────┤
│ [Ảnh] Cà phê sữa            │
│ 30.000đ · Còn 12            │
├─────────────────────────────┤
│ [Ảnh] Trà đào               │
│ 35.000đ · Sắp hết           │
├─────────────────────────────┤
│                         [+] │
└─────────────────────────────┘
```

---

# Accessibility Requirements

Quico must support:

* Large readable text.
* Sufficient color contrast.
* Buttons minimum 44px height.
* Tap targets minimum 44x44.
* Icons must have labels where needed.
* Do not rely only on color to communicate status.

---

# Dark Mode

Dark mode should be supported if feasible in v1.

Minimum requirement:

* App must not break visually in dark mode.
* Text must remain readable.
* Cards and surfaces must have proper contrast.

If full dark mode polish is delayed, document in `TECH_DEBT.md`.

---

# Responsive Behavior

Primary target:

* iPhone portrait.

Must support:

* Small iPhone screens.
* Large iPhone screens.
* iPad basic scaling without broken layout.

Not required for v1:

* Full iPad desktop-style layout.
* Web responsive dashboard.

---

# Animation Guidelines

Use subtle animations only.

Allowed:

* Button press feedback.
* Bottom sheet transition.
* Loading skeleton.
* Cart update micro-animation.

Avoid:

* Heavy page transitions.
* Slow animations.
* Decorative animations that delay selling.

---

# Content Language

Primary language:

```txt
Vietnamese
```

Tone:

* Friendly.
* Direct.
* Simple.

Examples:

Good:

```txt
Tạo đơn
Nói đơn
Chưa có sản phẩm
Không đọc được ảnh
```

Bad:

```txt
Initialize Transaction
AI Extraction Failed
Inventory Mutation Error
```

---

# UI Completion Criteria

UI implementation is complete only when:

* Every main screen exists.
* Navigation works.
* Empty states exist.
* Loading states exist.
* Error states exist.
* Forms validate correctly.
* Manual order flow works.
* AI order review flow works.
* Product image UI works.
* Receipt screen is shareable.
* UI does not look like a raw demo.
* App is usable on a real iPhone screen.

END OF DOCUMENT
