# Walkthrough: Fork Restructure, Rebranding to OpenCashew & Mobile-Only Scoping

## Overview
The repository has been restructured from the upstream Cashew project into **OpenCashew** (`org.opencashew.app`), an independent, mobile-only application targeting the latest Android and iOS versions under the GNU General Public License v3.0 (GPLv3).

---

## Changes Implemented

### 1. Web and Desktop Code Removal
- **Directories Removed**:
  - `budget/web/` (including wasm SQLite files, web manifests, and icons)
  - `budget/windows/` (including CMakeLists, Win32 runner, and Windows plugins)
  - `scripts/deploy_and_build_windows.bat`
  - `.github/workflows/firebase-hosting-pull-request.yml`
  - `budget/firebase.json` and `budget/.firebaserc`
- **Flutter Configuration**:
  - Web and desktop platforms disabled in Flutter tooling (`flutter config --no-enable-web --no-enable-windows-desktop --no-enable-linux-desktop --no-enable-macos-desktop`).
  - Removed web and unsupported platform database logic (`lib/database/platform/web.dart` and `unsupported.dart`).
  - Removed browser `universal_html` and `universal_io` dependencies in favor of standard Dart IO.

### 2. Legal & GPLv3 Compliance
- Retained upstream license file [LICENSE](file:///c:/Users/drshtmstry/Documents/GitHub/Cashew/LICENSE).
- Created [NOTICE](file:///c:/Users/drshtmstry/Documents/GitHub/Cashew/NOTICE) documenting:
  - Original author attribution: Copyright (C) 2021-2024 James Kokoska.
  - Derivative work attribution: Copyright (C) 2026 drshtmstry and contributors.
  - Full summary of architectural changes made in this fork.
- Rewrote [README.md](file:///c:/Users/drshtmstry/Documents/GitHub/Cashew/README.md) with updated project identity (`OpenCashew`) and links to upstream Cashew.

### 3. Rebranding to OpenCashew (`org.opencashew.app`)
- **App Name & Strings**:
  - `globalAppName = "OpenCashew"` in `budget/lib/struct/languageMap.dart`.
  - App title and root key updated in `budget/lib/main.dart`.
  - Export filenames and folders updated to `"OpenCashew"` / `"opencashew-"` across `exportCSV.dart`, `exportDB.dart`, `importCSV.dart`, `accountAndBackup.dart`, and `uploadAttachment.dart`.
  - Pro purchase ID set to `"opencashew.pro.lifetime"`.
- **Android Platform**:
  - Namespace & Application ID set to `org.opencashew.app` in `budget/android/app/build.gradle`.
  - Application label set to `"OpenCashew"` in `AndroidManifest.xml`.
  - Package migrated to `org.opencashew.app` with Kotlin sources reorganized under `budget/android/app/src/main/kotlin/org/opencashew/app/`.
- **iOS Platform**:
  - Product bundle identifier set to `org.opencashew.app` in `budget/ios/Runner.xcodeproj/project.pbxproj`.
  - `CFBundleDisplayName` and `CFBundleName` set to `"OpenCashew"` in `budget/ios/Runner/Info.plist`.

### 4. Modern Android & iOS Toolchain
- Android `compileSdkVersion` set to **37** and `targetSdkVersion` set to **36** (with plugin overrides to 36).
- Upgraded to **AGP 9.1.1**, **Gradle 9.3.1**, and Java 17 toolchain.
- Minimum iOS deployment target configured to iOS 13.0+.

### 5. Dependency & SDK Modernization
- Dart SDK environment modernized to `sdk: ">= 3.3.0 <4.0.0"`.
- Upgraded core database and system dependencies:
  - `drift: ^2.24.0` (resolved to `2.35.4`)
  - `drift_dev: ^2.24.0` (resolved to `2.35.3`)
  - `sqlite3_flutter_libs: ^0.5.24` (resolved to `0.5.42`)
  - `app_settings: ^9.0.1` (specifies `compileSdk = 36`)
  - `flutter_charset_detector: ^6.0.0` (specifies `compileSdk = 35`)
  - `file_picker: ^11.0.3`
  - `shared_preferences: ^2.3.5`
  - `intl: ^0.20.2`
  - `home_widget: ^0.9.4`
  - `carousel_slider: ^5.0.0`
- Re-generated Drift ORM schema code (`dart run build_runner build`).

---

### 6. Repository Flattening & Clean Single Commit
- **Flattened Layout**: The Flutter application was moved directly from the `budget/` subfolder into the repository root:
  - `android/`, `ios/`, `lib/`, `assets/`, `pubspec.yaml`, `drift_schemas/`, and `packages/` are now at `/`.
  - Opening the repository in Android Studio or VS Code immediately detects the Flutter project.
  - Updated `.vscode/launch.json` and build scripts to run directly against root paths.
- **Git History Structure**:
  - **Preserved Upstream History**: All original commits from James Kokoska (up to `9cfbe50c`) are completely retained, preserving original authorship, commit logs, and git blame.
  - **Single Clean Fork Commit on Top**: All OpenCashew modifications (mobile-only scoping, rebranding, repository flattening, dependency and SDK modernizations, Drift schema alignment, and in-app changelog sync) are consolidated into a single clean commit on top of upstream:
    `2b827107 feat: restructure mobile-only fork, rebrand to OpenCashew, and modernize dependencies and SDKs`.
  - Force-pushed to [`origin/main`](https://github.com/drshtmstry/OpenCashew.git).

---

## Build Verification Results

| Artifact / Command | Status | Output File / Details |
| :--- | :--- | :--- |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | **PASSED** | 0 errors |
| `dart run build_runner build` | **PASSED** | 424 outputs generated cleanly |
| `flutter build apk --debug` (from root) | **PASSED** | `build/app/outputs/flutter-apk/app-debug.apk` |
| `flutter build apk --release` (from root) | **PASSED** | `build/app/outputs/flutter-apk/app-release.apk` (92.2 MB) |

---

## Running Directly in Android Studio

To run or debug OpenCashew directly in Android Studio:

1. **Open the Project**:
   - In Android Studio, select **Open** and choose the repository folder directly:
     `c:\Users\drshtmstry\Documents\GitHub\Cashew` (or `OpenCashew` if renamed).
   - Android Studio will immediately recognize the Flutter project from the root `pubspec.yaml`.
2. **Select Device**:
   - Pick your running Android emulator or connected device from the device dropdown.
3. **Run or Debug**:
   - Press the green **Run** button (`Shift + F10`) or **Debug** (`Shift + F9`).
