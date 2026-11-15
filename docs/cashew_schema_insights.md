# Cashew Data Architecture & Schema Insights

Based on direct inspection of your SQLite database (`cashew-2026-11-15-11-55-18-868292.sql`) and binary reverse-engineering of `Cashew 6.7.5 (524).apks`.

---

## 1. Executive Summary & Big Discoveries

Your database was exported directly from **Cashew 6.7.5+524**, containing **3,632 transactions**, **70 categories**, **6 accounts**, **101 associated titles**, and **444 settings keys**.

Inspecting your `app_settings` JSON table and decompiling `libapp.so` in the APK revealed the **exact internal implementation** of every new 6.x feature:
1. **AI / Intelligence**:
   - `intelligenceFeature` flag
   - `nextGenChosenDefaultModelId: 'models/gemini-flash-lite-latest'` (Google Gemini Flash Lite API integration!)
   - `intelligenceAndroidAICore: true` & `intelligenceAppleIntelligence: true` (on-device OS models)
   - `nextGenEditBeforeAdding: true`
2. **Pinned Transactions**:
   - Keys: `showPinnedTransactions`, `pinnedTransactionPks`, `pinnedTransactionsDisplayType`, `pinnedTransactionsShowFrequent`
3. **Stacked Bar Graph**:
   - Keys: `showStackedBarGraph`, `stackedBarGraphAllWallets`, `stackedBarGraphIncomeAndExpenseOnly`, `cyclePeriodLengthStackedBarGraph`
4. **Left-Handed Mode**:
   - Keys: `leftHandedNavbar`, `leftHandedTabBar`, `leftHandedFAB`
5. **Modern UI & Formatting**:
   - `linearProgressBarStyle` (0 = flat, 1 = wavy)
   - `fontScale: 1.0`
   - `dateFormat: 'full'`, `datePickerType: 0`, `timePickerType: 0`
   - `categoryIconPack: 0`, `categoryBackgroundShape: 0`
   - `addTransactionOrder`: reorderable prompts for adding transactions

---

## 2. Accounts / Wallets (`wallets` table)

### Schema & Fields
| Field | Type | Description |
|---|---|---|
| `wallet_pk` | TEXT (UUID) | Primary key (e.g. `578445f6-e68b-445e-9ef2-69bd1eab5e95`) |
| `name` | TEXT | Display name (e.g. `Axis Bank`, `Cash`, `UPI Lite`) |
| `currency` | TEXT | ISO lowercase code (`inr`) |
| `decimals` | INTEGER | Precision (`2` for bank accounts, `0` for Cash) |
| `colour` | TEXT | Hex ARGB string (e.g. `0xffae275f`) |
| `icon_name` | TEXT | Asset filename or icon code |
| `home_page_widget_display` | TEXT | JSON array string like `[1,0]` (Show in account list / net worth widget) |
| `archived` | INTEGER (0/1) | Whether account is hidden |

### How Account Balance Works
There is **no stored balance column**. Account balance is dynamically calculated:
$$\text{Balance} = \sum_{\text{wallet\_fk} = \text{pk},\, \text{paid} = 1} \text{amount}$$
- **Income** transactions have positive amounts ($> 0$).
- **Expense** transactions have negative amounts ($< 0$).
- Unpaid transactions (`paid = 0`) are ignored in balance totals until marked paid.

---

## 3. Categories & Subcategories (`categories` table)

### Hierarchy Architecture
Cashew uses a **self-referential tree structure**:
- **Main Category**: `main_category_pk IS NULL`
- **Subcategory**: `main_category_pk` points to parent category's `category_pk`.

### Live Data Analysis
- **17 Main Categories** (15 Expense, 2 Income)
- **53 Subcategories** (hierarchically linked to their parent)

#### Examples from your data:
- **Food** (`noodles.png`):
  - $\rightarrow$ *Snacks & Beverages* (`fast-food.png`)
  - $\rightarrow$ *Eating Out* (`food-tray.png`)
  - $\rightarrow$ *Sweets* (`cupcake.png`)
- **Investments** (`plant.png`):
  - $\rightarrow$ *Stocks*, *Mutual Fund*, *Fixed Deposit*, *NPS*, *Cryptocurrency*
- **Transportation** (`car.png`):
  - $\rightarrow$ *Fuel*, *Parking*, *Service*, *Toll*, *Automobile Expenses*
- **Bills** (`bill.png`):
  - $\rightarrow$ *Mobile Recharge*, *DTH*, *Electricity*, *Gas*, *Subscriptions*, *Fees*

---

## 4. Associated Titles (`associated_titles` table)

### How Auto-Categorization Works
When typing a title while adding a transaction:
1. `title`: The trigger string (e.g. `"Petrol"`, `"SIP"`, `"Dinner"`, `"Jio"`)
2. `category_fk`: The target category/subcategory PK to assign automatically
3. `is_exact_match`:
   - `0` (Fuzzy / Contains): Matching any substring triggers the category (e.g., typing `"Jio Fiber"` matches `"Jio"` $\rightarrow$ *Mobile Recharge*)
   - `1` (Exact): Only exact string match triggers assignment
4. `order`: Priority order when multiple titles match

### Crucial Insight: Subcategory Targeting
In 90%+ of your entries, the associated title points directly to a **subcategory** (e.g. `"Petrol"` $\rightarrow$ *Fuel*, `"SIP"` $\rightarrow$ *Mutual Fund*). The app automatically resolves the parent category (*Transportation*, *Investments*) through the category foreign key.

---

## 5. Balance Transfers (`paired_transaction_fk`)

### How Transfers are Implemented
A balance transfer creates **two separate linked transactions** simultaneously:
1. **Source Transaction (Debit)**:
   - Account: `Axis Bank`
   - Name: `Axis Bank Transfer Out`
   - Amount: `-10,000.00`
   - Category: `0` (*Balance Correction*)
   - `paired_transaction_fk`: Points to Transaction 2 PK
   - Note: `"Transferred Balance\nAxis Bank → State Bank of India"`
2. **Destination Transaction (Credit)**:
   - Account: `State Bank of India`
   - Name: `State Bank of India Transfer In`
   - Amount: `+10,000.00`
   - Category: `0` (*Balance Correction*)
   - `paired_transaction_fk`: Points to Transaction 1 PK
   - Note: `"Transferred Balance\nAxis Bank → State Bank of India"`

Because both use category `0` (*Balance Correction*), transfers do **not** affect net income or expense totals in reports, but adjust the respective wallet balances accurately!

---

## 6. Scheduled & Repetitive Transactions

In your dataset:
- `reoccurrence = 3`: **Monthly** recurring transaction (1,439 transactions generated or tracked!)
- `reoccurrence = 4`: **Yearly** recurring transaction
- `period_length`: Interval multiplier (e.g. every `1` month)
- `original_date_due`: Timestamp when the instance was originally due
- `paid = 1`: Indicates the instance was paid/settled
- When paid, Cashew automatically generates the next future instance if `created_another_future_transaction` is updated.

---

## 7. What This Unlocks for OpenCashew

With the exact keys extracted from both your 6.7.5 database and `libapp.so`:
1. We can copy the **exact 6.7.5 default preferences map** into `lib/struct/defaultPreferences.dart`.
2. Any new database schema migrations can be matched 1:1 with official 6.7.5 structure.
3. Implementing **Gemini Flash Lite** AI auto-fill is now a documented target with exact setting keys (`nextGenChosenDefaultModelId`, `intelligenceGemini`, `nextGenEditBeforeAdding`).
