# F-Droid Build & Distribution Guide for TKMingle

This directory contains resources, metadata templates, and instructions for packaging, testing, and distributing the **TKMingle** Flutter Android application on [F-Droid](https://f-droid.org), the premier free and open-source software (FOSS) repository for Android.

---

## 1. Directory Contents

* `README.md` — This guide.
* `com.tkmingle.app.yml.example` — Metadata build template for submission to `fdroiddata`.

---

## 2. F-Droid Submission Prerequisites

Before opening a Merge Request on [fdroiddata](https://gitlab.com/fdroid/fdroiddata):

1. **License Confirmation:**
   Resolve the pending maintainer confirmation between `README.md` and `LICENSE`. F-Droid requires an approved OSI license (e.g. MIT, Apache-2.0, GPL-3.0) without non-commercial use restrictions.
2. **Tag a Release:**
   Create an annotated Git tag on the release commit in the public repository:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0 for F-Droid"
   git push origin v1.0.0
   ```
3. **Verify the Clean Build:**
   Ensure the project builds cleanly from source with no proprietary Google Play Services plugins:
   ```bash
   cd mobile
   flutter pub get
   flutter analyze
   flutter test
   flutter build apk --release --split-per-abi
   ```

---

## 3. Metadata Recipe Instructions

1. Fork the official F-Droid metadata repository on GitLab:
   `https://gitlab.com/fdroid/fdroiddata`
2. Copy `fdroid/com.tkmingle.app.yml.example` to `metadata/com.tkmingle.app.yml` in your fork.
3. Replace the placeholder values marked `[MANUAL_CONFIRMATION_REQUIRED]`:
   * Set `commit:` to the actual Git tag (e.g. `v1.0.0`) or verified commit SHA.
   * Verify the `versionName:` (e.g. `1.0.0`) and `versionCode:` (e.g. `1`).
4. Test the build recipe locally using `fdroid build com.tkmingle.app` (requires `fdroidserver` and the F-Droid build Docker image).
5. Open a Merge Request with the template **New App**.

---

## 4. Upstream Maintenance & Version Updates

When releasing a new version of TKMingle:

1. Update `version:` in `mobile/pubspec.yaml` (e.g., `1.0.1+2`).
2. Update `versionCode` and `versionName` in `mobile/android/app/build.gradle` if overridden.
3. Tag the release in Git (`git tag -a v1.0.1 -m "Release v1.0.1"`).
4. Add a new build block to `metadata/com.tkmingle.app.yml` or let F-Droid's `CheckUpdates` bot discover the new Git tag automatically via `AutoUpdateMode: Version`.

---

## 5. Security & Signing

* **Do not commit signing keystores to Git.**
* In `mobile/android/app/build.gradle`, the `release` build type intentionally omits `signingConfig` so that the F-Droid build server signs the generated APK with F-Droid's official cryptographic key.
