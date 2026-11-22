# F-Droid Technical Audit & Compliance Status Report

**Application Name:** TKMingle  
**Package ID:** `com.tkmingle.app`  
**Flutter Subdirectory:** `mobile/`  
**Review Commit:** `220a4dc7ebb27183fc672c745ecd3ef32d90fdcb`  
**Last Updated:** November 2026  

---

## 1. Executive Summary

This document presents the detailed compliance status of the TKMingle Flutter Android application for potential inclusion in the [F-Droid](https://f-droid.org) software repository. 

To maintain transparency and rigor, this audit categorizes all findings into three strict tiers:
1. **Verified and Tested:** Backed by actual local command execution, automated testing, and binary inspection.
2. **Inspected but Not Independently Tested:** Verified by manual source code inspection and official F-Droid specification review, but not executed within an air-gapped F-Droid Debian build bot.
3. **Unresolved and Requiring Maintainer Approval:** Legal, administrative, and versioning decisions that only the repository owner can confirm.

---

## 2. Category 1: Verified and Tested

The following items have been directly verified through command-line execution and tool-based inspection in the workspace:

### 2.1 Full Compilation & Test Suite
* **Flutter SDK Version:** `Flutter 3.24.5` (channel stable, revision `dec2ee5c1f`) on `Dart 3.5.4`.
* **Static Analysis:** Executed `flutter analyze` in `mobile/`. Result: **0 issues found** (passed cleanly in 5.0s).
* **Unit & Core Tests:** Executed `flutter test` in `mobile/`. Result: **All 7/7 core tests passed**:
  - Auth Repository initialization and current user handling
  - Student discovery filtering (self-exclusion and suspension filtering)
  - Cross-department discovery filtering
  - Mutual-consent connection request workflow
  - Campus circle joining and post creation
  - Messaging creation and timestamping
  - Multi-user isolation and logout session clearing
* **Release Build:** Executed `flutter build apk --release` in `mobile/`. Result: Built universal release APK at `mobile/build/app/outputs/flutter-apk/app-release.apk` (54.7 MB) in 22.0s.

### 2.2 Version Code & Name Consistency
* **Investigation of Previous `versionCode='2001'` Discrepancy:**
  - When building with `--split-per-abi`, Flutter Gradle plugin automatically offsets the base version code by ABI (arm64-v8a receives +2000, resulting in `2001`).
  - Universal release builds (`flutter build apk --release`) do not apply ABI offsets.
* **Inspection of Generated Universal APK:**
  - Evaluated using Android SDK `aapt dump badging`:
    ```
    package: name='com.tkmingle.app' versionCode='1' versionName='1.0.0'
    platformBuildVersionName='14' platformBuildVersionCode='34' compileSdkVersion='34'
    application-label:'TKMingle'
    native-code: 'arm64-v8a' 'armeabi-v7a' 'x86' 'x86_64'
    ```
  - **Result:** Consistently reports Package ID `com.tkmingle.app`, Version Name `1.0.0`, and Version Code `1`.

### 2.3 Unsigned Release Binary (No Debug Keystore)
* **Configuration:** `signingConfig signingConfigs.debug` was removed from `mobile/android/app/build.gradle`.
* **Verification via `apksigner`:**
  - Executed `apksigner verify --verbose mobile/build/app/outputs/flutter-apk/app-release.apk`.
  - Output: `DOES NOT VERIFY: Missing META-INF/MANIFEST.MF`.
  - **Result:** Confirms the APK is completely unsigned, preventing accidental debug-key leakage and allowing F-Droid's build bot to apply its official release signature.

### 2.4 Permissions and Component Exposure
* **Declared Permissions:**
  - `android.permission.INTERNET`
  - `android.permission.ACCESS_NETWORK_STATE`
  - `android.permission.VIBRATE`
  - `com.tkmingle.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (standard Android 14 broadcast guard)
* **Components:** Only `MainActivity` is exported (`android:exported="true"`) to act as the launcher. No background services, broadcast receivers, or content providers are improperly exported.

### 2.5 Exclusion of Proprietary Google / Firebase SDKs
* Removed `firebase_core`, `com.google.gms.google-services`, `firebase_options.dart`, and `google-services.json`.
* Zip-level binary scan of `mobile/build/app/outputs/flutter-apk/app-release.apk` confirmed **zero** references to `com.google.android.gms` or Firebase classes.

### 2.6 Sora Font Source & Licensing
* Verified source: Google Fonts upstream repository (`google/fonts/ofl/sora`).
* Bundled official license: Downloaded `OFL.txt` directly to `mobile/assets/fonts/OFL.txt`.
* Attribution:
  - **Copyright:** 2019 The Sora Project Authors (`https://github.com/sora-xor/sora-font`).
  - **License:** SIL Open Font License, Version 1.1 (FSF and Debian Free Software Guidelines approved).
  - Meets OFL Clause 2 requiring the copyright notice and license text to accompany the font software.

### 2.7 Supabase Client Configuration & Secrets Audit
* Inspected `mobile/lib/core/constants/app_constants.dart`.
* Verified that only public client parameters (`supabaseUrl` and public client key `supabaseAnonKey`) are referenced via `String.fromEnvironment`.
* **Zero service-role keys**, database passwords, or administrative tokens exist in the mobile codebase.
* Authorization and student data boundaries are enforced strictly via PostgreSQL Row Level Security (RLS).

---

## 3. Category 2: Inspected but Not Independently Tested

The following items have been audited against official documentation and code structures, but have not been executed in an isolated F-Droid environment:

### 3.1 F-Droid Metadata Build Recipe
* Inspected `fdroid/com.tkmingle.app.yml.example`.
* Corrected recipe to match F-Droid's standard Flutter specification:
  - Uses `srclibs: [flutter@3.24.5]` to declare the Flutter SDK dependency.
  - Uses `build:` script calling `flutter config --no-analytics`, `flutter pub get`, and `flutter build apk --release`.
  - Sets `output: build/app/outputs/flutter-apk/app-release.apk`.
  - Removed outdated and incompatible combination of `flutter: yes` with `gradle: assembleRelease`.
  - YAML syntax validated via `yaml.safe_load`.
* *Limitation:* Has not been built inside an official `fdroidserver` Debian Docker container.

### 3.2 Transitive Dependency Air-Gapped Resolution
* All 114 transitive dependencies declared in `mobile/pubspec.lock` use permissive open-source licenses (BSD-3-Clause, MIT, Apache-2.0).
* *Limitation:* While dependencies cache locally, full air-gapped builds without network access have not been tested outside the developer machine's local cache.

### 3.3 Hosted Supabase Anti-Feature (`NonFreeNet`) Potential
* The backend software running TKMingle (PostgreSQL, PostgREST, GoTrue, Realtime) is open source.
* However, the client application connects by default to a specific hosted URL without an in-app custom server switcher.
* *Limitation:* F-Droid maintainers decide on a case-by-case basis whether apps with hardcoded hosted cloud instances require the `AntiFeatures: NonFreeNet` tag. This can only be determined during upstream maintainer review.

---

## 4. Category 3: Unresolved and Requiring Maintainer Approval

The following items cannot be resolved autonomously and require explicit project owner decision:

### 4.1 License Contradiction (`README.md` vs `LICENSE`)
* **Problem:**
  - Root `LICENSE` contains MIT License text.
  - `README.md` states: `Pending maintainer confirmation. See LICENSE.`
* **Status:** Unresolved. The repository cannot be claimed as officially MIT-licensed until maintainers formally approve the license and align `README.md`.
* **F-Droid Metadata Impact:** `fdroid/com.tkmingle.app.yml.example` explicitly sets `License: Unverified` with a comment that maintainer confirmation is required.

### 4.2 Git Release Tagging & Remote Collision
* **Problem:**
  - An existing tag `v1.0.0` is already present on GitHub pointing to an earlier commit (`3c86bf3`) that lacks F-Droid compliance and recent fixes.
* **Decision Required:**
  - **Option A:** Force-update `v1.0.0` to the latest commit if `v1.0.0` was not distributed externally.
  - **Option B:** Increment to `v1.0.1` in `mobile/pubspec.yaml`, commit, and create tag `v1.0.1`.

### 4.3 Artwork & Campus Trademark Confirmation
* Community logos and graphics in `mobile/assets/images/` were designed for TKMingle. Maintainers must confirm that these visual assets are licensed under the project's chosen open-source license.
* TKM College of Engineering (TKMCE) name usage should be accompanied by a clear notice that TKMingle is an independent student project, not an official university administration release.

---

## 5. Summary Checklist of Next Actions for Maintainer

1. [ ] **Resolve Licensing:** Formally agree on the open-source license and update `README.md` to remove the "pending maintainer confirmation" notice.
2. [ ] **Push Master Branch:** `git push origin master`
3. [ ] **Tag the Release:**
   - Either force-update: `git tag -fa v1.0.0 -m "Release v1.0.0"` and `git push origin v1.0.0 --force`
   - Or bump to `v1.0.1`: Update `pubspec.yaml`, tag `v1.0.1`, and push.
4. [ ] **Submit to F-Droid:** Copy `fdroid/com.tkmingle.app.yml.example` to `fdroiddata/metadata/com.tkmingle.app.yml`, fill in the confirmed commit tag and license, and open a Merge Request on GitLab.
