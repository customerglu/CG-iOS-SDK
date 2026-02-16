<p align="center">
  <h1 align="center">CustomerGlu iOS SDK</h1>
  <p align="center">In-app gamification, rewards, and engagement campaigns for iOS.</p>
</p>

<p align="center">
  <a href="https://cocoapods.org/pods/CustomerGlu"><img src="https://img.shields.io/cocoapods/v/CustomerGlu?label=CocoaPods&color=blue" alt="CocoaPods"></a>
  <a href="https://github.com/customerglu/CG-iOS-SDK"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen" alt="SPM Compatible"></a>
  <a href="https://docs.customerglu.com/sdk/ios"><img src="https://img.shields.io/badge/docs-customerglu.com-green" alt="Documentation"></a>
  <a href="https://github.com/customerglu/CG-iOS-SDK/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-lightgrey" alt="License"></a>
</p>

<p align="center">
  <b>All CustomerGlu SDKs share the same version number.</b><br>
  iOS <code>4.1.0</code> · Android <code>4.1.0</code> · React Native <code>4.1.0</code>
</p>

---

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Entry Points](#entry-points)
- [Features](#features)
- [What's New in 4.1.0](#whats-new-in-410)
- [Troubleshooting](#troubleshooting)
- [Other SDKs](#other-sdks)
- [Documentation](#documentation)

---

## Requirements

| Requirement | Minimum |
|-------------|---------|
| iOS | 14.0+ |
| Xcode | 13.0+ |
| Swift | 5.0+ |

---

## Installation

### Swift Package Manager (Recommended)

1. In Xcode: **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/customerglu/CG-iOS-SDK
   ```
3. Select **Up to Next Major Version** from `4.1.0`
4. Click **Add Package**

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'CustomerGlu', '~> 4.1.0'
```

Then install:

```bash
pod install
```

Open the `.xcworkspace` file (not `.xcodeproj`) after installation.

---

## Quick Start

### 1. Add Your Write Key

In `Info.plist`:

```xml
<key>CUSTOMERGLU_WRITE_KEY</key>
<string>YOUR_WRITE_KEY</string>
```

You can find your write key in the [CustomerGlu Dashboard](https://dashboard.customerglu.com) under **Settings → SDK Keys**.

### 2. Initialize the SDK

```swift
import CustomerGlu

// In AppDelegate or your app's entry point
let customerGlu = CustomerGlu.getInstance
```

### 3. Register a User

```swift
CustomerGlu.getInstance.registerDevice(userId: "user-123") { success in
    if success {
        // SDK ready — entry points, nudges, and campaigns are now active
    }
}
```

### 4. Common Operations

```swift
// Open the rewards wallet
CustomerGlu.getInstance.openWallet()

// Load all campaigns
CustomerGlu.getInstance.loadAllCampaigns()

// Send a custom event
CustomerGlu.getInstance.sendEventData(
    eventName: "purchase",
    eventProperties: ["amount": 99]
)

// Update user attributes
CustomerGlu.getInstance.updateProfile(
    userAttributes: ["plan": "premium"]
)
```

---

## Entry Points

Entry points are UI elements the SDK renders in your app. Configure them in the dashboard and embed them using `BannerView`:

```swift
import CustomerGlu

// Programmatically
let bannerView = BannerView()
bannerView.bannerId = "home_rewards_banner"
view.addSubview(bannerView)
```

```swift
// Or via Interface Builder / SwiftUI
// Set the bannerId in code after the view loads
bannerView.bannerId = "home_rewards_banner"
```

The SDK handles rendering, styling, and click actions automatically based on your dashboard configuration.

---

## Features

| Feature | Description |
|---------|-------------|
| **Entry Points** | Floating buttons, banners, embedded views, tooltips, PiP video |
| **Campaigns** | Bottom sheets, popups, full-screen WebView campaigns |
| **Native Widgets** | DYNAMIC_MULTISTEP progress widgets rendered natively (no WebView) |
| **Real-time** | Server-Sent Events (SSE) for live nudges and state updates |
| **Deep Linking** | Campaign deep links and in-app navigation |
| **Analytics** | Automatic event tracking and diagnostics |
| **Multi-region** | ME, US, and default API endpoints — resolved automatically |

---

## What's New in 4.1.0

- **DYNAMIC_MULTISTEP native rendering** — three widget variants (MS1, MS2, MS3) rendered natively instead of WebView for better performance and native feel
- **Native style support** — 19 configurable `nativeStyle` fields (colors, fonts, border radius, shimmer, etc.) controlled via dashboard
- **SVG header images** — rendered inline via WKWebView
- **Auto-height** — widgets calculate preferred height and override dashboard percentage values
- **MS3 expand/collapse** — animated accordion with height resize propagation
- **CTA shimmer animation** — shimmer effect on call-to-action buttons
- **Campaign lookup fallback** — `CG_CAMPAIGNS_LOADED` notification rebuilds widget when campaigns load late
- **Custom CGBanner decoder** — handles type mismatches and unknown fields gracefully for forward compatibility

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| SDK not initializing | Verify `CUSTOMERGLU_WRITE_KEY` in `Info.plist` |
| Banners not showing | Check `bannerId` matches dashboard config; ensure `registerDevice` succeeded |
| CocoaPods conflict | Run `pod repo update` then `pod install` |
| SPM resolution error | Reset package caches: **File → Packages → Reset Package Caches** |
| Events not tracking | Confirm user is registered; check network connectivity |

---

## Other SDKs

| Platform | Package | Install |
|----------|---------|---------|
| **Android** | `com.customerglu:CustomerGluLibrary:4.1.0` | [Maven Central](https://central.sonatype.com/artifact/com.customerglu/CustomerGluLibrary) |
| **React Native** | `@customerglu/react-native-customerglu` | [npm](https://www.npmjs.com/package/@customerglu/react-native-customerglu) |

---

## Documentation

Full SDK docs, guides, and API reference:

**[https://docs.customerglu.com/sdk/ios](https://docs.customerglu.com/sdk/ios)**

---

## License

[MIT](LICENSE)
