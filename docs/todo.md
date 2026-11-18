# OpenCashew — To-Do List

> Last updated: 2026-11-15

> [!IMPORTANT]
> **Upstream source code is frozen at v5.3.4+396** (last GitHub release, 2 years ago).
> The live web app runs **v6.7.2+521** — all 6.x features were developed privately and have **no public source code**.
> Everything in the 🟡 and 🔴 sections below must be **implemented from scratch**, using only:
> - Changelog descriptions (already synced into `showChangelog.dart`)
> - Live web app UI observations (`budget-track.web.app`)
> - APK decompilation if needed for logic details

---

## 🟢 Quick Wins (low effort, high impact)

- [x] **Category Icon Packs** — extracted 592 official assets (`categories-mono/`, `categories-outlined/`, `intelligence/`) from 6.7.5 APK into `assets/`, registered in `pubspec.yaml`, enabled icon pack selection (Default Color, Monochrome, Outlined) in both Edit Categories and Settings > More Options > Style.
- [x] **Surface hidden settings** into the main Settings UI:
  - [x] Non-compact / Large transaction layout toggle → Settings > More Options > Style
  - [x] Scroll behavior (System default, Bouncing iOS, Clamping Android) → Settings > More Options > Style & wired to `ScrollBehaviorOverride`
  - [x] Bill Splitter shortcut toggle → Settings > Tools
  - [x] Incognito keyboard toggle → Settings > More Options > Transactions
  - [x] Battery saver toggle → Settings > More Options > Transactions
  - [x] Long-term loans difference feature toggle → Settings > More Options > Accounts
- [x] **Better default home page** — enabled Net Worth, Goals/Objectives, Loans, Upcoming/Overdue, and All Spending Summary by default so the home page is rich and modern on fresh launch.
- [x] **Modern "More" Page Layout** — overhauled to match 6.7.5 / web app:
  - Prominent top cards: *Settings & Customization*, *All Spending Summary*
  - Clean, balanced 2-column shortcut grid (4 rows / 8 shortcuts):
    - Row 1: *About* & *Cloud Backup*
    - Row 2: *Subscriptions* & *Scheduled*
    - Row 3: *Goals* & *Loans*
    - Row 4: *Activity Log* & *Bill Splitter*
    - (Removed redundant FAQ and Feedback cards since they are already integrated inside the About page).
  - Dedicated **Edit, Delete, and Reorder Data** section (`EditDataGrid`) with a clean 3×2 grid for Accounts, Categories, Titles, Budgets, Goals, and Loans.
- [x] **Title Suggestions (3–4 results)** — expanded `SelectTitle` and `TitleInput` in `addTransactionPage.dart` to return up to 4 recommendations (instead of 1), rendering a multi-result suggestion list with category icon, category/subcategory title, and bolded substring matching.
- [x] **Subcategory Prioritization for Auto-Created Titles** — fixed the bug in `addTransactionPage.dart` where `addAssociatedTitles` was hardcoded to `selectedCategory` (main category). It now checks `selectedSubCategory ?? selectedCategory`, links new titles to the subcategory if selected, and updates existing titles from main category to subcategory when reused.
- [x] **Main Category Types & Balance Correction Summary** — added 5-type category system (`CategoryType`: `both`, `expense`, `income`, `transfer`, `balanceCorrection`):
  - Default main categories keep blank/both and can be used for either expense or income.
  - Categories set as Income or Expense can only be used for that respective transaction type.
  - Type Transfer for linked transfer transactions, always excluded from expense/income summaries.
  - Type Balance Correction for account balance adjustments, with a toggle (`countBalanceCorrectionInSummary`) to count balance corrections in expense/income summaries when desired.
- [x] **Balance Correction Count in Summary Toggle** — when a balance correction is performed in `CorrectBalancePopup` (or edited in `AddTransactionPage`), a dedicated toggle `"Count as Expense/Income in Summary"` is now displayed:
  - If enabled, the balance correction transaction is stored in `countedBalanceCorrectionPks` and counted in daily, monthly, category, and total spending summaries as expense (if negative) or income (if positive).
  - Can be toggled on/off individually per correction or globally via the summary settings.
