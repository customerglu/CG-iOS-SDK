# CustomerGlu iOS SDK - Swift Integration Guide

## What is CustomerGlu?

CustomerGlu is a **customer engagement platform** that enables you to add powerful engagement features to your iOS app:

- 📢 In-app campaigns & nudges
- 🎯 Promotional banners, popups, tooltips
- 🎮 Gamification & rewards wallet
- 🎬 Picture-in-Picture videos
- 🔘 Floating action buttons
- 🔗 Deep linking & real-time updates

---

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 13.0+ |
| Xcode | 13.0+ |
| Swift | 5.0+ |

---

## Installation

### Option A: Swift Package Manager (Recommended)

1. Open your project in Xcode
2. Go to **File → Add Packages**
3. Enter the repository URL:
   ```
   https://github.com/customerglu/CG-iOS-SDK
   ```
4. Select your desired version
5. Click **Add Package** and add to your target

### Option B: CocoaPods

Add to your `Podfile`:

```ruby
pod 'CustomerGlu'
```

Then run:

```bash
pod install
```

---

## Configuration

### Step 1: Configure Info.plist

Add your CustomerGlu write key to your app's `Info.plist`:

```xml
<key>CUSTOMERGLU_WRITE_KEY</key>
<string>YOUR_WRITE_KEY_HERE</string>
```

> 💡 You'll receive your write key from the CustomerGlu dashboard after creating your account.

---

## Implementation

### Step 2: Initialize the SDK

Initialize CustomerGlu in your `AppDelegate.swift`:

```swift
import CustomerGlu

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initialize CustomerGlu SDK
        let customerGlu = CustomerGlu.getInstance
        customerGlu.initializeSdk()

        // Optional: Enable debug mode during development
        #if DEBUG
        customerGlu.gluSDKDebuggingMode(enabled: true)
        #endif

        return true
    }
}
```

For **SwiftUI** apps using `@main App`:

```swift
import SwiftUI
import CustomerGlu

@main
struct MyApp: App {

    init() {
        // Initialize CustomerGlu SDK
        CustomerGlu.getInstance.initializeSdk()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

### Step 3: Register a User

Register the user after login or when user identity is available:

```swift
import CustomerGlu

func registerUser() {
    let userData: [String: AnyHashable] = [
        "userId": "unique-user-id-123",      // Required: Unique identifier
        "email": "user@example.com",          // Optional
        "userName": "John Doe",               // Optional
        "phone": "+1234567890"                // Optional
    ]

    CustomerGlu.getInstance.registerDevice(userdata: userData) { success in
        if success {
            print("CustomerGlu: User registered successfully")
        } else {
            print("CustomerGlu: Registration failed")
        }
    }
}
```

#### With Custom Attributes

```swift
let userData: [String: AnyHashable] = [
    "userId": "user-123",
    "email": "user@example.com",
    "customAttributes": [
        "plan": "premium",
        "signupDate": "2024-01-15",
        "totalOrders": 42
    ]
]

CustomerGlu.getInstance.registerDevice(userdata: userData) { success in
    // Handle response
}
```

---

### Step 4: Enable Entry Points

Enable entry points to display campaigns configured in your CustomerGlu dashboard:

```swift
// Enable campaign entry points
CustomerGlu.getInstance.enableEntryPoints(enabled: true)

// Start real-time updates (Server-Sent Events)
CustomerGlu.getInstance.startSSEOnForeground()
```

---

## Common Features

### Open Rewards Wallet

```swift
// Simple wallet open
CustomerGlu.getInstance.openWallet(auto_close_webview: true)

// With configuration
let config = CGNudgeConfiguration()
config.closeOnDeepLink = true
config.opacity = 0.5
CustomerGlu.getInstance.openWallet(nudgeConfiguration: config)
```

### Open a Specific Nudge/Campaign

```swift
// Basic usage
CustomerGlu.getInstance.openNudge(nudgeId: "your-nudge-id")

// With layout options
CustomerGlu.getInstance.openNudge(
    nudgeId: "your-nudge-id",
    layout: "full-default",      // Layout style
    bg_opacity: 0.5,             // Background opacity
    closeOnDeeplink: true        // Auto-close on deep link
)
```

### Handle Deep Links

```swift
func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {

    CustomerGlu.getInstance.openDeepLink(deepurl: url) { state, message, data in
        switch state {
        case .SUCCESS:
            print("Deep link handled successfully")
        case .INVALID_URL:
            print("Invalid URL")
        case .CAMPAIGN_UNAVAILABLE:
            print("Campaign not available")
        default:
            print("Status: \(message)")
        }
    }

    return true
}
```

### Update User Profile

```swift
let updatedData: [String: AnyHashable] = [
    "email": "newemail@example.com",
    "userName": "Jane Doe"
]

CustomerGlu.getInstance.updateProfile(userdata: updatedData)
```

### Update Custom Attributes

```swift
let customAttributes: [String: AnyHashable] = [
    "lastPurchaseDate": "2024-03-15",
    "loyaltyPoints": 1500
]

CustomerGlu.getInstance.updateUserAttributes(customAttributes: customAttributes)
```

---

## UI Customization

### Dark Mode Support

```swift
// Enable dark mode
CustomerGlu.getInstance.enableDarkMode(isDarkModeEnabled: true)

