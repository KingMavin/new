# Release Checklist — Immortal Path

Steps to take the repo from source-only to a public, store-ready build.
Checked boxes are already handled in the repo; unchecked boxes need a
machine with the Flutter SDK or store consoles.

## 1. Verify the build (your machine)

- [ ] `flutter pub get`
- [ ] `flutter test` — 29 test files, all green
- [ ] `flutter analyze` — no errors or warnings
- [ ] `dart run tool/balance_sim.dart` — sanity-check report runs
- [ ] `flutter run` on a device — smoke test: intro, origin choice, hunt,
      event dialog, tournament, war, forge, breakthrough ceremony, audio
      changes per screen, save survives app kill

## 2. Generate platform shells

- [ ] `flutter create --project-name immortal_path --platforms=android,ios,web .`
      (keep lib/, test/, pubspec.yaml — merge only the new platform folders)
- [ ] Web notes: `shared_preferences` works with no extra setup (browser
      localStorage); `audioplayers` plays on web too
- [ ] Android: set `applicationId` to `com.kingmavin.immortalpath`,
      `android:label="Immortal Path"`, minSdk 23 or higher
- [ ] iOS: set bundle identifier and display name

## 3. Icons & identity

- [x] Procedural 1024×1024 icon + adaptive foreground + 512 store icon in
      `assets/icon/` (regenerate: `python3 tool/generate_icon.py`)
- [ ] `flutter pub get` then `dart run flutter_launcher_icons` to stamp the
      icon into the platform shells (config already in pubspec.yaml)
- [ ] Optional: replace the generated art with a commissioned icon later —
      keep the same filenames/paths

## 4. Release build

- [ ] Android keystore: create, store safely, wire `key.properties`
- [ ] Size trim (optional): the 4 WAV music loops total ~3.2 MB; converting
      them to OGG shrinks ~80% — rename files and update the paths in
      `lib/audio/audio_players_gateway.dart` and `assets/audio/`, then
      re-run `flutter test`
- [ ] `flutter build appbundle --release`

## 5. Store consoles (only you can do)

- [ ] Google Play Console / App Store Connect accounts
- [ ] Paste listing copy from STORE_LISTING.md; upload screenshots
- [ ] Host PRIVACY_POLICY.md (GitHub Pages or the raw GitHub link) and link
      it in both consoles
- [ ] Content rating questionnaire (fantasy violence, no user content)
- [ ] Data safety form: "no data collected" (see PRIVACY_POLICY.md)
- [ ] Internal testing track first: upload, install, and run a 24h idle
      check plus an offline-progress check

## 6. Monetization go-live (whenever ready)

- [ ] AdMob account → rewarded ad-unit IDs → implement a real rewarded-ads
      `MonetizationGateway` replacing `StubMonetizationGateway`
- [ ] Play Billing / StoreKit via `in_app_purchase` → real purchase gateway
- [ ] Re-test: every blessing grants its boost after a real ad; purchases
      restore after reinstall
- [ ] Flip "Contains ads" in the listing; update the data-safety form (the
      AdMob SDK collects device data) and the privacy policy

## 7. Post-launch

- [ ] Tag releases: `git tag v0.16.0 && git push --tags`
- [ ] Track issues in this repo; keep README's "What hasn't been added yet"
      honest with each release