- [x] **FAB Speed Dial with Animated + to × Transformation** — tapping the FAB reveals a floating mini-list floating directly above the `+` button, while the `+` icon smoothly rotates 45° into an `×`:
  - **Expense**: opens Add Transaction preset to Expense (`selectedIncome: false`).
  - **Income**: opens Add Transaction preset to Income (`selectedIncome: true`).
  - **Transfer**: opens the Transfer Balance sheet directly (or prompts to create a 2nd account if only 1 account exists).
  - **More Options**: shortcut directly opens the full "More options" popup for Account, Budget, Category, Goal, Loan, etc.
  - Backdrop barrier with smooth fade and tap-to-dismiss.
  - Seamlessly respects left-handed FAB alignment and screen navigation bar paddings.
  - Opt-in setting under Settings > More Options > Transactions (`selectTransactionTypeBeforeAdding`), default off so tapping `+` directly opens Add Transaction normally.
- [x] **Transfer Always Enabled Without Setting Gate** — completely removed the unnecessary "Show balance transfer tab" setting toggle from settings, quick actions, and long-press menus. Balance transfer is now treated as a core, first-class capability like Expense and Income. If only 1 account exists, tapping Transfer displays a prompt explaining at least 2 accounts are needed with a direct "Add Account" shortcut.
- [x] **Account Types System** — implemented comprehensive Account Types (`AccountType`: `bank`, `cash`, `card`, `prepaid`, `savings`, `other`):
  - **Account Type Selector**: added `SettingsContainerDropdown` in `AddWalletPage` allowing selection when adding or editing an account.
  - **Smart Automatic Heuristic**: new accounts auto-detect type based on title (e.g. "Cash" → Cash, "Card" → Card, "Wallet/UPI Lite/Prepaid" → Prepaid, "Bank" → Bank).
  - **Tags & Badges**: accounts list in `EditWalletsPage` and account header in `WalletDetailsPage` now prominently display their Account Type badge.
- [x] **Home Transactions Header & Revamped Default Navigation Tabs** — replaced the All/Expense/Income sliding selector on the home page with a prominent, tappable **"Transactions →"** header that directly opens the Transactions list page:
  - Frees up the bottom navigation bar shortcuts for higher-priority hubs.
  - **Tab 1 (Shortcut 0)**: Home
  - **Tab 2 (Shortcut 1)**: Summary (`allSpending`)
  - **Center**: FAB Speed Dial (+ / ×)
  - **Tab 3 (Shortcut 2)**: Accounts (`accountDetails`)
  - **Tab 4**: More
  - Added auto-migration for existing installs to upgrade default nav shortcuts to Summary and Accounts without losing custom configurations.
- [x] **Settings Page Categorized Hub Overhaul** — restructured flat settings page into modern Cashew 6.x grouped rounded cards matching official layout:
  - **Card 1 (Main Settings)**:
    1. *General Settings* (`Icons.settings_outlined`) — Biometric lock, haptic feedback, edit home page, edit data grid, extra text guides, scroll behavior, left-handed FAB.
    2. *Theme & Style* (`Icons.palette_outlined`) — Accent color picker, Material You toggle, theme mode dropdown, icon pack, outlined icons, font picker, font scale slider, progress bar style, animations, text contrast, non-compact transactions.
    3. *Transactions* (`Icons.dashboard_outlined`) — Speed dial mini-list toggle, default transaction type, auto-pay upcoming, mark as paid on day, net spending day total, monthly spending summary, incognito keyboard, battery saver, balance correction summary toggle, accounts, budgets, goals, titles, tags, activity log, widgets.
    4. *Localization & Formatting* (`Icons.language_outlined`) — Language picker, primary currency, number formatting/delimiter, percentage precision, 24-hour time, date format, first day of week, number pad format, extra zeros button.
    5. *Notifications* (`Icons.notifications_outlined`) — Daily & upcoming transaction reminders.
    6. *Import & Export Data* (`Icons.save_outlined`) — CSV import/export, database backup/restore, Google Drive sync.
    7. *About OpenCashew* (`Icons.info_outline`) — App info, open source link, licenses.
  - **Section Header**: "Tools & Extras"
  - **Card 2 (Tools & Extras)**:
    1. *Bill Splitter* (`Icons.receipt_long_outlined`) — Bill splitting tool.
    2. *Advanced Automation* (`Icons.view_in_ar_outlined`) — External App Links documentation shortcut.
    3. *Experimental Features* (`Icons.science_outlined`) — Email scanning, notification scanning (Android), bill splitter shortcut.

---

## 🟡 Missing Settings / Preferences

