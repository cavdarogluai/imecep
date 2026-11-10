# imeCep

Offline Bluetooth mesh messaging for emergencies — no internet, accounts, phone numbers or servers needed.
Based on [bitchat](https://github.com/permissionlesstech/bitchat) (GPL-3.0 for imeCep's additions).

- **One-tap status:** "I'm safe" / SOS broadcast over the Bluetooth mesh, repeated for 30 minutes.
- **Offline emergency guide:** earthquake, trapped, fire, flood, first aid, water/food, battery saving (TR + EN).
- **Low-power helper**, auto-delete of local messages, end-to-end encrypted private messages (Noise).
- **Sponsors:** imeCep is free and has no ads.

> imeCep does not replace 112 / local emergency services. This software has not had an external security review.

## Layout

| Folder | Platform | Build |
|---|---|---|
| `ios/` | iOS (SwiftUI) | Open `ios/bitchat.xcodeproj`, scheme `bitchat (iOS)`. Set your own signing team and bundle ID. |
| `android/` | Android (Kotlin) | `cd android && ./gradlew assembleDebug` |

## License

GPL-3.0 — see [LICENSE.md](LICENSE.md) and [NOTICE.md](NOTICE.md).
