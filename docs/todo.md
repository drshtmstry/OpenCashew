# OpenCashew — Master To-Do & Roadmap

> Last updated: 2026-11-18

> [!IMPORTANT]
> **Upstream source code is frozen at v5.3.4+396** (last GitHub release, 2 years ago).
> The live web app runs **v6.7.2+521** — all 6.x features were developed privately and have **no public source code**.
> Everything in the sections below is implemented and maintained natively for OpenCashew.

---

## 🟢 Completed Core Capabilities & Enhancements

### 1. Milestone 1: Data Organization, Bulk Actions & Filters
- [x] **Payee / Payer Management System** — added `Payee` entity to Drift database schema, with transaction associations, category/subcategory linking, autocompletion in transaction entry, and dedicated management UI.
- [x] **Category-Centric Payees & Associated Titles** — titles and payees are unified under their respective categories and subcategories with direct re-assignment.
- [x] **Bulk Edit Note** — edit notes across multiple selected transactions at once from Search / Transactions list.
- [x] **Bulk Edit Include/Exclude in Totals** — toggle whether selected transactions count towards budget and spending summaries in bulk.
- [x] **Excluded from Totals Transactions Filter** — filter specifically for transactions excluded from totals.
- [x] **Boolean Search Logic (`&&` and `||`)** — support combining keywords with logical AND (`&&`) or OR (`||`) in note/title searches.
- [x] **Transaction Sorting** — sort transactions in Search page and monthly lists by Date (Newest/Oldest), Amount (Highest/Lowest), Title, and Category.
- [x] **Account Archiving** — archive inactive accounts without deleting historical transaction history; dedicated archived accounts section.

### 2. Milestone 2: Homescreen Visuals & Hierarchical Budgets
- [x] **Pinned Transactions Homepage Section (`HomePagePinnedTransactions`)** — quick-access horizontal carousel of pinned frequent transactions with 1-tap duplicate, long-press options, and row-level pin/unpin toggles.
- [x] **Stacked Bar Graph Homepage Section (`HomePageStackedBar`)** — periodic comparative spending visualization powered by `fl_chart`, supporting 7D, 4W, and 6M timeframes, breakdown by Top Categories or Income vs Expense.
- [x] **Hierarchical Visual Representation of Category → Subcategories for Budgets** — visual tree connectors, branch indicators, and percentage-of-parent metrics in `CategoryLimits` and budget breakdowns.

### 3. Milestone 3: Calendar Page & Budget Enhancements
- [x] **Calendar Page (`CalendarPage`)** — full calendar view accessible from navigation, More page, and Transactions list:
  - Monthly calendar grid with day cells showing transaction count indicators and net/expense totals.
  - Month summary banner showing total Income, Expense, and Net balance.
  - Single tap a day to view that day's itemized transactions list.
  - Double tap any day cell to instantly open Add Transaction preset to that date.
  - Toggle between Net Totals vs Expense Totals on calendar day cells.
  - Fast month-to-month navigation with "Today" quick-jump button.
- [x] **Subcategory Filter Support for All Budgets** — updated Drift query expressions (`isInCategory` and `isInCategoryCheck`) to evaluate both `tbl.categoryFk` and `tbl.subCategoryFk`. Added interactive subcategory include/exclude filter chips in `AddBudgetPage`.
- [x] **Spending Per Day and Total Day Metrics when Setting Custom Budget Period** — calculates and displays Total Days, Daily Allowance (`selectedAmount / totalDays`), and Days Remaining in `AddBudgetPage`.

### 4. Account Customization & Enhancements
- [x] **Account Types System** — `bank`, `cash`, `card`, `prepaid`, `savings`, `other` with smart auto-detection heuristics based on account title.
- [x] **Default Account Type Icons** — standard Material icons mapped to each account type (e.g., globe icon for online wallets/prepaid, bank for checking, card for credit/debit).
- [x] **Custom Logo / Image File Picking & Storage** — pick images from device gallery/files, persisted locally in app storage (`account_icons/`), rendered cleanly via `WalletIcon`.
- [x] **Group Accounts by Type in Accounts List** — grouped accounts list with type headers, account counts, and section balances.
- [x] **Streamlined List Rows & Actions in Edit Account** — removed row-level clutter; Default, Archive, and Delete actions moved cleanly into Edit Account (`AddWalletPage`).
- [x] **Account Icon/Logo in Transactions** — `WalletTag` displays account icon/logo directly preceding the account name in transaction tags.
- [x] **Merge Accounts Feature** — reassigns transactions, transfers, and budgets to a target account and removes the source account safely.

