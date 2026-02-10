# CustomerGlu iOS SDK

CustomerGlu SDK for iOS provides in-app gamification, rewards, and engagement campaigns with minimal integration effort.

**Current Version:** 4.0.0

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/customerglu/CG-iOS-SDK`
3. Select version **4.0.0** or "Up to Next Major"
4. Click **Add Package**

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'CustomerGlu', '~> 4.0.0'
```

Then run:

```bash
pod install
```

## Initialization

### 1. Add Write Key to Info.plist

```xml
<key>CUSTOMERGLU_WRITE_KEY</key>
<string>YOUR_WRITE_KEY</string>
```

### 2. Initialize the SDK

```swift
import CustomerGlu

// CustomerGlu follows the singleton pattern
let customerGlu = CustomerGlu.getInstance
```

### 3. Register User

```swift
CustomerGlu.getInstance.registerDevice(userId: "user-123") { success in
    if success {
        // User registered, SDK is ready
    }
}
```

## Key Features

- **Entry Points**: Floating buttons, banners, embedded views, tooltips, PiP video
- **Campaign Display**: Bottom sheets, popups, full-screen WebView campaigns
- **Real-time Updates**: Server-Sent Events (SSE) for live nudges
- **Deep Linking**: Handle campaign deep links and navigation
- **Analytics**: Automatic event tracking and diagnostics

## Documentation

Full documentation: [https://docs.customerglu.com/sdk/ios](https://docs.customerglu.com/sdk/ios)
