# OpenCashew Codebase & Architecture Guide (GEMINI.md)

This file provides persistent architectural context, directory mappings, component references, and critical engineering rules for AI agents operating on OpenCashew.

---

## 1. Project Overview & Tech Stack

- **Framework**: Flutter (Dart)
- **App / Package ID**: `org.opencashew.app`
- **Database / ORM**: Drift (SQLite) defined in `lib/database/tables.dart`. All tables, DAOs, reactive queries, and watchers live here.
- **State Management**: `Provider` (e.g., `AllWallets`, `appStateSettings` defined in `lib/struct/settings.dart`).
- **Localization**: `easy_localization` (Use `"key".tr()` for UI strings; translation files live in `assets/translations/`).
- **Theming & Design**: `lib/colors.dart`, dynamic pastel coloring (`dynamicPastel`), Material You support.

---

## 2. Directory & Component Map

### Core Architecture & Database
- `lib/database/tables.dart`: Single source of truth for database schema. Contains `Transactions`, `TransactionCategories`, `TransactionWallets`, `Budgets`, `Objectives`, `Payees`, `AssociatedTitles`, `TransactionTags`. Access via global `database.*`.
- `lib/struct/settings.dart`: Global app preferences map (`appStateSettings`), key-value setters, and defaults.

### Transaction Screens & Forms
- `lib/pages/addTransactionPage.dart`:
  - Handles both **Add Transaction** (`widget.transaction == null`) and **Edit Transaction** (`widget.transaction != null`).
  - Header Card (`transactionAmountAndCategoryHeader`): Colored container holding:
    1. `IncomeExpenseTabSelector` (Expense / Income / Transfer selector)
    2. Category Icon (`CategoryIcon`) and Amount Display (`convertToMoney`)
    3. Subcategory Chips (`SelectSubcategoryChips`)
    4. Payee / Payer Chips (`SelectPayeeChips`)
  - Form Fields (`transactionDetailsParameters`): Date/time selector, special type chips (Default / Upcoming / Subscription), wallet/account picker, title/note input, attachments, and "More Options" toggle.
  - Bottom Bar (`staticOverlay`): "Save Changes" / "Add Transaction" CTA and type actions.

### Dashboard & Navigation
- `lib/pages/homePage.dart` & `lib/pages/homePage/`: Main dashboard displaying account summary cards, pinned frequent transactions (`HomePagePinnedTransactions`), comparative spending graph (`HomePageStackedBar`), and recent transaction feed.
- `lib/pages/allTransactionsPage.dart`: Itemized transaction lists with date filters, search, bulk notes, bulk totals exclusion, and sorting.
- `lib/pages/calendarPage.dart`: Month calendar view showing net/expense totals per day cell with quick-jump to date.

### Accounts & Wallets
- `lib/pages/addWalletPage.dart`: Add & edit account screen. Manages account types (`bank`, `cash`, `card`, `prepaid`, `savings`, `other`), custom icons, default toggle, archiving, and merging accounts.
- `lib/widgets/walletIcon.dart`: Renders account logo/icon (Material icon detection or custom image from device storage).

### Key Reusable Widgets
- `lib/widgets/selectChips.dart`: `SelectChips<T>` horizontal scrollable choice chip row. Supports single/multiple selection, sticky extra buttons, dynamic colors, and item measurement.
- `lib/widgets/framework/pageFramework.dart`: Universal screen scaffold. Supports pinned or collapsing `SliverAppBar`, `listWidgets` (injected into `SliverList`), floating overlay buttons (`staticOverlay`), and drag-down-to-dismiss gestures.
- `lib/widgets/categoryIcon.dart`: Renders category icons with support for monochrome, outlined, and custom image packs.
- `lib/widgets/openPopup.dart`: Standardized popups, bottom sheets, and discard changes confirmation (`discardChangesPopup`).

---

## 3. Critical Architectural Rules & Anti-Patterns

### Rule 1: Always Cache Drift Streams in StatefulWidget
**Never** invoke `database.watch...()` directly inside a `build()` method.
```dart
// ❌ WRONG: Creates a new stream on every build, triggering infinite rebuilds and ANR freezes
@override
Widget build(BuildContext context) {
  return StreamBuilder(stream: database.watchAllCategories(), ...);
}

// ✅ CORRECT: Cache in state, update in didUpdateWidget when dependencies change
late Stream<List<Category>> _stream;
@override
void initState() {
  super.initState();
  _stream = database.watchAllCategories();
}
```

### Rule 2: Subcategory Chips Placement
- `SelectSubcategoryChips` belongs **inside** `transactionAmountAndCategoryHeader` directly below the Category Icon + Amount row.
- Do not place `SelectSubcategoryChips` as an independent item in `PageFramework.listWidgets` (this creates visual detachment from the colored header card and triggers layout assertion errors inside `SliverList`).

### Rule 3: Safe Size Measurement in Custom Layouts
When using `WidgetSize` (`lib/widgets/util/widgetSize.dart`):
- Always guard with `if (!mounted) return;`
- Always verify `renderBox is RenderBox && renderBox.hasSize` before reading `.size` during animations to prevent unhandled layout exceptions.

### Rule 4: ChoiceChip Layout Constraints
Inside `SelectChips`, chip avatars must never use `Column(mainAxisSize: MainAxisSize.max)`. Always use `MainAxisSize.min` to avoid unbounded height errors inside measurement stacks.

### Rule 5: Strictly Mobile-Only (Android & iOS)
- OpenCashew is **mobile-only**. Do not run `flutter create --platforms=web/windows` or attempt web/desktop builds.
- Database access uses `lib/database/platform/native.dart` with `dart:ffi` and `package:drift/native.dart` directly. Web browsers do not support `dart:ffi`.

### Rule 6: Type Safety in Drift Helper Functions
- In Drift expressions and custom query helper functions (such as `isInCategory`), never leave table references untyped or operate on `dynamic` expressions.
- Drift operators (`&`, `|`, `not()`) are **extension methods** (`extension BooleanExpressions on Expression<bool>`). Extension methods **cannot be called dynamically** in Dart; doing so causes runtime `NoSuchMethodError: Class 'BaseInfixOperator<bool>' has no instance method '&'`.
- Always statically type column expressions (e.g. `final Expression<String> categoryCol = tbl.categoryFk;`).

---

## 4. Build & Verification Environment

- **Target Device / Emulator**: `emulator-5554` (or connected physical device).
- **Fast Development Workflow (Interactive Hot Reload)**:
  Run once and keep the session active:
  ```powershell
  $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
  flutter run -d emulator-5554
  ```
  - Press `r` to Hot Reload in ~0.5s.
  - Press `R` to Hot Restart in ~1.5s.
  - **Never** repeatedly invoke `flutter build apk` for incremental UI tweaks when an interactive run session can hot reload immediately.
- **Android JDK Path**: Always use Android Studio's bundled JBR:
  ```powershell
  $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
  ```
- **Static Analysis**: Must always pass with 0 errors:
  ```powershell
  (flutter analyze --no-pub | Select-String -Pattern "error -").Count -eq 0
  ```
- **Build APK Command**:
  ```powershell
  flutter build apk --debug
  ```
- **Install & Launch via ADB**:
  ```powershell
  & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r build\app\outputs\flutter-apk\app-debug.apk
  & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" shell am start -n org.opencashew.app/org.opencashew.app.MainActivity
  ```
