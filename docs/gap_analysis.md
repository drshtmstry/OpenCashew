# OpenCashew vs Live Cashew Web App — Gap Analysis

> Compared: **OpenCashew** codebase (upstream commit `9cfbe50c` + our changes) vs **Cashew Web App v6.7.2+521** at `budget-track.web.app`

---

## TL;DR

Most features **exist in the codebase** but are either:
- Hidden behind **`false` default flags** (need enabling)
- Present but **not surfaced in settings UI** (exist in `debugPage.dart` only)
- **Genuinely missing** (new features added after our upstream snapshot)

---

## 🟢 Present & Working (may appear disabled by default)

| Feature | Status | Setting Key / Note |
|---|---|---|
| Material You theming | ✅ Present | `materialYou` |
| Dark / Light / System theme | ✅ Present | `theme` |
| Black theme (with Material You) | ✅ Present | unlocked by `materialYou` |
| Accent color picker | ✅ Present | `accentColor` |
| Font picker (Avenir/DM Sans/etc.) | ✅ Present | `font` |
| App animations toggle | ✅ Present | `appAnimations` |
| Number count-up animation | ✅ Present | `numberCountUpAnimation` |
| Outlined icons toggle | ✅ Present | `outlinedIcons` |
| High text contrast | ✅ Present | `increaseTextContrast` |
| Short/tall header | ✅ Present | `forceSmallHeader` |
| Edit Home Page (drag & reorder) | ✅ Present | `homePageOrder` |
| Heatmap home section | ✅ Present | `showHeatMap` (default `false`) |
| Pie chart home section | ✅ Present | `showPieChart` (default `false`) |
| Net Worth home section | ✅ Present | `showNetWorth` (default `false`) |
| Goals / Objectives home section | ✅ Present | `showObjectives` (default `false`) |
| Loans home section | ✅ Present | `showObjectiveLoans` (default `false`) |
| Upcoming/Overdue home section | ✅ Present | `showOverdueUpcoming` (default `false`) |
| Subscriptions page | ✅ Present | `SubscriptionsPage` |
| Savings Goals / Objectives | ✅ Present | `AddObjectivePage`, `EditObjectivesPage` |
| Loans / Credit-Debt tracking | ✅ Present | `CreditDebtTransactionsPage`, `objectiveLoanFk` |
| Bill Splitter | ✅ Present | `BillSplitter`; hidden by `showBillSplitterShortcut: false` |
| Shared/Collaborative budgets | ✅ Present | `sharedBudgets: false` (Firebase-dependent) |
| Scheduled / Upcoming transactions | ✅ Present | `TransactionSpecialType` |
| Auto-pay subscriptions/upcoming | ✅ Present | `automaticallyPaySubscriptions`, etc. |
| Home screen widgets (Android) | ✅ Present | `NetWorthWidgetProvider`, `PlusWidgetProvider`, etc. |
| Biometric lock | ✅ Present | `requireAuth` |
| Notifications (daily + upcoming) | ✅ Present | `notifications`, `notificationsUpcomingTransactions` |
| Number formatting (custom) | ✅ Present | `customNumberFormat`, delimiter/decimal keys |
| 24-hour time format | ✅ Present | `use24HourFormat` |
| First day of week | ✅ Present | `firstDayOfWeek` |
| Number pad format & haptics | ✅ Present | `numberPadFormat`, `numberPadHapticFeedback` |
| Percentage precision | ✅ Present | `percentagePrecision` |
| CSV import/export | ✅ Present | — |
| DB import/export | ✅ Present | — |
| Google Drive backup | ✅ Present | — |
| Activity Log | ✅ Present | `ActivityPage` |
| Tags | ✅ Present | `EditTagsPage` |
| Exchange rates | ✅ Present | `ExchangeRatesPage` |
| Customizable bottom nav tabs | ✅ Present | `customNavBarShortcut0/1/2` |
| Long-term loans difference feature | ✅ Present | `longTermLoansDifferenceFeature: false` |
| Email auto-transactions | ✅ Present | `emailScanning: false` |
| Non-compact transaction layout | ✅ Present | `nonCompactTransactions` (in `debugPage.dart`, not settings) |
| Bouncing scroll physics | ✅ Present | `scrollBehaviorOverride.dart` (not exposed in settings UI) |
| Incognito keyboard | ✅ Present | `incognitoKeyboard: false` |
| Battery saver mode | ✅ Present | `batterySaver: false` |
| Notification scanning (Android) | ✅ Present | `notificationScanning: false` |

---

## 🔴 Genuinely Missing — Not in Codebase

These features appear in the live web app but **have no corresponding code** in our upstream snapshot.

### 1. Intelligence / AI Natural Language Parsing
**Web app shows**: `Intelligence` toggle under Experimental features. When enabled, reveals "Message Parsing [Beta]" with:
- Edit transaction before adding toggle
- Custom parser configurations (Webhooks, SMS, Regex rules)
- Parsed message log / inspection view

**Our codebase**: Zero matches for `intelligence`, `Intelligence`, `naturalLanguage`, `messageParser`, or any NLP/AI code.