> From changelog 6.0.0 "Revamp and organize settings page" — these were listed as new settings added in that release.

- [x] **Font Scale** slider (0.8×–1.4×) in Theme settings & wired to app-wide text scaler — _changelog 6.0.0_
- [x] **Left-Handed Access** toggle (inverts FAB and navigation placement) — _changelog 6.0.0_
- [x] **Date Format** selector (Locale default, DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD) — _changelog 6.0.0_
- [x] **Default Transaction Type** preference (Expense/Income default in Add Transaction) — _web app audit_
- [x] **Progress Bar Style** toggle (Simple flat vs Wavy) & custom sinusoidal painter — _changelog 6.0.0 "New progress bar style"_
- [x] **Date Selector Type** setting (wheel picker vs calendar dialog) — _changelog 6.0.0_
- [x] **Animated Budget Container** toggle (disable for performance) — _changelog 6.0.0_
- [x] **Prompt for Upcoming Transaction Amount When Paid** — toggle — _changelog 6.0.0_
- [x] **Amount Totals Colored Style** (colorful vs simple net totals) — _changelog 6.0.0_
- [x] **Gray Theme Color** — additional accent color preset — _changelog 6.0.0_
- [ ] **Support Custom Font Files** — allow user-provided `.ttf`/`.otf` — _changelog 6.0.0_
- [ ] **New Floating Navigation Bar option** (Android) — _changelog 6.0.0_
- [x] **Custom Add Transaction Flow** — disable and reorder prompts when adding a transaction — _changelog 6.0.0_
- [x] **Transaction Row Entry Interactions** setting — action button vs tap-to-expand — _changelog 6.0.0_
- [x] **Display Transaction Time** in transaction entry setting — _changelog 6.0.0_
- [x] **Use Subcategory Icon** instead of primary icon in transaction entry — _changelog 6.0.0_
- [x] **Group Transfer Transactions** together toggle — _changelog 6.0.0_
- [x] **Net Total Style** setting (colorful/simple) — _changelog 6.0.0 "Net total style setting"_
- [ ] **Biometrics Auto-lock After App Closed** — _changelog 6.0.0_

---

## 🔴 Missing Features (need new code)

### Homepage Sections
- [x] **Stacked Bar Graph** homepage section — periodic comparative spending visualization (_web app audit_)
  - New file: `lib/pages/homePage/homePageStackedBar.dart`
  - Add `stackedBar` key to `homePageOrder` in `defaultPreferences.dart`
  - Register in `homePage.dart` and `editHomePage.dart`
- [x] **Pinned Transactions** homepage section — _changelog 6.0.0 "Pinned transactions home page section"_
  - New file: `lib/pages/homePage/homePagePinnedTransactions.dart`
  - Includes: long-press `+` button to pin, pinned transactions list UI, merged with common/frequent transactions
  - Add `pinnedTransactions` key to `homePageOrder`
  - Register in `homePage.dart` and `editHomePage.dart`

### Transaction Features
- [x] **Payee / Payer Management** — mapped per Category and Subcategory with quick-add chips in transaction entry, category-centric management in `AddCategoryPage`, and automatic labeling — _changelog 6.0.0_
- [x] **Pinned Transactions** manager shortcut from the `+` long-press menu — manager already supports adding, ordering, and unpinning; direct pinning from a transaction's `+` action remains a follow-up — _changelog 6.0.0_
- [x] **Bi-weekly and Quarterly** repeat options for scheduled transactions — _changelog 6.0.0_
- [x] **Excluded from Totals** transactions filter — _changelog 6.0.0 "Excluded from totals transactions filter"_
- [x] **Filter "Notes contains" and "Title contains" with AND (`&&`) / OR (`||`)** logic — _changelog 6.0.0_
- [x] **Sort Transactions** in Search page and monthly list (Date, Amount, Alphabetical) — _changelog 6.0.0_
- [x] **Export Selected Transactions** from Search page as CSV — reuses transaction selection and CSV encoding/file saving — _changelog 6.0.0_
- [ ] **Evaluate Partial Calculation** when entering amounts (e.g., `50+30`) — _changelog 6.0.0_
- [ ] **Copy/Paste Calculations** when entering amounts — _changelog 6.0.0_
- [x] **Edit Note on All Selected Transactions** (bulk edit) — _changelog 6.0.0_
- [x] **Edit Include/Exclude Toggle** when bulk editing selected transaction amounts — _changelog 6.0.0_
- [x] **Account Archiving** — in `AddWalletPage`, toggle "Archive Account"; in `EditWalletsPage`, active accounts and archived accounts are separated with a dedicated archived section — _changelog 6.0.0_

