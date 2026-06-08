# Live TV App (Flutter)

A minimal Android live-TV app. Channels are loaded from a JSON file you host
on your server. **To change the channels or stream links, you just edit that
one JSON file — every app updates the next time it opens. No rebuild needed.**

---

## How it works

```
channels.json (on your server)  ←—— you edit this
        │
        ▼
   App fetches it on launch
        │
        ▼
   Channel list  ──tap──►  HLS player (.m3u8)
```

---

## Setup (one time)

1. **Install Flutter** — https://docs.flutter.dev/get-started/install
   Then check it works:
   ```
   flutter doctor
   ```

2. **Create the project scaffold** (this generates the android/ folder):
   ```
   flutter create livetv
   ```

3. **Copy the provided files into the project**, replacing what's there:
   - `pubspec.yaml`  →  livetv/pubspec.yaml
   - everything in `lib/`  →  livetv/lib/

4. **Point the app at your server.** Open
   `lib/services/channel_service.dart` and change:
   ```dart
   static const String channelsUrl = 'https://yourdomain.com/channels.json';
   ```

5. **Upload `channels.json`** to that URL (any static host works: your own
   server, GitHub Pages, Cloudflare R2, Netlify, etc.).

6. **Install dependencies:**
   ```
   cd livetv
   flutter pub get
   ```

---

## ⚠️ Two required Android edits

Open `android/app/src/main/AndroidManifest.xml`.

**a) Internet permission** — add this just above the `<application>` tag:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**b) Allow plain http streams** — many free/live HLS feeds are `http://`,
not `https://`, and Android blocks those by default. Add this attribute to
the `<application ...>` tag:
```xml
<application
    android:usesCleartextTraffic="true"
    ... >
```
(Skip this only if every one of your stream URLs is https.)

---

## Build the APK

```
flutter build apk --release
```

The installable file lands at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Copy that to your phone and install it (you'll need to allow
"install from unknown sources"). To test live on a plugged-in phone instead:
```
flutter run
```

---

## Changing channels later

Just edit `channels.json` on your server. Format:
```json
[
  { "name": "Channel Name", "category": "News", "logo": "https://.../logo.png", "url": "https://.../stream.m3u8" }
]
```
`logo` and `category` are optional. `url` must be an HLS (`.m3u8`) or other
stream the player supports.

---

## Note on content

This app is content-neutral — it plays whatever streams you put in the JSON.
Rebroadcasting licensed TV channels without rights will get the app removed
and can carry legal liability. Use it for free-to-air/public feeds, your own
content, or properly licensed streams.