**What it does**: Parses freeform text messages (bank SMS, notifications) into transactions automatically using configurable regex/webhook rules — not an external AI service.

---

### 2. Transaction Mailbox (Google Sheets Sync)
**Web app shows**: `Transaction Mailbox` toggle — automated headless transaction syncing via Google Sheets webhook.

**Our codebase**: `emailScanning` exists (reads Gmail), but `mailbox` / `Mailbox` → no matches. This is a separate feature.

---

### 3. Stacked Bar Graph Home Section
**Web app shows**: "Stacked Bar Graph" as one of the 16 modular homepage sections — periodic comparative spending visualization.

**Our codebase**: `homePageStackedBar.dart` does **not exist** in `lib/pages/homePage/`. The `homePageOrder` list also doesn't include a `stackedBar` key.

---

### 4. Pinned Transactions Home Section
**Web app shows**: "Pinned Transactions" as a homepage section — quick-access pinned recurring transactions.

**Our codebase**: `homePagePinnedTransactions.dart` does **not exist**. No `showPinnedTransactions` key in `defaultPreferences.dart` either.

---

### 5. Category Icon Pack Selector
**Web app shows**: "Category Icon Pack" setting to select custom icon packs beyond built-in Material icons.

**Our codebase**: `editCategoriesPage.dart` line 853 has `//return CategoryIconPackSelection();` — **commented out**. The widget exists but is disabled.

---

### 6. Font Scale Slider
**Web app shows**: Font Scale slider (0.8× to 1.4×) under Theme settings.

**Our codebase**: No `fontScale` or `textScale` preference key in `defaultPreferences.dart`.

---

### 7. Left-Handed Access Toggle
**Web app shows**: Toggle under Layout settings that inverts FAB and navigation for left-hand thumb reach.

**Our codebase**: No `leftHanded` or `leftHandedMode` key anywhere.

---

### 8. Transactions List Layout (Compact/Comfortable/Detailed)
**Web app shows**: Three-way layout selector for transaction list card density.

**Our codebase**: Only `nonCompactTransactions` boolean exists (and it's in `debugPage.dart`, not settings). No three-way selector.

---

### 9. Progress Bar Style (Simple vs Wavy)
**Web app shows**: Toggle between flat and wavy budget progress bars.

**Our codebase**: No `progressBarStyle` or `wavyProgressBar` key.

---

### 10. Date Format Selector
**Web app shows**: Choose display date format (YYYY-MM-DD, DD/MM/YYYY, MM/DD/YYYY, etc.)

**Our codebase**: Date formatting uses locale-based `DateFormat.*()` calls — no user-configurable date format preference key.

---

### 11. Default Transaction Type Setting
**Web app shows**: Set default to Expense or Income when opening Add Transaction.

**Our codebase**: No `defaultTransactionType` preference key.

---

### 12. Advanced Automation Documentation / Deep Links
**Web app shows**: Full documentation section for App Links (`cashew://...`), iOS Shortcuts integration, Notification/SMS broadcast receivers.

**Our codebase**: No dedicated automation documentation page visible in page list.

---

## 🟡 Present But Needs Surfacing in Settings UI

These keys exist in `defaultPreferences.dart` or logic files, but are **not exposed in the main settings page** (only in `debugPage.dart` or hardcoded):

| Feature | Exists In | Should Move To |
|---|---|---|
| Non-compact transaction layout | `debugPage.dart` | Settings > More Options > Style |
| Bouncing scroll physics | `scrollBehaviorOverride.dart` | Settings > More Options > Style |
| `showBillSplitterShortcut` | preferences, not in settings UI | Settings > Tools |
| `incognitoKeyboard` | preferences key only | Settings > More Options |
| `batterySaver` | preferences key only | Settings > More Options |
| `logging` | preferences key only | Settings > More Options (or debug) |
| `longTermLoansDifferenceFeature` | preferences, behind feature flag | Settings > More Options > Accounts |
| Category Icon Pack | Commented out (`//return CategoryIconPackSelection()`) | Settings or Category edit screen |

---

## Priority Recommendation

| Priority | Action |
|---|---|
| **High** | Implement **Stacked Bar Graph** homepage section (significant visual feature) |
| **High** | Implement **Pinned Transactions** homepage section |
| **High** | Surface hidden settings in Settings UI (non-compact layout, scroll behavior, bill splitter shortcut, incognito keyboard, battery saver) |
| **Medium** | Re-enable **Category Icon Pack** (just uncomment `CategoryIconPackSelection()`) |
| **Medium** | Add **Date Format** selector preference |
| **Medium** | Add **Default Transaction Type** preference |
| **Medium** | Add **Font Scale** slider |
| **Medium** | Add **Left-Handed Access** toggle |
| **Low** | Add **Progress Bar Style** (simple vs wavy) |
| **Low** | Implement **Intelligence / Message Parsing** (complex, regex/webhook rule engine) |
| **Low** | Implement **Transaction Mailbox** (Google Sheets webhook) |
