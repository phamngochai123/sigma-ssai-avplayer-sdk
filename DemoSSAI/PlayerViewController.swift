//
//  PlayerViewController.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 31/03/2022.
//

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: 15, y: self.view.frame.size.height - 300, width: self.view.frame.size.width - 30, height: 45))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }

import Foundation
import UIKit
import AVFoundation
import AVKit
import SSAITracking

class PlayerViewController: UIViewController, SigmaSSAIInterface, AVAssetResourceLoaderDelegate, AVPlayerItemMetadataCollectorPushDelegate {
    
    var videoUrl: String = "";
    var adsProxy: String = "https://dev-streaming.gviet.vn:8783/api/proxy-ads/ads/88f9074c-0550-476f-b312-e932286a48a1";
    var fullScreenAnimationDuration: TimeInterval {
        return 0.15
    }
    let widthDevice = UIScreen.main.bounds.width;
    let heightDevice = UIScreen.main.bounds.height;
    let keyTimedMetadata = "timedMetadata";
    let readyForDisplayKeyPath = "readyForDisplay";
    var playerItem: AVPlayerItem?;
    var topSafeArea = 0.0
    var bottomSafeArea = 0.0
    var layer: AVPlayerLayer = AVPlayerLayer();
    var ssai: SigmaSSAI?;
    var sessionUrl = "";
    //change to false if not use sdk ssai cover
    //change time interval tracking
    var playBackTime = 0.0
    private var videoPlayer: AVPlayer?
    
    @IBOutlet weak var playerView: UIView!
    let playPauseButton = UIButton(type: .system)

    var items: [String] = []
    var labels: [UILabel] = [] // Keep track of UILabels
    
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        //
    }
    //event when session fail
    func onSessionFail(_ message: String) {
        print("onSessionFailSSAI=>\(message)")
    }
    
    func onSessionInitSuccess() {
        print("onSessionInitSuccess=>", videoUrl)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
    
    func onTracking(_ message: String) {
        self.showToast(message: message, font: .systemFont(ofSize: 12.0))
    }
    
    override func viewDidLoad() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        self.ssai = SSAITracking.SigmaSSAI.init(videoUrl, adsProxy, self, playerView)
        //show or hide ssai log
        self.ssai?.setShowLog(true)
        //
        Task {
            do {
                let content = try await Helper.fetchM3U8Content(from: videoUrl)
                print("Fetched .m3u8 content:")
                print(content)

                // Define the base URL for constructing playlist links
                let baseURL = Helper.getBaseURL(from: videoUrl)

                // Extract playlist URLs
                let playlistLinks = Helper.extractPlaylistURLs(from: content, baseURL: baseURL)
                print("\nExtracted Playlist URLs:")
                for url in playlistLinks {
                    print(url)
                }
            } catch {
                print("Failed to fetch .m3u8 content: \(error)")
            }
        }
        setupPlayPauseButton()
        // Create the button
        let button = UIButton(type: .system)
        button.setTitle("Change", for: .normal)
        button.addTarget(self, action: #selector(changeSessionUrl), for: .touchUpInside)
        
        // Set button frame (or use Auto Layout)
        button.frame = CGRect(x: 10, y: 100, width: 100, height: 50)// Set background color
        button.backgroundColor = UIColor.gray
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)

        // Set corner radius
        button.layer.cornerRadius = 10
        button.clipsToBounds = true // Ensure the corner radius is applied
        
        // Set title color for better visibility
        button.setTitleColor(.white, for: .normal)
        
        // Add the button to the view
        view.addSubview(button)
        // change video url
//        let buttonChangeVideoUrl = UIButton(type: .system)
//        buttonChangeVideoUrl.setTitle("Change", for: .normal)
//        buttonChangeVideoUrl.addTarget(self, action: #selector(changeVideoUrl), for: .touchUpInside)
//        
//        // Set button frame (or use Auto Layout)
//        buttonChangeVideoUrl.frame = CGRect(x: 10, y: 150, width: 100, height: 50)// Set background color
//        buttonChangeVideoUrl.backgroundColor = UIColor.gray
//        buttonChangeVideoUrl.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
//
//        // Set corner radius
//        buttonChangeVideoUrl.layer.cornerRadius = 10
//        buttonChangeVideoUrl.clipsToBounds = true // Ensure the corner radius is applied
//        
//        // Set title color for better visibility
//        buttonChangeVideoUrl.setTitleColor(.white, for: .normal)
//        
//        // Add the button to the view
//        view.addSubview(buttonChangeVideoUrl)
    }
    private func setupPlayPauseButton() {
            playPauseButton.setTitle("Pause", for: .normal)
            playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
            playPauseButton.translatesAutoresizingMaskIntoConstraints = false
            
            // Add button to your view
            view.addSubview(playPauseButton)
            NSLayoutConstraint.activate([
                playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                playPauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
            ])
        }
    @objc func togglePlayPause() {
        if videoPlayer?.timeControlStatus == .playing {
            videoPlayer?.pause()
            playPauseButton.setTitle("Play", for: .normal)
        } else {
            videoPlayer?.play()
            playPauseButton.setTitle("Pause", for: .normal)
        }
    }
    @objc func changeSessionUrl() {
        stopBtnPressed(UIButton())
        videoUrl = videoUrl == Constants.playlist360Url ? Constants.playlist480Url : Constants.playlist360Url
        self.ssai = SSAITracking.SigmaSSAI.init(videoUrl, adsProxy, self, playerView)
        self.ssai?.setShowLog(true)
    }
