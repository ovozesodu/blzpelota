# BLZPelotaSignalKit

BLZ Pelota local SwiftUI package for server-driven signal launches with:

- camera upload support for web file inputs
- photo library upload support
- files picker fallback
- WebKit media capture permission handling for trusted hosts
- reactive language forwarding through `@AppStorage("appLanguage")`
- audio keepalive workarounds for game-like web runtimes

Requires `iOS 15+`.

## Add To An App

```swift
dependencies: [
    .package(path: "Packages/BLZPelotaSignalKit")
]
```

```swift
import BLZPelotaSignalKit
```

## Configure

```swift
let webConfiguration = PelotaSignalConfiguration(
    serverDomain: "example.com",
    webToken: "token",
    bundleID: Bundle.main.bundleIdentifier ?? "com.blz.pelotamixteca"
)
```

Preset example:

```swift
PelotaSignalConfiguration.blzPelotaPreset
```

## Launch Panel

```swift
PelotaSignalLaunchPanel(
    configuration: .blzPelotaPreset
)
```

## Root Flow

```swift
PelotaSignalRootFlow(
    configuration: .blzPelotaPreset,
    requestReviewBeforeCheck: false
) {
    RootView()
}
```

## Required Info.plist Keys

- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSPhotoLibraryUsageDescription`
