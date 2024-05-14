//
//  CGVideoPlayer.swift
//  UIViewPlayerTesting
//
//  Created by Amit Samant on 03/11/23.
//

import UIKit
import AVFoundation
import OSLog


public enum CGMediaPlayerScreenTimeBehaviour {
    case keepSystemIdleBehaviour
    case preventFromIdle
}
public enum CGMediaPlayingBehaviour {
    case autoPlayOnLoad
    case playOnDemand
}
public protocol CGVideoplayerListener{
    func showPlayerCTA()
}
public protocol CGPiPMovieVideoCallbacks {
    func onVideo25Completed()
    func onVideo50Completed()
    func onVideo75Completed()
    func onVideoCompleted()
}

public class CGVideoPlayer: UIView {
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    public var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
        }
    }
    
    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    
    private var playerItemContext = 0
    private var playerItem: AVPlayerItem?
    private var mediaPlayingBehaviour: CGMediaPlayingBehaviour = .playOnDemand
    private var screenTimeBehaviour: CGMediaPlayerScreenTimeBehaviour = .keepSystemIdleBehaviour
    private var isPaused = false
    private var isMuted = false
    private var isMoveToForeground = true
    private var shouldVideoLoop = false
    var delegate: CGVideoplayerListener?
    var videoListeners: CGPiPMovieVideoCallbacks?
    
    // One of the value from here containing the actual playable media in avassets
    // Read more: https://developer.apple.com/documentation/avfoundation/avasset?language=objc
    private let assetValueKey = "playable"
    
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Load asset for given url
    /// - Parameters:
    ///   - url: URL to load asset from
    ///   - completion: completion called once the media is been loaded
    private func loadAsset(with url: URL, completion: @escaping (_ asset: AVAsset) -> Void) {
        // Added otherwise video sound would be silenced by system in case of silent mode is enabled
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                self.logInfo("Successfully loaded media from url %{PUBLIC}@", url.absoluteString)
                completion(asset)
            case .failed:
                self.logError("Failed to load media from url %{PUBLIC}@", url.absoluteString)
            case .cancelled:
                self.logError("Media loading was cancelled for url %{PUBLIC}@", url.absoluteString)
            default:
                self.logError("Undefined status observed while loading for url %{PUBLIC}@", url.absoluteString)
            }
        }
    }
    
    /// Updates the current player item to reflect new media asset
    /// - Parameter asset: asset to update/play
    private func updatePlayerItem(with asset: AVAsset, startTime: CMTime?) {
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        DispatchQueue.main.async { [weak self] in
            self?.player = AVPlayer(playerItem: self?.playerItem!)
            if let startTime = startTime {
                self?.player?.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }
    
    
    public func setCGVideoPlayerListener(delegate: CGVideoplayerListener){
        self.delegate = delegate
    }
    public func setCGVideoCallbacks(delegate: CGPiPMovieVideoCallbacks){
        self.videoListeners = delegate
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
            
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                self.logInfo("Ready to play media")
                playIfBehaviourAllowsOnLoad()
            case .failed:
                self.logError("Failed to play media")
            case .unknown:
                self.logError("Unknown status recieved while playing the media")
            @unknown default:
                self.logError("Unknown status recieved while playing the media")
            }
        }
    }
    
    private func playIfBehaviourAllowsOnLoad() {
        switch mediaPlayingBehaviour {
        case .autoPlayOnLoad:
            self.checkVideoTime()
            player?.play()
            isPlayerMuted() ? self.mute() : unmute()
            if let delegate = self.delegate {
                delegate.showPlayerCTA()
            }
        case .playOnDemand:
            break
        }
    }
    
    private func setPrefferedScreenTimeBehaviour() {
        switch screenTimeBehaviour {
        case .keepSystemIdleBehaviour:
            UIApplication.shared.isIdleTimerDisabled = false
        case .preventFromIdle:
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    
    public func addAppStateObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    public func removeAppStateObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appMovedToBackground() {
        isMoveToForeground = false
        player?.pause()
        try? AVAudioSession.sharedInstance().setActive(false)
        print("App moved to background. Player paused. Mute state: %{PUBLIC}@", String(describing: isMuted))

    }
    
    @objc private func appMovedToForeground() {
        if !isMoveToForeground{
            isMoveToForeground = false
            
            print("App moved to foreground. Player state paused: %{PUBLIC}@, Mute state: %{PUBLIC}@", String(describing: isPaused), String(describing: isMuted))
            try? AVAudioSession.sharedInstance().setActive(true)
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            if !isPaused {
                self.checkVideoTime()
                player?.play()
                player?.isMuted = isMuted
                print("App moved Player resumed. Current Mute state: %{PUBLIC}@", String(describing: player?.isMuted))
                
            }
        }
    }
    
    /// Starts loading the media associated with given url, and optinally plays it once loaded
    /// - Parameters:
    ///   - url: URL of media file
    ///   - behaviour: Media behaviour that controlls the plyaback on load.
    public func play(
        with url: URL,
        startTime: CMTime? = nil,
        behaviour: CGMediaPlayingBehaviour = .autoPlayOnLoad,
        screenTimeBehaviour: CGMediaPlayerScreenTimeBehaviour = .preventFromIdle
    ) {
        self.setupPlayerLooping()
        self.checkVideoTime()
        self.mediaPlayingBehaviour = behaviour
        self.screenTimeBehaviour = screenTimeBehaviour
        loadAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.updatePlayerItem(with: asset, startTime: startTime)
        }
    }
    
    /// Starts loading the media associated with given url, and optinally plays it once loaded
    /// - Parameters:
    ///   - url: URL of media file
    ///   - behaviour: Media behaviour that controlls the plyaback on load.
    public func play(
        with filePath: String,
        startTime: CMTime? = nil,
        behaviour: CGMediaPlayingBehaviour = .autoPlayOnLoad,
        screenTimeBehaviour: CGMediaPlayerScreenTimeBehaviour = .preventFromIdle
    ) {
        
        self.setupPlayerLooping()
        self.checkVideoTime()

        self.mediaPlayingBehaviour = behaviour
        self.screenTimeBehaviour = screenTimeBehaviour
        let url = URL(fileURLWithPath: filePath)
        loadAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.updatePlayerItem(with: asset, startTime: startTime)
        }
        self.isPaused = false
    }
    
    /// Starts loading the media associated with given url, and optinally plays it once loaded
    /// - Parameters:
    ///   - url: URL of media file
    ///   - behaviour: Media behaviour that controlls the plyaback on load.
    public func play(
        bundleResource resource: String,
        withExtension extension: String?,
        startTime: CMTime? = nil,
        bundle: Bundle = .main,
        behaviour: CGMediaPlayingBehaviour = .autoPlayOnLoad,
        screenTimeBehaviour: CGMediaPlayerScreenTimeBehaviour = .preventFromIdle
    ) {
        guard let url = bundle.url(forResource: resource, withExtension: `extension`) else {
            logError("Unable to locate %{PUBLIC}@ with extension %{PUBLIC}@ in bundle", resource, (`extension` ?? "N/A"))
            return
        }
        self.setupPlayerLooping()
        self.checkVideoTime()
        self.mediaPlayingBehaviour = behaviour
        self.screenTimeBehaviour = screenTimeBehaviour
        loadAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.updatePlayerItem(with: asset, startTime: startTime)
        }
        self.isPaused = false
    }
    
    
    public func setupPlayerLooping(){
        player?.actionAtItemEnd = .none

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    
    // Handle Looping of video - Notification logic
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            if let delegate = self.videoListeners{
                delegate.onVideoCompleted()
            }
            if self.shouldVideoLoop {
                CGPIPHelper.shared.setIs25Completed(value:false)
                CGPIPHelper.shared.setIs50Completed(value:false)
                CGPIPHelper.shared.setIs75Completed(value:false)
               
                playerItem.seek(to: CMTime.zero, completionHandler: nil)
                if let player = self.player {
                    player.play()
                }
                isPlayerMuted() ? self.mute() : self.unmute()
            }else {
                guard let firstVideoTrack = player?.currentItem?.asset.tracks(withMediaType: .video).first else {
                  return
                }
                    
//                let duration = firstVideoTrack.timeRange.duration
//                player?.seek(to: duration, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }
 
    @objc func checkVideoTime(){
        player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            
            let duration = CMTimeGetSeconds(self.player?.currentItem?.duration ?? CMTime.zero)
            let currentTime = CMTimeGetSeconds(time)
            
            // Check if video is 50% completed
            if !CGPIPHelper.shared.is25Completd {
                if currentTime >= duration * 0.25 {
                    
                    print("Video is 25% completed")
                    if let delegate = self.videoListeners{
                        delegate.onVideo25Completed()
                    }
                    CGPIPHelper.shared.setIs25Completed(value: true)
                    
                }
            }
            if !CGPIPHelper.shared.is50Completd {
                
                if currentTime >= duration * 0.5 {
                    print("Video is 50% completed")
                    if let delegate = self.videoListeners{
                        delegate.onVideo50Completed()
                    }
                    CGPIPHelper.shared.setIs50Completed(value: true)
                    
                    // Do something here when video reaches 50% completion
                }
            }
            
            if !CGPIPHelper.shared.is75Completd {
                if currentTime >= duration * 0.75 {
                    
                    print("Video is 75% completed")
                    if let delegate = self.videoListeners{
                        delegate.onVideo75Completed()
                    }
                    CGPIPHelper.shared.setIs75Completed(value: true)
                    
                }
            }
        }
    }

    
    public func unRegisterLooper(){
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    public func resume() {
        if let player = self.player {
            self.isPaused = false
            player.rate = 1.1
        }
    }
    
    public func pause() {
        if let player = self.player {
            self.isPaused = true
            player.pause()
        }
    }
    
    public func mute() {
        isMuted = true
        if let player = self.player {
            player.isMuted = true
        }
    }
    
    
    public func unmute() {
        isMuted = false
        if let player = self.player {
            player.isMuted = false
        }
    }

    public func isPlayerMuted() -> Bool {
        return isMuted
    }
    
    public func isPlayerPaused()-> Bool{
        return isPaused
    }
    
    public func setVideoShouldLoop(with shouldVideoLoop: Bool){
        self.shouldVideoLoop = shouldVideoLoop
    }
    
    
    
        
    
    //MARK: - Logging
    #if DEBUG
    private let log = OSLog(subsystem: "com.customerglu.CGVideoPlayer", category: "VideoPlayer")
    #endif

    private func logInfo(_ message: StaticString, _ args: CVarArg...) {
        #if DEBUG
        os_log(message, log: log, type: .info, args)
        #endif
    }

    private func logError(_ message: StaticString, _ args: CVarArg...) {
        #if DEBUG
        os_log(message, log: log, type: .error, args)
        #endif
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerItemContext)
    }
    
}
