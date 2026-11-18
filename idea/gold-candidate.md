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
2. **[owner] Publish the site.** The sibling repo `d:\projects\ends-site` is committed locally. Follow its README: create the public GitHub repo `ends-site`, push, and turn on Pages. The app already links to `https://yuraivanskyi.github.io/ends-site/…`.
3. **[console] Apple Developer Program** ($99/yr):
   - register `com.ivanskyi.ends`;
   - create the app record (name ENDS);
   - create an App Store Connect API key (App Manager role).
4. **[console] Play Console** ($25, identity verification). Create the app, then generate the upload keystore and **back it up off-machine**.
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
- [ ] **[check]** On the first CI build, confirm the target API level meets Play's minimum, and that edge-to-edge (Android 15+) clears the gesture bar. Nothing Android has been built yet: this PC has no SDK.

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
