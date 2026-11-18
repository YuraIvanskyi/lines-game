# Gold Candidate Plan — ENDS 1.0

Started 2026-11-17. This is the checklist for the first App Store and Google Play submission. Store rules change, so check each limit against the console when filling it in.

Legend: **[owner]** needs you · **[code]** a repo change · **[console]** filled in on the store website · ✅ done.

## 0. Decisions (all settled)

| # | Decision | Outcome |
| --- | --- | --- |
| D1 | Product name | ✅ **ENDS**, one name everywhere (decisions L10). |
| D2 | Bundle / application ID | ✅ `com.ivanskyi.ends` on both platforms. Permanent after the first upload. |
| D3 | Grid size | ✅ 6×6 for classic. Other sizes are future modes (decisions L3). |
| D4 | Devices | ✅ iPhone only (`TARGETED_DEVICE_FAMILY = 1`). |
| D5 | Home buttons | ✅ ♥ opens the App Store on iOS and Google Play elsewhere. Exit is hidden on iOS, and the three icons spread to the same edges. |
| D6 | Build pipeline | ✅ Codemagic for all builds (decisions L8). GitHub Actions runs tests only. |
| D7 | 1.0 scope | ✅ Classic + bot as is. Resume, results and skins come after 1.0. |

## 1. Owner to-do (in order)

1. ✅ **Support email** ends.support@gmail.com, on the live pages and in `store/listing.md`.
2. ✅ **Site published.** `privacy.html`, `terms.html` and `support.html` are live under `https://yuraivanskyi.github.io/ends-site/` (checked 2026-11-18).
3. **[console] Apple Developer Program** ($99/yr):
   - register `com.ivanskyi.ends`;
   - create the app record (name ENDS);
   - create an App Store Connect API key (App Manager role).
4. **[console] Play Console.** ✅ Account created. Next, create the app (ENDS, Game, Free); new personal accounts also verify a real Android device in the Play Console mobile app.
   - ✅ Upload keystore generated 2026-11-18: `%USERPROFILE%\keys\ends-upload.jks`, alias `upload`. The password is in `ends-upload-credentials.txt` in the same folder, and the gitignored `app/android/key.properties` points at it for local release builds. Upload cert SHA-256 `8E:8E:9F:AA:…:E4:82:A8:E6`.
   - [ ] **[owner] Back up the `keys` folder off-machine** (password manager or cloud drive).
   - [ ] **[console]** Service account for Codemagic: in Google Cloud, enable the Google Play Android Developer API, create a service account and a JSON key, then invite its email in Play Console → Users and permissions with release rights for ENDS.
5. **[owner] Codemagic setup.** The names must match `codemagic.yaml`:
   - the API key as team integration `ENDS ASC key`;
   - the keystore as `ends_upload_key`;
   - an env group `google_play` holding `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (a Play service account with release rights).
6. **[code] Fill in the Apple ID.** Once the app record exists, copy its numeric Apple ID into `StoreLinks.appStoreId` (`app/lib/store_links.dart`). Until then, the ♥ button on iOS opens a dead link.
7. **Android first upload.** Run `android-release`. Play's API cannot create the first release, so upload that first `.aab` by hand. Then start the **closed test: at least 12 testers for 14 continuous days**. This is the long pole for a new personal account.
8. **iOS.** Run `ios-release` → TestFlight → install on the iPhone 16 Pro.
9. **Real-device passes.** Play a full game on each platform, including back gesture, safe area, haptics and sound (LG-017 on Android).
10. **Fill in the listings** from [../store/listing.md](../store/listing.md) and the screenshots, then submit iOS. Promote Android after the 14-day test.

## 2. Done in the repo

Shared

- ✅ Version `1.0.0+1`. Codemagic overrides the build number with its counter.
- ✅ Listing copy in en and uk, plus the console answers: [../store/listing.md](../store/listing.md).
- ✅ Legal and support pages in en and uk, in the sibling repo `ends-site` (the only copy). The links in `app/lib/legal_links.dart` point at the GitHub Pages URLs.
- ✅ Screenshots in [../store/screenshots/](../store/screenshots/). Regenerate them with `tools/web-verify` → `store-shots` (instructions at the top of the scenario).
  - `ios-6.9-en`, `ios-6.9-uk`: 1320×2868, captured as iOS, so no Exit button.
  - `play-phone-en`, `play-phone-uk`: 1080×2160.
- ✅ Play icon `store/play-icon-512.png` and feature graphic `store/play-feature-graphic.png`. Generators are in `tools/store-art/`.

iOS

- ✅ Bundle ID, iPhone only, `ITSAppUsesNonExemptEncryption = false`, opaque 1024 icon.
- ✅ The `ios-release` workflow: automatic signing from the API key, IPA, TestFlight.
- [ ] **[check]** Privacy manifest. The plugins ship their own. Add an app-level one only if the upload email warns about required-reason APIs.
- [ ] **[optional]** Launch screen. It is a 1×1 placeholder: acceptable, but a flat brand color looks better.

Android

- ✅ `applicationId` / namespace and the Kotlin package.
- ✅ Adaptive and legacy launcher icons.
- ✅ The https VIEW query for links.
- ✅ Release signing from `key.properties`.
- ✅ The `android-release` workflow: signed AAB to the internal track, as a draft.
- ✅ Local Android build (2026-11-18): this PC now has the SDK and a `Pixel_9_API_36` emulator. Release APK and AAB build with target API 36 and play correctly on Android 16, gesture bar included.
- ✅ Fixed a release-only startup hang: `shared_preferences_android` 2.5.1 lost its JNI methods to R8 (`NoSuchMethodError`, stuck on splash). The lockfile now pins 2.5.4; the fix landed in 2.5.2.

## 3. Store answers (quick reference)

App Privacy / Data safety: **no data collected or shared**. No ads, no login, no in-app purchases. Category Games → Board. Target audience 13+. Age rating: lowest tier. More detail in [../store/listing.md](../store/listing.md).

## 4. Open tickets vs 1.0

| Ticket | Blocks 1.0? | Note |
| --- | --- | --- |
| LG-017 Android classic loop | **Play only** | Covered by the first CI build plus the device pass (owner steps 7 and 9). |
| LG-018 Resume a match | No | After 1.0. |
| LG-019 Local names and results | No | Name prefill works. The results list comes after 1.0. |
| LG-020 Second skin | No | After 1.0. |
| LG-021 Online note | No | Docs only. |
