//
//  CGPictureInPictureViewController.swift
//  
//
//  Created by Kausthubh adhikari on 20/10/23.
//

import Foundation
import UIKit

class CGPictureInPictureViewController : UIViewController, CGVideoplayerListener {
   
    let pipInfo: CGData
    private(set) var pipMediaPlayer: CGVideoPlayer
    private var window = PiPWindow()
    
    // CTA Buttons
    lazy var closeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "ic_close", in: .module, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "ic_close", in: .module, compatibleWith: nil), for: .selected)
        return button
    }()
   
    lazy var muteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "ic_mute", in: .module, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "ic_mute", in: .module, compatibleWith: nil), for: .selected)
        return button
    }()
    
    lazy var expandButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "ic_expand", in: .module, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "ic_expand", in: .module, compatibleWith: nil), for: .selected)
        return button
    }()

    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    // Initialising PIP implementation
    init(btnInfo: CGData) {
        pipInfo = btnInfo
        pipMediaPlayer = CGVideoPlayer()
        super.init(nibName: nil, bundle: nil)
        
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = true
        window.rootViewController = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
            if let pipIsMute = self.pipInfo.mobile.conditions.pip?.muteOnDefaultPIP, pipIsMute {
                pipMediaPlayer.mute()
            }
            pipMediaPlayer.play(with: CustomerGlu.getInstance.getPiPLocalPath())
            if pipMediaPlayer.isPlayerPaused(){
                pipMediaPlayer.resume()
            }
        })
    }
    
    
    override func viewDidLoad() {
        let view = UIView()
        
        let screenRect = UIScreen.main.bounds
        var screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        screenWidth = screenWidth * 0.35
        let widthPer  = screenWidth
        let heightPer = 1.78 * screenWidth
        
        
        let bottomSpace = CustomerGlu.verticalPadding
        let sideSpace = Int(CustomerGlu.horizontalPadding)
        let topSpace = Int(CustomerGlu.verticalPadding)
        
        pipMediaPlayer.setCGVideoPlayerListener(delegate: self)
        pipMediaPlayer.setVideoShouldLoop(with: true)
        
        let pipMoviePlayerHeight = Int(heightPer)
        let pipMoviePlayerWidth = Int(widthPer)
        
        if pipInfo.mobile.container.position == "BOTTOM-LEFT" {
            pipMediaPlayer.frame = CGRect(x: sideSpace, y: Int(screenHeight - (CGFloat(pipMoviePlayerHeight) + CGFloat(bottomSpace))), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo.mobile.container.position == "BOTTOM-RIGHT" {
            pipMediaPlayer.frame = CGRect(x: Int(screenRect.size.width - (CGFloat(pipMoviePlayerWidth) + CGFloat(sideSpace))), y: Int(screenHeight - (CGFloat(pipMoviePlayerHeight) + CGFloat(bottomSpace))), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        }  else if pipInfo.mobile.container.position == "TOP-LEFT" {
            pipMediaPlayer.frame = CGRect(x: sideSpace, y: topSpace, width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else if pipInfo.mobile.container.position == "TOP-RIGHT" {
            pipMediaPlayer.frame = CGRect(x: Int(screenRect.size.width - (CGFloat(pipMoviePlayerWidth) + CGFloat(sideSpace))), y: topSpace, width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        } else {
            pipMediaPlayer.frame = CGRect(x: sideSpace, y: Int(screenHeight - (CGFloat(pipMoviePlayerHeight) + CGFloat(bottomSpace))), width: pipMoviePlayerWidth, height: pipMoviePlayerHeight)
        }
                
        pipMediaPlayer.layer.cornerRadius = 16.0
        pipMediaPlayer.clipsToBounds = true
        pipMediaPlayer.layer.masksToBounds = true
        self.view = view
        view.addSubview(pipMediaPlayer)
        window.pipMoviePlayer = pipMediaPlayer
        
        if(pipInfo.mobile.conditions.draggable == true){
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
            pipMediaPlayer.addGestureRecognizer(panGesture)
        }else{
            let pipMediaPlayerTapped = UITapGestureRecognizer(target: self, action: #selector(didTapOnMediaPlayer))
            pipMediaPlayer.addGestureRecognizer(pipMediaPlayerTapped)
        }
        
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(applicationDidBecomeActive(notification:)),
              name: UIApplication.didBecomeActiveNotification,
              object: nil)
        
        setupPiPCTAs()
    }
    
       
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        if  pipMediaPlayer.isHidden == false && pipMediaPlayer.superview != nil{
            pipMediaPlayer.resume()
        }
    }
    
    
    public func setupPiPCTAs(){
        muteButton.frame = CGRect(x: pipMediaPlayer.frame.width - (22 + 8) ,y:pipMediaPlayer.frame.size.height - (22 + 8) ,width:22,height:22)
        closeButton.frame = CGRect(x: 8 ,y:8,width:22,height:22)
        expandButton.frame = CGRect(x: pipMediaPlayer.frame.width - (22 + 8 ) ,y:8,width:22,height:22)
        
        
        self.muteButton.isHidden = true
        self.expandButton.isHidden = true
        self.closeButton.isHidden = true
        
        pipMediaPlayer.addSubview(muteButton)
        pipMediaPlayer.addSubview(expandButton)
        pipMediaPlayer.addSubview(closeButton)
        
        let muteTapped = UITapGestureRecognizer(target: self, action: #selector(didTapOnMute))
        let expandTapped = UITapGestureRecognizer(target: self, action: #selector(didTapOnExpand))
        let closeTapped = UITapGestureRecognizer(target: self, action: #selector(didTapOnClose))
        
        muteButton.addGestureRecognizer(muteTapped)
        expandButton.addGestureRecognizer(expandTapped)
        closeButton.addGestureRecognizer(closeTapped)
    
        hidePiPCTAs()
    }
    
    @objc func didTapOnMediaPlayer(){
         launchPiPExpandedView()
     }


    func hidePiPCTAs(){
        muteButton.isHidden = true
        expandButton.isHidden = true
        closeButton.isHidden = true
    }
    
    
    func showPiPCTAs(){
        expandButton.isHidden = false
        muteButton.isHidden = false
        closeButton.isHidden = false
    }
    
    
    @objc func didTapOnMute(){
        pipMediaPlayer.isPlayerMuted() ? pipMediaPlayer.unmute() : pipMediaPlayer.mute()
        muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
        muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)
     }
    
    @objc func didTapOnExpand(){
        launchPiPExpandedView()
     }
    
    @objc func didTapOnClose(){
        self.dismissPiPButton(is_remove: true)
    }
    
    func launchPiPExpandedView(){
        dismissPiPButton(is_remove: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let clientTestingVC = StoryboardType.main.instantiate(vcType: CGPiPExpandedViewController.self)
            clientTestingVC.pipInfo = self.pipInfo
            guard let topController = UIViewController.topViewController() else {
                return
            }
            clientTestingVC.modalPresentationStyle = .fullScreen
            topController.present(clientTestingVC, animated: true, completion: nil)
        })
    
    }
    
    
    public func dismissPiPButton(is_remove: Bool){
        if CustomerGlu.getInstance.arrPIPViews.contains(self) {
            if let index = CustomerGlu.getInstance.arrPIPViews.firstIndex(where: {$0 === self}) {
                CustomerGlu.getInstance.arrPIPViews.remove(at: index)
                pipMediaPlayer.pause()
                self.pipMediaPlayer.unRegisterLooper()
                self.window.dismiss()
            }
        }
    }

    func showPlayerCTA() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            self.showPiPCTAs()
            CGPIPHelper.shared.setDailyRefresh()
        })
    }
    
    public func hidePiPButton(ishidden: Bool) {
        window.pipMoviePlayer?.isHidden = ishidden
        self.pipMediaPlayer.isHidden = ishidden
        window.isHidden = ishidden
        window.isUserInteractionEnabled = !ishidden
        if ishidden {
            self.pipMediaPlayer.pause()
        }else{
            self.pipMediaPlayer.resume()
        }
        self.pipMediaPlayer.isUserInteractionEnabled = !ishidden
    }
    
    public func showPiPView(){
        window.pipMoviePlayer?.isHidden = false
        self.pipMediaPlayer.isHidden = false
        window.isUserInteractionEnabled = true
        self.pipMediaPlayer.pause()
        self.pipMediaPlayer.isUserInteractionEnabled = true
    }
    
    
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        
        if let pipMediSuperView  = pipMediaPlayer.superview {
            let point: CGPoint = sender.location(in: pipMediSuperView)
            let boundsRect = CGRect(x: pipMediSuperView.bounds.origin.x - 50 , y: pipMediSuperView.bounds.origin.y - 50, width: pipMediSuperView.frame.width , height: pipMediSuperView.frame.height)
            if boundsRect.contains(point) {
                pipMediaPlayer.center = point
            }
        }
    }
    
    
    @objc func keyboardDidShow(note: NSNotification) {
        window.windowLevel = UIWindow.Level(rawValue: 0)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }
    
}

private class PiPWindow: UIWindow {
    
    var pipMoviePlayer: CGVideoPlayer?
    
    init(){
        super.init(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            self.windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene)!
        }
        backgroundColor = .clear
        pipMoviePlayer?.backgroundColor = .black
        pipMoviePlayer?.layer.cornerRadius = 8
    }
    
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
        
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            guard let pipMoviePlayer = pipMoviePlayer else {
                return false
                
            }
            let pipMoviePoint = convert(point, to: pipMoviePlayer)
            return pipMoviePlayer.point(inside: pipMoviePoint, with: event)
    }
    
    
}
