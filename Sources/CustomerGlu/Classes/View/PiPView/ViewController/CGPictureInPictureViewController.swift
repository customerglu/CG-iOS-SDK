//
//  CGPictureInPictureViewController.swift
//  
//
//  Created by Kausthubh adhikari on 20/10/23.
//

import Foundation
import UIKit
import AVFoundation

class CGPictureInPictureViewController : UIViewController, CGVideoplayerListener,CGPiPMovieVideoCallbacks {
    
    func onVideo25Completed() {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_25_COMPLETED, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
    }
    func onVideo75Completed() {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_75_COMPLETED, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
    }
    
    
    func onVideo50Completed() {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_50_COMPLETED, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
    }
    
    func onVideoCompleted() {
        CGPIPHelper.shared.setIs25Completed(value: false)
        CGPIPHelper.shared.setIs50Completed(value: false)
        CGPIPHelper.shared.setIs75Completed(value: false)

        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_COMPLETED, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
    }
    
   
    let pipInfo: CGData
    let startTime: CMTime?
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
    init(btnInfo: CGData, startTime: CMTime? = nil) {
        pipInfo = btnInfo
        self.startTime = startTime
        pipMediaPlayer = CGVideoPlayer()
        super.init(nibName: nil, bundle: nil)
        
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = true
        window.rootViewController = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if (self.window != nil && self.pipMediaPlayer != nil) {
            
            self.window.dismiss()
            self.pipMediaPlayer.cleanUp()
            self.pipMediaPlayer.pause()
            self.pipMediaPlayer.unRegisterLooper()
            CustomerGlu.getInstance.activePIPView = nil
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
            if let pipIsMute = self.pipInfo.mobile.conditions.pip?.muteOnDefaultPIP, pipIsMute {
                pipMediaPlayer.mute()
                muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
            }else {
                muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
                pipMediaPlayer.unmute()
            }
            pipMediaPlayer.play(with: CustomerGlu.getInstance.getPiPLocalPath(), startTime: self.startTime)
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
        
        
        if let horizontalPadding = Int(pipInfo.mobile.container.horizontal_padding ?? "0"), horizontalPadding > 0{
            CustomerGlu.horizontalPadding = horizontalPadding
        }
        
        if let verticalPadding = Int(pipInfo.mobile.container.vertical_padding ?? "0"), verticalPadding > 0 {
            CustomerGlu.verticalPadding = verticalPadding
        }
        
        
        let bottomSpace = CustomerGlu.verticalPadding
        let sideSpace = Int(CustomerGlu.horizontalPadding)
        let topSpace = Int(CustomerGlu.verticalPadding)
        
        pipMediaPlayer.setCGVideoPlayerListener(delegate: self)
        pipMediaPlayer.setCGVideoCallbacks(delegate: self)
        
        pipMediaPlayer.setVideoShouldLoop(with: pipInfo.mobile.conditions.pip?.loopVideoPIP ?? true)
        
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
        
//        NotificationCenter.default.addObserver(
//              self,
//              selector: #selector(applicationDidBecomeActive(notification:)),
//              name: UIApplication.didBecomeActiveNotification,
//              object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(notification:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        setupPiPCTAs()
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
      //  if  pipMediaPlayer.isHidden == false && pipMediaPlayer.superview != nil{
            pipMediaPlayer.player?.seek(to: CMTime.zero)
        //}
    }

    
       
//    @objc func applicationDidBecomeActive(notification: NSNotification) {
//        if  pipMediaPlayer.isHidden == false && pipMediaPlayer.superview != nil{
//            pipMediaPlayer.resume()
//        }
//    }
    
    
    public func setupPiPCTAs(){
        hidePiPCTAs()
        muteButton.frame = CGRect(x: pipMediaPlayer.frame.width - (22 + 8) ,y:pipMediaPlayer.frame.size.height - (22 + 8) ,width:22,height:22)
        closeButton.frame = CGRect(x: 8 ,y:8,width:22,height:22)
        expandButton.frame = CGRect(x: pipMediaPlayer.frame.width - (22 + 8 ) ,y:8,width:22,height:22)
      
        pipMediaPlayer.addSubview(muteButton)
        pipMediaPlayer.addSubview(expandButton)
        pipMediaPlayer.addSubview(closeButton)
        
        let muteTapped = UITapGestureRecognizer(target: self, action: #selector(didTapOnMute))
        let expandTapped = UITapGestureRecognizer(target: self, action: #selector(didTapOnExpand))
        let closeTapped = UITapGestureRecognizer(target: self, action: #selector(didTapOnClose))
        
        muteButton.addGestureRecognizer(muteTapped)
        expandButton.addGestureRecognizer(expandTapped)
        closeButton.addGestureRecognizer(closeTapped)
    
       
    }
    
    @objc func didTapOnMediaPlayer(){
        if ((pipInfo.mobile.conditions.pip?.openExpandedView) != nil && pipInfo.mobile.conditions.pip?.openExpandedView == true){
            launchPiPExpandedView()
       }else{
            performCTAAction()
           dismissPiPButton(shouldCallEvent: true)
       }
     }
    
    func performCTAAction(){
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_ENTRY_POINT_CTA_CLICK, entry_point_id: self.pipInfo._id ?? "", entry_point_name: pipInfo.name ?? "",content_campaign_id: pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
        if let actionData = pipInfo.mobile.content[0].action, let type = actionData.type {
            
            if type == WebViewsKey.open_deeplink {
                
               
                
                //Incase of Handled by CG is true
                if actionData.isHandledBySDK == true {
                    guard let url = URL(string: "http://assets.customerglu.com/deeplink-redirect/?redirect=\(actionData.url)" as! String) else { return }
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                
                // Converted data for NSNotification.
                var data: [String: Any]
                var postdata: [String:Any] = ["eventName":WebViewsKey.open_deeplink,
                                              "data": ["deepLink": actionData.url]]
            
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: postdata)
                })
            } else if type == WebViewsKey.open_weblink {
                
                // Hyperlink logic
                let nudgeConfiguration = CGNudgeConfiguration()
                nudgeConfiguration.layout = pipInfo.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
                nudgeConfiguration.opacity = pipInfo.mobile.conditions.backgroundOpacity ?? 0.5
                nudgeConfiguration.closeOnDeepLink = pipInfo.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
                nudgeConfiguration.relativeHeight = pipInfo.mobile.content[0].relativeHeight ?? 0.0
                nudgeConfiguration.absoluteHeight = pipInfo.mobile.content[0].absoluteHeight ?? 0.0
                nudgeConfiguration.isHyperLink = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    CustomerGlu.getInstance.openURLWithNudgeConfig(url: actionData.url, nudgeConfiguration: nudgeConfiguration)
                })
            } else {
                //Incase of failure / API contract breach
                // Check to open wallet or not in fallback case
                let campaignId = pipInfo.mobile.content[0].campaignId
                guard CustomerGlu.getInstance.checkToOpenWalletOrNot(withCampaignID: campaignId ?? "") else {
                    return
                }

                // Opening Campaign using CampaignId from payload
                if let campaignId = campaignId {
                    let nudgeConfiguration = CGNudgeConfiguration()
                    nudgeConfiguration.layout = pipInfo.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
                    nudgeConfiguration.opacity = pipInfo.mobile.conditions.backgroundOpacity ?? 0.5
                    nudgeConfiguration.closeOnDeepLink = pipInfo.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
                    nudgeConfiguration.relativeHeight = pipInfo.mobile.content[0].relativeHeight ?? 0.0
                    nudgeConfiguration.absoluteHeight = pipInfo.mobile.content[0].absoluteHeight ?? 0.0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                        CustomerGlu.getInstance.openCampaignById(campaign_id: campaignId, nudgeConfiguration: nudgeConfiguration)
                    })
                  
                   
                    
                } else {
                    //Incase Campaign Id is nil / unavailable
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                        CustomerGlu.getInstance.openWallet()
                    })
                }
            }
        } else {
            
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = pipInfo.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
            nudgeConfiguration.opacity = pipInfo.mobile.conditions.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = pipInfo.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            nudgeConfiguration.relativeHeight = pipInfo.mobile.content[0].relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = pipInfo.mobile.content[0].absoluteHeight ?? 0.0
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (self.pipInfo.mobile.content[0].campaignId)!, nudgeConfiguration: nudgeConfiguration)
            })
        }
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
       
            self.pipMediaPlayer.isPlayerMuted() ? self.pipMediaPlayer.unmute() : self.pipMediaPlayer.mute()
        
        
        if pipMediaPlayer.isPlayerMuted(){
            CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.UNMUTE_PIP_VIDEO, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
        }else{
            CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.MUTE_PIP_VIDEO, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
        }
        
        muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
        muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)
     }
    
    @objc func didTapOnExpand(){
            self.launchPiPExpandedView()
     }
    
    @objc func didTapOnClose(){
        CustomerGlu.pipDismissed = true
        
        self.dismissPiPButton(shouldCallEvent: true)
        
    }
    
    func launchPiPExpandedView(){
        let pipInfo = self.pipInfo
        self.pipMediaPlayer.mute()
        muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
        muteButton.setImage( pipMediaPlayer.isPlayerMuted() ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)

        DispatchQueue.global(qos: .utility).async {
            CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.EXPAND_PIP_VIDEO, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
            CGPIPHelper.shared.setIs25Completed(value: false)
            CGPIPHelper.shared.setIs50Completed(value: false)
            CGPIPHelper.shared.setIs75Completed(value: false)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.dismissPiPButton()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            
            CustomerGlu.getInstance.showExpandedPiP(pipInfo: pipInfo, currentTime: CMTime.zero)
        })
    }
    
    
    public func dismissPiPButton(shouldCallEvent: Bool = false) {
    //    if CustomerGlu.getInstance.activePIPView != nil {
        
                self.window.dismiss()
                self.pipMediaPlayer.pause()
                self.pipMediaPlayer.unRegisterLooper()
                CustomerGlu.getInstance.activePIPView = nil
                
            if shouldCallEvent {
                DispatchQueue.global(qos: .utility).async {
                    
                    CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_ENTRY_POINT_DISMISS, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
                }
            }
    //    }
    }

    func showPlayerCTA() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
            self.showPiPCTAs()
        })
            CGPIPHelper.shared.setDailyRefresh()
            if (!CustomerGlu.getInstance.isPiPViewLoadedEventPushed) {
                CustomerGlu.getInstance.isPiPViewLoadedEventPushed = true
                CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_ENTRY_POINT_LOAD, entry_point_id: self.pipInfo._id ?? "", entry_point_name: self.pipInfo.name ?? "",content_campaign_id: self.pipInfo.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
            }
        
    }
    
    public func hidePiPButton(ishidden: Bool) {
        OtherUtils.shared.createAndWriteToFile(content:"hidePiPButton start")
        window.pipMoviePlayer?.isHidden = ishidden
        self.pipMediaPlayer.isHidden = ishidden
        window.isHidden = ishidden
        window.isUserInteractionEnabled = !ishidden
        if ishidden {
            OtherUtils.shared.createAndWriteToFile(content:"hidePiPButton hide")
            self.pipMediaPlayer.pause()
            self.pipMediaPlayer.removeAppStateObservers()
        }else{
            OtherUtils.shared.createAndWriteToFile(content:"hidePiPButton show")

//            var path = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_PIP_PATH)
//            self.pipMediaPlayer.play(with: path)
            self.pipMediaPlayer.resume()
            self.pipMediaPlayer.addAppStateObservers()
        }
        self.pipMediaPlayer.isUserInteractionEnabled = !ishidden
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        

        
        if let pipMediSuperView  = pipMediaPlayer.superview {
            let point: CGPoint = sender.location(in: pipMediSuperView)
            let boundsRect = CGRect(x: pipMediSuperView.bounds.origin.x - 50 , y: pipMediSuperView.bounds.origin.y - 50, width: pipMediSuperView.frame.width , height: pipMediSuperView.frame.height)

            // Convert to parent's coordinate system
    //       let rect = pipMediaPlayer.convert(self.pipMediaPlayer.bounds, to: self.view)
//            CGRectContainsRect(boundsRect, rect)

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
