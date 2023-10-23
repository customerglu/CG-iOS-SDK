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
}

class CGPiPMoviePlayer : UIView {
        
    var player: AVPlayer?
    var closeCTA:  UIImageView?
    var muteCTA: UIImageView?
    var expandCTA: UIImageView?
    var delegate: CGPiPMoviePlayerProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMoviePlayer(data: Data())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // Setup Movie Player with Video in Data format
    func setupMoviePlayer(data: Data){
        backgroundColor = .black
        
        player = AVPlayer(url: data.convertToURL())
        let playerVideoLayer = AVPlayerLayer(player: player)
        
        self.layer.addSublayer(playerVideoLayer)
        playerVideoLayer.frame = self.frame
    }
    
    //Setup Movie
    func setupPiPMoviePlayerCTAs(){
        // Setup the Close CTA
        closeCTA = UIImageView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        closeCTA?.image = UIImage(named: "ic_close.png")
        self.addSubview(closeCTA!)
        
        closeCTA?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        closeCTA?.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(self.closeTapped(_:)))
        closeCTA?.addGestureRecognizer(closeTap)
        
        
        //Setup the Expand CTA
        expandCTA = UIImageView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        expandCTA?.image = UIImage(named: "ic_expand.png")
        self.addSubview(expandCTA!)
        
        expandCTA?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        expandCTA?.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        let expandTap = UITapGestureRecognizer(target: self, action: #selector(self.expandTapped(_:)))
        expandCTA?.addGestureRecognizer(expandTap)
        
        
        
        //Setup the Mute / UnMute CTA
        muteCTA = UIImageView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        muteCTA?.image = UIImage(named: "ic_mute.png")
        self.addSubview(muteCTA!)
        
        muteCTA?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        muteCTA?.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        
        let muteTap = UITapGestureRecognizer(target: self, action: #selector(self.muteTapped(_:)))
        muteCTA?.addGestureRecognizer(muteTap)
        
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

 
