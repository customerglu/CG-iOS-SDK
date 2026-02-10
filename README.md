# CustomerGlu iOS SDK

In-app gamification, rewards, and engagement campaigns for iOS.

**Version:** `4.0.0`

> **All CustomerGlu SDKs share the same version number.**
> iOS `4.0.0` · Android `4.0.0` · React Native `4.0.0`

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## Installation

### Swift Package Manager (Recommended)

1. In Xcode: **File → Add Package Dependencies**
2. Enter: `https://github.com/customerglu/CG-iOS-SDK`
3. Select version `4.0.0` or **Up to Next Major**
4. Click **Add Package**

### CocoaPods

```ruby
# Podfile
pod 'CustomerGlu', '~> 4.0.0'
```

```bash
pod install
```

## Quick Start

### 1. Add Write Key to Info.plist

```xml
<key>CUSTOMERGLU_WRITE_KEY</key>
<string>YOUR_WRITE_KEY</string>
```

### 2. Initialize

```swift
import CustomerGlu

let customerGlu = CustomerGlu.getInstance
```

### 3. Register User

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
CustomerGlu.getInstance.sendEventData(eventName: "purchase", eventProperties: ["amount": 99])

// Update user attributes
CustomerGlu.getInstance.updateProfile(userAttributes: ["plan": "premium"])
```

## Features

| Feature | Description |
|---------|-------------|
| Entry Points | Floating buttons, banners, embedded views, tooltips, PiP video |
| Campaigns | Bottom sheets, popups, full-screen WebView campaigns |
| Real-time | Server-Sent Events (SSE) for live nudges |
| Deep Linking | Campaign deep links and in-app navigation |
| Analytics | Automatic event tracking and diagnostics |

## Other SDKs

| Platform | Package | Install |
|----------|---------|---------|
| **Android** | `com.customerglu:CustomerGluLibrary:4.0.0` | [Maven Central](https://central.sonatype.com/artifact/com.customerglu/CustomerGluLibrary) |
| **React Native** | `@customerglu/react-native-customerglu` | [npm](https://www.npmjs.com/package/@customerglu/react-native-customerglu) |

## Documentation

[https://docs.customerglu.com/sdk/ios](https://docs.customerglu.com/sdk/ios)