//    @objc func changeVideoUrl() {
//        let newPlayerItem = AVPlayerItem(url: URL(string: videoUrl == "http://123.31.18.25:2180/manifest/manipulation/master/7d47b94e-7e65-4f9f-9fcf-9f104032ac0d/origin04/scte35-av4s-clear/master.m3u8" ? "https://vtvgolive-ssai.vtvdigital.vn/J2Jn4_Rz5-nFrKpNB6kvzw/1834651569/manifest/manipulation/master/a78b13b7-e735-47e8-90a0-4406b0769e2a/manifest/vtv3-ssai/master.m3u8?sessionId=4e8d5bf2-115b-431a-9ee6-59295ff2adc9" : "http://123.31.18.25:2180/manifest/manipulation/master/7d47b94e-7e65-4f9f-9fcf-9f104032ac0d/origin04/scte35-av4s-clear/master.m3u8")!)
//                
//                // Replace the current item with the new one
//                videoPlayer?.replaceCurrentItem(with: newPlayerItem)
//                
//                // Optionally, start playing the new video
//                videoPlayer?.play()
//    }
    override func viewWillDisappear(_ animated: Bool) {
        print("Player viewWillDisappear", animated);
        stopBtnPressed(UIButton())
        super.viewWillDisappear(animated);
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")	
        AppUtility.lockOrientation(.portrait)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("viewWillTransition=>")
        super.viewWillTransition(to: size, with: coordinator);
        if UIDevice.current.orientation.isLandscape {
            if #available(iOS 11.0, *) {
                topSafeArea = view.safeAreaInsets.top
                bottomSafeArea = view.safeAreaInsets.bottom
            } else {
                topSafeArea = topLayoutGuide.length
                bottomSafeArea = bottomLayoutGuide.length
            }
            print("Landscape=>",topSafeArea, bottomSafeArea);
            goFullscreen()
        } else {
            print("Portrait")
            minimizeToFrame()
        }
    }
    func minimizeToFrame() {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            let heightVideo = self.widthDevice * (9/16);
            self.layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: self.widthDevice, height: heightVideo)
            self.layer.videoGravity = .resizeAspectFill;
        }
    }

    func goFullscreen() {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            print("widthDevice=>", self.widthDevice, self.heightDevice)
            let widthVideo = self.widthDevice * (16/9);
            self.layer.frame = CGRect(x: (self.heightDevice - widthVideo) / 2, y: 0, width: widthVideo, height: self.widthDevice)
            self.layer.videoGravity = .resizeAspectFill
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, player == videoPlayer, keyPath == "status" {
            if player.status == .readyToPlay {
                if let duration = player.currentItem?.duration {
                    let seconds = CMTimeGetSeconds(duration)
                    print("Seconds :: \(seconds)")
                }
                videoPlayer?.play()
                let heightVideo = self.widthDevice * (9/16);
                self.layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: self.widthDevice, height: heightVideo)
                self.layer.videoGravity = .resizeAspectFill;
            } else if player.status == .failed {
                stopBtnPressed(UIButton())
            }
        }
    }
    private func startPlayer() {
        print("start player ", videoUrl)
        if let url = URL(string: videoUrl) {
            // Use the asset from your SSAI if applicable
            let asset = self.ssai?.getAsset() ?? AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer = AVPlayer(playerItem: playerItem)
            self.ssai?.setPlayer(videoPlayer!)

            // Create and configure the AVPlayerViewController
            // playerViewController = AVPlayerViewController()
            // playerViewController?.player = videoPlayer
            
            // Listen for player status changes
            videoPlayer?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)

            // Observe playback time
            videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: DispatchQueue.main) { [weak self] time in
                guard let self = self else { return }
                let playbackTime = CMTimeGetSeconds(time)
                // Update your playback time variable here
                self.playBackTime = playbackTime
            }
            
            videoPlayer?.volume = 1.0
            
            
            layer = AVPlayerLayer(player: videoPlayer);
            layer.backgroundColor = UIColor.white.cgColor
            let heightVideo = widthDevice * (9/16);
            layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: widthDevice, height: heightVideo)
            layer.videoGravity = .resizeAspectFill
            playerView.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            playerView.layer.addSublayer(layer)
            
            // Present the AVPlayerViewController
//            if let playerVC = playerViewController {
//                playerVC.modalPresentationStyle = .fullScreen
//                present(playerVC, animated: true) {
//                    self.videoPlayer?.play() // Start playback when presented
//                }
//            }
        }
    }

    
    func stopBtnPressed(_ sender: Any) {
//        videoUrl = ""
        self.ssai?.clear()
        videoPlayer?.pause()
        videoPlayer = nil
        self.ssai = nil
        playerView.layer.sublayers?
            .filter { $0 is AVPlayerLayer }
            .forEach { $0.removeFromSuperlayer() }
        playerView.backgroundColor = .black
        self.title = ""
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
