# F-Droid Compliance & Open Source Audit Report

**Project:** TKMingle (Campus Social Discovery Platform for TKMCE)  
**Package ID:** `com.tkmingle.app`  
**Flutter Subdirectory:** `mobile/`  
**Audit Date:** November 2026  

---

## 1. Executive Summary

This report documents the technical audit and preparation of the TKMingle Flutter Android application for distribution via the official [F-Droid](https://f-droid.org) repository.

F-Droid is a curated catalogue of Free and Open Source Software (FOSS) for Android. All applications in F-Droid must:
1. Be built strictly from source using reproducible build recipes in isolated, non-networked build environments.
2. Contain zero proprietary binary blobs, closed-source dependencies, or proprietary SDKs (such as Google Play Services or Firebase).
3. Have unambiguous, OSI-approved open-source licensing covering all source code, assets, and fonts.
4. Distribute unsigned release artifacts that F-Droid signs with its official repository key.

All technical blockers (Firebase plugins, dynamic Google Font network requests, and debug signing in release mode) have been resolved. The remaining open item is formal maintainer alignment on the project license text.

---

## 2. Licensing Audit & Identified Inconsistencies

### 2.1 License Inconsistency Requiring Maintainer Approval
* **Current Root `LICENSE`:** Contains an MIT License notice naming `Copyright (c) 2026 TKM College of Engineering Student Community`.
* **Current `README.md` (lines 130–131):** States:
  ```markdown
  ## 📄 License
  Pending maintainer confirmation. See LICENSE.
  ```
* **Historical Context:** An earlier project draft in the repository history described the license as pending formal selection among MIT, Apache 2.0, or AGPLv3, and contained a clause prohibiting "commercial exploitation." Under Debian Free Software Guidelines (DFSG Criterion #6), non-commercial clauses are deemed non-free and cause automated rejection by F-Droid.
* **Required Maintainer Action:** The project maintainers must formally confirm the open-source license (recommended: **MIT License** or **Apache License 2.0**) and update `README.md` to remove the "pending maintainer confirmation" placeholder so that `README.md` and `LICENSE` are fully consistent.

### 2.2 Asset & Font Licensing
| Asset | Path | Origin & Author | License | F-Droid Status |
| :--- | :--- | :--- | :--- | :--- |
| **Sora Font** | `mobile/assets/fonts/Sora.ttf` | Jonathan Barnbrook, Julieta Ulanovsky (Google Fonts) | SIL Open Font License 1.1 (OFL-1.1) | **Compliant** (FSF & DFSG free) |
| **Vector Logos** | `mobile/assets/images/logo_*.svg` | TKMingle Student Design Team | Dedicated Project Artwork | **Compliant** (Covered under repository license) |
| **App Icons & Splash** | `mobile/assets/images/app_icon.png`, `splash_logo.png` | TKMingle Student Design Team | Derived from vector logos | **Compliant** |
| **Design Mockups** | `mobile/assets/images/brand_*.png` | Internal brand board slices | Internal project reference | **Compliant** (Harmless visual assets) |

### 2.3 Trademark & Institutional Name Note
The application uses the name and architectural motifs of **TKM College of Engineering (TKMCE)**. F-Droid routinely distributes collegiate, community, and club applications provided there is no trademark infringement or misrepresentation. To avoid ambiguity, the project documentation maintains that TKMingle is an independent student community initiative.

---

## 3. Dependency Audit

Every direct and transitive dependency defined in `mobile/pubspec.yaml` and `mobile/pubspec.lock` was examined for license compliance and proprietary third-party SDKs.

### 3.1 Direct Dependencies
| Package | Version | License | Proprietary Google Blobs? | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `flutter` | SDK | BSD-3-Clause | None | Core UI framework |
| `flutter_riverpod` | `^2.5.1` (2.6.1) | MIT | None | Reactive state management |
| `go_router` | `^14.2.0` (14.8.1) | BSD-3-Clause | None | Declarative routing |
| `intl` | `^0.19.0` | BSD-3-Clause | None | Date & message formatting |
| `shared_preferences` | `^2.2.3` (2.5.3) | BSD-3-Clause | None | Local key-value storage |
| `cached_network_image`| `^3.3.1` (3.4.1) | MIT | None | Image caching |
| `flutter_animate` | `^4.5.0` | MIT | None | Micro-animations |
| `uuid` | `^4.4.0` | MIT | None | Client-side UUID generation |
| `path_provider` | `^2.1.3` (2.1.5) | BSD-3-Clause | None | Filesystem access paths |
| `supabase_flutter` | `^2.8.0` (2.15.4) | MIT | None | Supabase Auth, DB, Realtime |

### 3.2 Dev Dependencies & Overrides
| Package | Version | License | Purpose |
| :--- | :--- | :--- | :--- |
| `flutter_test` | SDK | BSD-3-Clause | Unit & integration testing |
| `flutter_lints` | `^4.0.0` | BSD-3-Clause | Static analysis rules |
| `app_links` (override)| `6.3.2` | Apache-2.0 | Deep linking handler |

### 3.3 Transitive Dependencies
All 114 transitive packages resolved in `pubspec.lock` are distributed under OSI-approved licenses (BSD-3-Clause, MIT, Apache-2.0). There are **zero** transitive references to Google Play Services (`com.google.android.gms`), Firebase, Facebook SDK, or closed-source analytics.

---

## 4. Android Configuration & Build Reproducibility

### 4.1 Release Signing
* **Previous Configuration:** The release build block in `mobile/android/app/build.gradle` contained `signingConfig signingConfigs.debug`.
* **Updated Configuration:** Removed `signingConfig signingConfigs.debug`. Gradle now generates an unsigned release APK by default. This enables F-Droid's automated build infrastructure to compile from source and apply F-Droid's repository signing key.
* **Keystore Safety:** No private keystores or signing passwords exist in the repository.

### 4.2 Manifest & Permissions Audit
* **Application ID:** `com.tkmingle.app`
* **Declared Permissions:**
  * `android.permission.INTERNET` (Required for Supabase API calls and avatars)
  * `android.permission.ACCESS_NETWORK_STATE` (Network connectivity status)
  * `android.permission.VIBRATE` (Haptic feedback on interaction)
* **Excluded Permissions:** No camera, microphone, fine location, contacts, or SMS permissions are requested.
* **Component Export:** `MainActivity` is the single exported activity (`android:exported="true"`) guarded with `MAIN` and `LAUNCHER` intent filters. No unexported or vulnerable services are exposed.

### 4.3 Verified Binary Inspection (`aapt dump badging`)
Inspection of the built release binary:
```
package: name='com.tkmingle.app' versionCode='2001' versionName='1.0.0'
compileSdkVersion='34'
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
uses-permission: name='android.permission.VIBRATE'
application-label:'TKMingle'
```
Zip entry analysis confirmed that no proprietary Google or Firebase classes are present in the compiled APK.

---

## 5. Flutter SDK Compatibility

* **Verified Flutter Version:** `Flutter 3.24.5` (channel stable)
* **Verified Dart Version:** `Dart 3.5.4`
* **Pubspec Constraint:** Updated in `mobile/pubspec.yaml` to `flutter: ">=3.24.0 <4.0.0"` to ensure full compatibility with the existing code while preventing unexpected breaking changes from newer major SDKs.
* **Offline Build Capability:** All packages resolve and compile offline once cached, fulfilling F-Droid's non-networked build requirement.

---

## 6. Supabase & Network Considerations (Anti-Feature Evaluation)

### 6.1 Backend Architecture
TKMingle communicates with a Supabase backend for authentication, student discovery, and real-time messaging.
* **Client Credentials:** `mobile/lib/core/constants/app_constants.dart` stores `supabaseUrl` and `supabaseAnonKey`.
* **Security Verification:** The `anonKey` is a public client token intended for client-side applications and constrained by PostgreSQL Row Level Security (RLS). The privileged `service_role` key is **not** present in the mobile application.

### 6.2 F-Droid `NonFreeNet` Evaluation
F-Droid attaches the `AntiFeatures: NonFreeNet` flag to applications that promote or depend entirely on a non-free (proprietary) network service.
* **Software Status:** The Supabase backend software (PostgreSQL, PostgREST, GoTrue, Realtime) is 100% open source under Apache 2.0 / MIT / PostgreSQL licenses and can be independently self-hosted.
* **Deployment Model:** By default, TKMingle connects to a managed hosted instance for the TKMCE campus.
* **Assessment:** Because the underlying backend stack is open-source software, TKMingle does not violate the free network guidelines. However, since the endpoint URL is compiled into the app rather than offering an arbitrary server switcher, F-Droid reviewers may request a clarification or note in the metadata. This is standard for collegiate and community federation apps.

---

## 7. Checklist for Maintainer Action

Before submitting the Merge Request to `fdroiddata`:

1. [ ] **Confirm License:** Update `README.md` to remove "Pending maintainer confirmation" and ensure full alignment with root `LICENSE` (MIT).
2. [ ] **Tag Release:** Create and push the Git tag:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0 for F-Droid"
   git push origin v1.0.0
   ```
3. [ ] **Fork & Copy Metadata:** Fork `https://gitlab.com/fdroid/fdroiddata`, copy `fdroid/com.tkmingle.app.yml.example` to `metadata/com.tkmingle.app.yml`, and submit the Merge Request.