### 5. Quick Wins & Modern Layouts
- [x] **Category Icon Packs** — 592 official assets (`categories-mono/`, `categories-outlined/`, `intelligence/`) with Default Color, Monochrome, and Outlined styles.
- [x] **Surface Hidden Settings** — non-compact transaction layout, scroll physics override, bill splitter shortcut, incognito keyboard, battery saver, long-term loan differences.
- [x] **Modern "More" Page Layout** — clean 2-column shortcut grid, dedicated *Edit, Delete, and Reorder Data* section (`EditDataGrid`).
- [x] **Title Suggestions (3–4 results)** — multi-result suggestion list with category icon, subcategory title, and substring matching.
- [x] **Subcategory Prioritization for Auto-Created Titles** — auto-associates and updates reused titles to the selected subcategory.
- [x] **5-Type Category System & Balance Correction Summary** — both, expense, income, transfer, balance correction, with toggle to count balance corrections in summaries.
- [x] **FAB Speed Dial with Animated + to × Transformation** — floating mini-menu for Expense, Income, Transfer, and More.
- [x] **Transfer Always Enabled** — balance transfer as a first-class feature without requiring a toggle gate.
- [x] **Default Navigation Overhaul** — Home, Summary, Speed Dial (+), Accounts, and More.
- [x] **Categorized Settings Hub** — organized into Main Settings card and Tools & Extras card.
- [x] **Font Scale Slider** (0.8×–1.4×) wired to app-wide text scaler.
- [x] **Left-Handed Access Toggle** inverting FAB and navigation.
- [x] **Progress Bar Style** (Simple flat vs Wavy) with sinusoidal painter.
- [x] **Export Selected Transactions from Search Page as CSV**.

---

## 🟡 Remaining Settings & Feature Polish

- [ ] **Evaluate Partial Calculation when Entering Amounts** (e.g., `50+30`) — _changelog 6.0.0_
- [ ] **Copy/Paste Calculations when Entering Amounts** — _changelog 6.0.0_
- [ ] **Budget Spending Limit Total Type Setting** — _changelog 6.0.0_
- [ ] **Savings Budget vs Expense Budget Type** — _web app audit_
- [ ] **Reorder / Disable Shortcuts on More Page** — _changelog 6.0.0_
- [ ] **Biometrics Auto-Lock After App Closed** — _changelog 6.0.0_
- [ ] **Custom Period per Account in Account Summary Statistics** — _changelog 6.0.0_
- [ ] **Export Transactions with Date Range in CSV** — _changelog 5.3.5_

---

## 🔴 User Experience & Guidance

- [x] **New Onboarding Tutorial and Feature Highlight Overlays** — guided walkthrough matching 6.x design with top-left dismiss, typography, budget information popup, and Google Sign-in / local skip flow.

---

## ⚪ Descoped / Excluded from Plan (Per User Direction)

- [-] **Intelligence / AI Natural Language Parsing**:
  - Google Gemini API integration (`models/gemini-flash-lite-latest`) via API key
  - Custom Webhook, SMS, and Regex transaction parser configurations
  - Parsed message inspection log
  - Settings section: Experimental > Intelligence
- [-] **Deep Link / App Link API (Android)** — automate adding transactions via external URL parameters.
- [-] **Import Google Sheet (Real-Time Sync)** — _web app audit_
- [-] **Import CSV via Google Drive** — _changelog 6.0.0_
- [-] **Auto-detect Unstandardized CSV Formats** (semicolon-separated etc.) — _changelog 6.0.0_
- [-] **Support Custom Font Files** — allow user-provided `.ttf`/`.otf` — _changelog 6.0.0_
- [-] **New Floating Navigation Bar Option** (Android) — _changelog 6.0.0_

---

## 🔵 Build & Release

- [ ] Set up Android signing (keystore) for release builds
- [ ] Verify app runs cleanly with `flutter run --release`
- [ ] Test package references (`org.opencashew.app`) on physical device
- [ ] Verify Google Drive backup with Firebase project config
