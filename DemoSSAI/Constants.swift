//
//  Constants.swift
//  DemoSSAI
//
//  Created by Pham Hai on 14/10/2024.
//

import Foundation

struct Constants {
    // URL constants
    static let baseDomain = "https://stream-cdn.sigmadrm.com/manifest/channel-test"
    static let adsEndpoint = "da914c58-5c6e-41b7-93b7-0597c4a983ee"
    static let adsEndpointQuery = "sigma.dai.adsEndpoint=\(adsEndpoint)"
    static let drmUrl = "\(baseDomain)/manifest/origin04/scte35-av4s-sigma-drm/master.m3u8?\(adsEndpointQuery)"
    static let hlsSCTE35 = "\(baseDomain)/mastersplit-master.m3u8?\(adsEndpointQuery)"
    static let hlsTs2s = "\(baseDomain)/masterhls-ts-2s.m3u8?\(adsEndpointQuery)"
    static let hlsTs4s = "\(baseDomain)/masterhls-ts-4s.m3u8?\(adsEndpointQuery)"
    static let hlsTs6s = "\(baseDomain)/masterhls-ts-6s.m3u8?\(adsEndpointQuery)"
    static let ANTV = "https://vtv-live-push-token.akamaized.net/hls/live/2029307/vtv1/playlist.m3u8?hdnts=exp=1747367448~acl=/hls/live/2029307/vtv1/*~hmac=746fcf4d5f7d29e8cf52f66b8b18c3d2647e0dc60c46b2df3d10872444a05006?\(adsEndpointQuery)"
    static let sourceTestStreamMux = "https://vtv-live-push-token.akamaized.net/hls/live/2029307/vtv1/playlist.m3u8?hdnts=exp=1745481663~acl=/hls/live/2029307/vtv1/*~hmac=7e9ad112ec391e62f541af0eed335a72289c0d957029d57b8eb9146857091323&\(adsEndpointQuery)"
    static let sourceTestTearOfSteel = "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8?\(adsEndpointQuery)"
//    static let playlist480Url = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/playlist_480.m3u8"
//    static let playlist360Url = "https://lrm-test.sigma.video:1643/manifest/origin04/scte35-av4s-clear/playlist_360.m3u8"
    
    static let urls = [
        ["url": hlsSCTE35, "isLive": true, "name": "SCTE 35", "isDrm": false],
        ["url": hlsTs2s, "isLive": true, "name": "Hls 2s", "isDrm": false],
        ["url": hlsTs4s, "isLive": true, "name": "Hls 4s", "isDrm": false],
        ["url": hlsTs6s, "isLive": true, "name": "Hls 6s", "isDrm": false],
        ["url": drmUrl, "isLive": true, "name": "Link drm", "isDrm": true],
        ["url": ANTV, "isLive": false, "name": "ANTV", "isDrm": false],
        ["url": sourceTestStreamMux, "isLive": true, "name": "Vod", "isDrm": true],
        ["url": sourceTestTearOfSteel, "isLive": false, "name": "Tear of steel", "isDrm": false]
    ] as [[String: Any]]

    // API keys
    static let apiKey = "YOUR_API_KEY"

    // Notification names
    static let userLoggedInNotification = Notification.Name("UserLoggedIn")
    static let userLoggedOutNotification = Notification.Name("UserLoggedOut")

    // Other constants
    static let defaultTimeout: TimeInterval = 60.0
    static let maxRetries = 3
    //drm info
    static let drmScheme = "SIGMA_DRM"
    static let merchantId = "d5321abd-6676-4bc1-a39e-6bb763029e54"
    static let appId = "7444c496-67be-4998-8b29-82152668ba20"
    static let assetId = "123"
    static let host = "https://api.sigmadrm.com"
    static let baseUrl = ""
}
