# OpenCashew

<p align="center">
  <b>A modern, mobile-first personal finance and budget tracker</b><br>
  <i>Open-source fork of Cashew, built with Flutter and SQLite</i>
</p>

<p align="center">
  <b>Package ID:</b> <code>org.opencashew.app</code> &nbsp;|&nbsp; <b>Platforms:</b> Android (API 37) &bull; iOS (13.0+) &nbsp;|&nbsp; <b>License:</b> GPL-3.0
</p>

---

## About OpenCashew

**OpenCashew** is an independent, mobile-only fork of [Cashew](https://github.com/jameskokoska/Cashew), optimized for modern mobile devices.

### Fork Attribution & Legal Notice
- **Upstream Project**: Cashew by James Kokoska ([upstream repository](https://github.com/jameskokoska/Cashew)).
- **Original Copyright**: (C) 2021-2024 James Kokoska.
- **Fork Modernization & Maintenance**: (C) 2026 drshtmstry and contributors.
- **License**: [GNU General Public License v3.0 (GPLv3)](LICENSE). See [NOTICE](NOTICE) for complete attribution and modification history.

### Key Fork Modernizations
- **Mobile-First Focus**: Completely removed obsolete desktop (Windows, macOS, Linux) and web deployment assets for a lightweight, mobile-tailored codebase.
- **Modern Toolchain**: Upgraded Android build targets to **compileSdk 37**, **targetSdk 37**, **AGP 9.1.1**, **Gradle 9.3.1**, and Java 17 toolchain.
- **Decoupled Architecture**: Cleaned out hardcoded upstream web endpoints, Firebase hosting, and obsolete dependencies.

---

## Features

### 💸 Budget & Goal Management
- **Flexible Budgeting**: Daily, weekly, monthly, and custom event/travel budgets with category spending caps.
- **Goals & Savings**: Track spending and savings milestones with automated progress calculations.
- **Budget History**: Visual historical analysis of spending trends across periods.

### 💰 Transaction Management
- **Transaction Types**: Standard expenses and income, subscriptions, recurring transactions, loans, and debt tracking.
- **Smart Categorization**: Custom categories with extensive icon libraries, emoji pickers, and auto-matching rules.
- **Advanced Filtering**: Search by amount, custom tags, date ranges, and categories.

### 💱 Multi-Currency & Accounts
- Manage multiple accounts and wallets with automatic currency conversions.
- Switch active accounts and currencies dynamically across all dashboards.

### 🎨 Material Design & Usability
- **Material You (M3)** adaptive dynamic theming with custom accent color support.
- Native dark mode and light mode.
- Interactive spending charts and customizable dashboards.
- Biometric authentication (Fingerprint / Face ID) for privacy.

### 💿 Offline-First & Data Ownership
- **Local SQLite Database**: 100% offline-first storage via Drift SQLite; your financial data never leaves your device unless you choose to sync.
- **Export & Import**: Full CSV and SQLite database export/import functionality.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.35.0)
- Android SDK (API 37) / Xcode for iOS development

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/drshtmstry/Cashew.git
   cd Cashew/budget
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on a mobile device or emulator**:
   ```bash
   flutter run
   ```

### Building Release Packages

- **Android App Bundle (AAB)**:
  ```bash
  flutter build appbundle --release
  ```

- **Android APK**:
  ```bash
  flutter build apk --release
  ```

- **iOS IPA**:
  ```bash
  flutter build ipa --release
  ```

---

## Database Migrations

When modifying the local Drift database schema:
1. Make necessary changes in `lib/database/tables.dart`.
2. Increment `schemaVersionGlobal` in `lib/database/tables.dart`.
3. Generate Drift code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Dump schema JSON:
   ```bash
   dart run drift_dev schema dump lib/database/tables.dart drift_schemas/drift_schema_v[schemaVersion].json
   ```
5. Generate step migrations:
   ```bash
   dart run drift_dev schema steps drift_schemas/ lib/database/schema_versions.dart
   ```

---

## License

This project is licensed under the [GNU General Public License v3.0 (GPLv3)](LICENSE).
See [NOTICE](NOTICE) for full upstream author and contributor credits.