### Pages & Navigation
- [ ] **Calendar Page** — daily totals, monthly total banner, filter/search, double-press day to add transaction, net/day total toggle — _changelog 5.3.5 "New calendar page"_
- [ ] **Reorder/Disable Shortcuts** on More page and full-screen sidebar — _changelog 6.0.0_
- [ ] **Add Page Info Section** / guide text throughout app — _changelog 6.0.0_

### Budgets
- [x] **Hierarchical Visual Representation** of category → subcategories for budgets — _changelog 6.7.0_
- [ ] **Spending Per Day and Total Day Metrics** when setting custom budget period — _changelog 6.7.0_
- [ ] **Subcategory Filter Support** for all transaction budgets — _changelog 6.0.0_
- [ ] **Budget Spending Limit Total Type** setting — _changelog 6.0.0_
- [ ] **Savings Budget vs Expense Budget** type — _web app audit_

### Accounts & Import
- [x] **Account Currency Options List** — the Edit Account screen presents currency choices as a searchable list instead of tiles.
- [x] **View Transactions with Account Filter** — Edit Account screen opens Search with that wallet filter applied.
- [ ] **Accounts List Page** (dedicated accounts overview) — _changelog 6.0.0_
- [ ] **Account Spending Summary Table** — _changelog 5.2.6_
- [ ] **Ability to Archive Accounts** — _changelog 6.0.0_
- [ ] **Group Accounts by Color** in home page accounts list — _changelog 6.0.0_
- [ ] **Custom Period per Account** in account summary statistics — _changelog 6.0.0_
- [ ] **Import CSV via Google Drive** — _changelog 6.0.0_
- [ ] **Auto-detect Unstandardized CSV** formats (semicolon-separated etc.) — _changelog 6.0.0_
- [ ] **Export Transactions with Date Range** in CSV — _changelog 5.3.5_
- [ ] **Import Google Sheet** (real-time sync) — _web app audit_

### Intelligence & Automation
- [ ] **Intelligence / AI Natural Language Parsing** — 6.7.5 implementation identified:
  - Supports Google Gemini (`models/gemini-flash-lite-latest`) via API key
  - Supports on-device Android AICore & Apple Intelligence
  - Setting keys: `intelligenceFeature`, `intelligenceGemini`, `nextGenChosenDefaultModelId`, `nextGenEditBeforeAdding`
  - Custom Webhook, SMS, and Regex parser configurations
  - Parsed message inspection log
  - Settings section: Experimental > Intelligence
- [ ] **Transaction Mailbox** — Google Sheets webhook sync for headless transaction entry — _web app audit_
- [ ] **iOS Shortcuts** support — _changelog 6.0.0, 5.3.5_ _(iOS-only, lower priority)_
- [ ] **Deep Link / App Link API** (Android) — automate adding transactions via URL — _changelog 5.2.4, 5.0.5_

### Onboarding
- [ ] **New Onboarding Tutorial and Feature Highlight Overlays** — _changelog 6.0.0 "Onboarding UI guide and overlay hints"_

---

## 🔵 Build & Release

- [ ] Set up Android signing (keystore) for release builds
- [ ] Verify app runs cleanly on emulator with `flutter run --release`
- [ ] Test all renamed package references (`org.opencashew.app`) on physical/emulator device
- [ ] Verify Google Drive backup still works (needs Firebase project config)

---

## ✅ Done

- [x] Flatten repo — Flutter app moved to root (was in `budget/` subfolder)
- [x] Rebrand to OpenCashew (`org.opencashew.app`, display name `OpenCashew`)
- [x] Clean Git history — 928 upstream commits preserved + 1 clean OpenCashew commit on top
- [x] Sync in-app changelog (`getChangelogString()`) with 6.x release notes
- [x] Delete unused files — `promotional/`, `reference/`, old google-services JSON files
- [x] Fix emulator — cleared corrupted snapshot + zombie QEMU processes
- [x] Android Studio project renamed (`.idea/OpenCashew.iml`, `.idea/.name`)
- [x] Gap analysis vs live web app completed
- [x] Full changelog cross-reference completed
