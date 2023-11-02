//
//  File.swift
//  
//
//  Created by Kausthubh adhikari on 19/10/23.
//

import Foundation
import AVFoundation
import UIKit

public protocol CGPiPMoviePlayerProtocol: NSObject {
    func onPiPCloseClicked()
    func onPiPExpandClicked()
    func onPiPPlayerClicked()
}

class CGPiPMoviePlayer : UIView {
    
    public enum PiPType: Int {
       case compactPlayer = 1002
       case normalPlayer = 1001
    }
        
    var player: AVPlayer?
    var closeCTA:  UIImageView?
    var muteCTA: UIImageView?
    var expandCTA: UIImageView?
    var delegate: CGPiPMoviePlayerProtocol?
    var playerVideoLayer: CALayer?
    var pipType: PiPType = PiPType.normalPlayer
    

    convenience init(pipType: PiPType){
        self.init(frame: CGRect.zero)
        self.pipType = pipType
        setupMoviePlayer(data: Data())
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMoviePlayer(data: Data())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFrame(){
        playerVideoLayer?.frame = self.bounds
    }
    
    
    override func layoutSublayers(of layer: CALayer) {
      super.layoutSublayers(of: layer)
        playerVideoLayer?.frame = self.bounds
    }
    
    
    // Setup Movie Player with Video in Data format
    func setupMoviePlayer(data: Data){
        backgroundColor = .black
        
        let videoPath = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_PIP_PATH)
        
        let videoPathURL = URL(fileURLWithPath: videoPath)
        
        self.player = AVPlayer(url: videoPathURL)
        playerVideoLayer = AVPlayerLayer(player: player)
        
        self.playerVideoLayer?.frame = self.bounds
    
        self.layer.addSublayer(playerVideoLayer!)
        self.player?.play()
        
        setupPiPMoviePlayerCTAs()
    }
    
    //Setup Movie
    func setupPiPMoviePlayerCTAs(){
        
        //Setup player click listener
        let pipPlayerTap = UITapGestureRecognizer(target: self, action: #selector(self.onPiPPlayerTapped(_:)))
        self.addGestureRecognizer(pipPlayerTap)
        
        let ctaDimensions = 24
        
        
        // Setup the Close CTA
        
        
        if closeCTA == nil {
            closeCTA = UIImageView(frame: CGRect(x: 0, y: 0, width: ctaDimensions, height: ctaDimensions))
            closeCTA?.image = UIImage(named: "ic_close.png")
            self.addSubview(closeCTA!)
            
            closeCTA?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
            closeCTA?.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
            
            let closeTap = UITapGestureRecognizer(target: self, action: #selector(self.closeTapped(_:)))
            closeCTA?.addGestureRecognizer(closeTap)
        }
        
        
        //Setup the Expand CTA
        
        if expandCTA == nil {
            expandCTA = UIImageView(frame: CGRect(x: 0, y: 0, width: ctaDimensions, height: ctaDimensions))
            expandCTA?.image = UIImage(named: "ic_expand.png")
            self.addSubview(expandCTA!)
            
            expandCTA?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 16.0).isActive = true
            expandCTA?.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
            
            let expandTap = UITapGestureRecognizer(target: self, action: #selector(self.expandTapped(_:)))
            expandCTA?.addGestureRecognizer(expandTap)
        }
        
        
        
        //Setup the Mute / UnMute CTA
        
        if muteCTA == nil {
            muteCTA = UIImageView(frame: CGRect(x: 0, y: 0, width: ctaDimensions, height: ctaDimensions))
            muteCTA?.image = UIImage(named: "ic_mute.png")
            self.addSubview(muteCTA!)
            
            
//            if let muteLeadingConstraint = muteCTA?.rightAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0){
//                muteCTA?.addConstraint(muteLeadingConstraint)
//            }
//
//            if let muteBottomConstraint = muteCTA?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 16.0){
//                muteCTA?.addConstraint(muteBottomConstraint)
//            }
        
            let muteTap = UITapGestureRecognizer(target: self, action: #selector(self.muteTapped(_:)))
            muteCTA?.addGestureRecognizer(muteTap)
        }
        
    }
    
    
    @objc func closeTapped(_ sender: UITapGestureRecognizer? = nil) {
        self.removeFromSuperview()
    }
    
    
    @objc func expandTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let delegate = self.delegate {
            delegate.onPiPExpandClicked()
        }
    }
    
    @objc func muteTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let delegate = self.delegate {
            muteCTA?.image = UIImage(named: isPiPVideoMute() ?  "ic_unmute.png" : "ic_mute.png")
            isPiPVideoMute() ? unMuteVideo() : muteVideo()
        }
    }
    
    @objc func onPiPPlayerTapped(_ sender: UITapGestureRecognizer? = nil){
        if let delegate = self.delegate {
            delegate.onPiPPlayerClicked()
        }
    }
    
    
    // Play Video
    func playPiPVideo(){
        if let player = player {
            player.play()
        }
    }
    
    
    
    // Pause Video
    func stopPiPVideo(){
        if let player = player {
            player.pause()
        }
    }
    
    
    // Mute Player
    func muteVideo(){
        if let player = player {
            player.isMuted = true
        }
    }
    
    
    func isPiPVideoMute()-> Bool {
        if let player = player {
            return player.isMuted
        }
        return false
    }
    
    
    // Unmute Player
    func unMuteVideo(){
        if let player = player {
            player.isMuted = false
        }
    }
    
    
    //Seek Video to current time.
    func seekPiPVideoTo(timeSeek: CMTime){
        if let player = player {
            player.seek(to: timeSeek)
        }
    }
    
    
    // Get Video Current frame
    func getPiPVideoCurrentFrame() -> CMTime {
        var currentime = CMTime()
        
        if let player = player {
           currentime = player.currentTime()
        }
        
        return currentime
    }
}

 
