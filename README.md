# SSAITracking SDK Integration Guide

 **Version**: 1.1.0

**Organization**: Thủ Đô Multimedia

## Table of Contents

- [SSAITracking SDK Integration Guide](#ssaitracking-sdk-integration-guide)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
  - [2. Scope](#2-scope)
  - [3. System Requirements](#3-system-requirements)
  - [4. SDK Installation](#4-sdk-installation)
  - [5. SDK Integration](#5-sdk-integration)
    - [5.1 SDK Initialization](#51-sdk-initialization)
    - [Parameter Definitions](#parameter-definitions)
    - [5.2 Generating Video URL](#52-generating-video-url)
    - [5.3 Listening for Callbacks](#53-listening-for-callbacks)
    - [5.4 Additional SDK Configuration](#54-additional-sdk-configuration)
  - [6. Important Notes](#6-important-notes)
  - [7. Callback Descriptions](#7-callback-descriptions)
  - [8. Conclusion](#8-conclusion)
  - [9. References](#9-references)

## 1. Introduction

This document provides a guide for integrating and using the SSAITracking SDK for iOS applications, specifically for iOS version 12.4 and above. It includes detailed information on installation, SDK initialization, and handling necessary callbacks.

## 2. Scope

This document applies to iOS developers who want to integrate the SSAITracking SDK into their applications, including requesting IDFA access as per App Tracking Transparency requirements.

## 3. System Requirements

* **Operating System**: iOS 12.4 and above
* **Device**: Physical device required
* **Additional Requirement**: App Tracking Transparency authorization needed **on ios 14+**

## 4. SDK Installation

To install the SSAITracking SDK, follow these steps:

1. **Update Info.plist**:

- Add the `NSUserTrackingUsageDescription` key with a custom message describing the usage of IDFA:

```swift
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

- Allow HTTP requests to localhost. Add the following configuration to allow HTTP requests specifically to localhost:

```swift
<key>NSAppTransportSecurity</key>
<dict>
   <key>NSAllowsArbitraryLoads</key>
   <true/>
   <key>NSExceptionDomains</key>
   <dict>
      <key>localhost</key>
      <dict>
          <key>NSExceptionAllowsInsecureHTTPLoads</key>
          <true/>
          <key>NSIncludesSubdomains</key>
          <true/>
      </dict>
    </dict>
</dict>
```

2. **Declare the library in Podfile**:

```swift
pod 'SSAITracking', :git => 'https://github.com/sigmaott/sigma-ssai-ios.git', :tag => '1.1.0'
```

3. **Run the installation command**:

```swift
cd [path to your project]
pod install
```

## 5. SDK Integration

### 5.1 SDK Initialization

* **Import the SDK**:

```swift
import SSAITracking
```

* **Call the start function when your application launches**:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      SSAITracking.SigmaSSAI.start()
      return true
  }
```

* **Initialize the SDK with the required parameters**:

```swift
self.ssai = SSAITracking.SigmaSSAI.init(self, playerView, enableNonce)
```

### Parameter Definitions

* **`self`**: A reference to the current instance of your class, which must conform to the `SigmaSSAIInterface` protocol to handle callbacks.
* **`playerView`**: The view where the video player will be displayed.
* **`enableNonce`**  Enables or disables the use of a `nonce` in ad requests. When set to `true`, the SDK will include a `nonce` parameter in requests to  **Google Ad Manager (GAM)**. This helps GAM understand the context of the ad request, which can improve ad targeting, verification, or compliance with GAM policies.

> ✅ Recommended to enable (`true`) if you're using Google Ad Manager for ad serving.

### 5.2 Generating Video URL

Once the SDK is initialized, generate the video URL by calling the `generateUrl` method with the `videoUrl` parameter:

**Example**: https://example.com/master.m3u8

```swift
self.ssai?.generateUrl(videoUrl)
```

### 5.3 Listening for Callbacks

After calling `generateUrl`, listen for callbacks from the SDK:

* **Success Callback**:
  When the video URL is successfully generated, the `onGenerateVideoUrlSuccess` method will be called.
* **Failure Callback**:
  If there is an error generating the video URL, the `onGenerateVideoUrlFail` method will be invoked.

### 5.4 Additional SDK Configuration

`setManifestTimeout`

```swift
SSAITracking.SigmaSSAI.setManifestTimeout(6000)
```

* **Description**: Sets the timeout (in milliseconds) for manifest requests from the proxy to the origin server or CDN.
* **Parameter**:

    `manifestTimeout`: Timeout in milliseconds. For example, `6000` means 6 seconds.

📝  **Note** : This is a **static** method and should be called on `SSAITracking.SigmaSSAI` directly. You can call `setManifestTimeout` **after** `SSAITracking.SigmaSSAI.start()` and **before calling** `generateUrl(...)` to ensure the setting is applied for the upcoming playback session.

`setCustomData`

```swift
let jsonObject: [String: Any] = [
    "content_id": "movie123",
    "is_premium": false,
    "user_age": 25
 ]
if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
   let jsonString = String(data: jsonData, encoding: .utf8) {
   print("onGenerateVideoUrlSuccess: \(jsonString)")
   self.ssai?.setCustomData(self.initialVideoUrl, customDataJsonStr: jsonString)
 }
```

* **Description**: Sends JSON-formatted custom parameters to the ad server.
* **Parameters**:

    `url`: Original manifest URL.

    `customDataJsonStr`: JSON string with targeting parameters.

📝 **Note**: `setCustomData` should be called immediately before starting video playback to ensure correct configuration for the upcoming stream.

`setAdsEndpoint`

```swift
self.ssai?.setAdsEndpoint(initialVideoUrl, adsEndpoint)
```

* **Description** : Updates the ads endpoint associated with a specific manifest URL. Useful for dynamically overriding the default `adsEndpoint` during a playback session.
* **Parameters** :
* `initialVideoUrl`: The original manifest URL (before SSAI processing).
* `adsEndpoint`: ads endpoint to apply.

📝  **Note** : This method can be called  **at any time during a playback session** , even while the video is playing. However, it is **recommended** to call `setAdsEndpoint` inside `onGenerateVideoUrlSuccess(...)` to ensure correct association before playback starts.

## 6. Important Notes

Always remember to call `setPlayer` on the SDK after initializing the `AVPlayer` or replacing the current item. This ensures that the SDK correctly recognizes the active video player and can effectively manage ad tracking. If you need to change the `adsEndpoint`, it is essential to reinitialize the SDK. This ensures that the new endpoint is properly configured and used for tracking.

## 7. Callback Descriptions

* `onGenerateVideoUrlSuccess(_ videoUrl: String)`: Called when the video URL is successfully generated.
* `onGenerateVideoUrlFail(_ message: String, videoUrl: String)`: Called when there is an error in generating the video URL. message is errorCode, videoUrl is video url input
* `onTracking(_ message: String)`: Called whenever there is a tracking message.

## 8. Conclusion

By following the steps outlined above, you can successfully integrate and utilize the SSAITracking SDK within your application. Ensure that you handle both success and failure callbacks to provide a seamless user experience.

## 9. References

* SSAITracking demo link: [Demo Link](https://github.com/sigmaott/sigma-ssai-avplayer-sdk)