// Listen to system dark mode changes
CustomerGlu.getInstance.listenToDarkMode(allowToListenDarkMode: true)

// Check current state
let isDark = CustomerGlu.getInstance.isDarkModeEnabled()
```

### Loader & Colors

```swift
// Configure loader colors
CustomerGlu.getInstance.configureLoaderColour(color: [.systemBlue, .systemPurple])

// Configure loading screen background
CustomerGlu.getInstance.configureLoadingScreenColor(color: .white)

// Configure light/dark mode backgrounds
CustomerGlu.getInstance.configureLightBackgroundColor(color: .white)
CustomerGlu.getInstance.configureDarkBackgroundColor(color: .black)
```

### Default Banner Image

```swift
CustomerGlu.getInstance.setDefaultBannerImage(bannerUrl: "https://example.com/default-banner.png")
```

---

## Push Notifications

Handle CustomerGlu notifications:

```swift
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
) {
    // Check if notification is from CustomerGlu
    if CustomerGlu.getInstance.notificationFromCustomerGlu(remoteMessage: userInfo as! [String: AnyHashable]) {
        CustomerGlu.getInstance.cgapplication(
            application,
            didReceiveRemoteNotification: userInfo,
            backgroundAlpha: 0.5,
            auto_close_webview: true,
            fetchCompletionHandler: completionHandler
        )
    } else {
        // Handle other notifications
        completionHandler(.noData)
    }
}
```

---

## Campaign Status

### Check Campaign Validity

```swift
CustomerGlu.getInstance.isCampaignValid(
    campaignId: "campaign-123",
    dataType: .API  // .API for fresh data, .CACHE for cached
) { isValid in
    if isValid {
        print("Campaign is valid")
    }
}
```

### Get Campaign Status

```swift
CustomerGlu.getInstance.getCampaignStatus(
    campaignId: "campaign-123",
    dataType: .API
) { status in
    switch status {
    case .IN_PROGRESS:
        print("Campaign in progress")
    case .PRISTINE:
        print("Campaign not started")
    case .COMPLETED:
        print("Campaign completed")
    case .NOT_ELIGIBLE:
        print("User not eligible")
    }
}
```

---

## Diagnostics & Debugging

```swift
// Enable debug logging
CustomerGlu.getInstance.gluSDKDebuggingMode(enabled: true)

// Enable crash logging
CustomerGlu.getInstance.setCrashLoggingEnabled(isCrashLoggingEnabled: true)

// Enable metrics logging
CustomerGlu.getInstance.setMetricsLoggingEnabled(isMetricsLoggingEnabled: true)

// Enable diagnostics
CustomerGlu.getInstance.setDiagnosticsEnabled(isDiagnosticsEnabled: true)

// Enable analytics events
CustomerGlu.getInstance.enableAnalyticsEvent(event: true)
```

---

## Cleanup

### Clear SDK Data

```swift
// Clear all CustomerGlu data (useful for logout)
CustomerGlu.getInstance.clearGluData()
```

### Disable SDK

```swift
// Temporarily disable the SDK
CustomerGlu.getInstance.disableGluSdk(disable: true)
```

---

## Quick Reference

| Task | Code |
|------|------|
| Get instance | `CustomerGlu.getInstance` |
| Initialize | `.initializeSdk()` |
| Register user | `.registerDevice(userdata:completion:)` |
| Open wallet | `.openWallet(auto_close_webview: true)` |
| Open nudge | `.openNudge(nudgeId: "id")` |
| Enable campaigns | `.enableEntryPoints(enabled: true)` |
| Update profile | `.updateProfile(userdata: [...])` |
| Update attributes | `.updateUserAttributes(customAttributes: [...])` |
| Handle deep link | `.openDeepLink(deepurl:completion:)` |
| Check notification | `.notificationFromCustomerGlu(remoteMessage:)` |
| Clear data | `.clearGluData()` |
| Debug mode | `.gluSDKDebuggingMode(enabled: true)` |
| Dark mode | `.enableDarkMode(isDarkModeEnabled: true)` |

---

## State Enums

### CGSTATE (Deep Link Results)

| Value | Description |
|-------|-------------|
| `.SUCCESS` | Operation successful |
| `.USER_NOT_SIGNED_IN` | User not registered |
| `.INVALID_URL` | Invalid deep link URL |
| `.INVALID_CAMPAIGN` | Campaign ID invalid |
| `.CAMPAIGN_UNAVAILABLE` | Campaign not available |
| `.NETWORK_EXCEPTION` | Network error |
| `.DEEPLINK_URL` | Deep link processed |
| `.EXCEPTION` | General exception |

### CAMPAIGN_STATE

| Value | Description |
|-------|-------------|
| `.IN_PROGRESS` | Campaign is active |
| `.PRISTINE` | Campaign not started |
| `.COMPLETED` | Campaign finished |
| `.NOT_ELIGIBLE` | User not eligible |

---

## Resources

- **Documentation:** [https://docs.customerglu.com/sdk/ios](https://docs.customerglu.com/sdk/ios)
- **GitHub Repository:** [https://github.com/customerglu/CG-iOS-SDK](https://github.com/customerglu/CG-iOS-SDK)
- **Support:** code@customerglu.net

---

## License

Apache License, Version 2.0
