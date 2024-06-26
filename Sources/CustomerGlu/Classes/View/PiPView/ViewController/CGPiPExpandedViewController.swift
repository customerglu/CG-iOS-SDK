//
//  CGPiPViewController.swift
//  
//
//  Created by Kausthubh adhikari on 20/10/23.
//

import Foundation
import UIKit
import AVFoundation

class CGPiPExpandedViewController : UIViewController,CGPiPMovieVideoCallbacks {
   
    func onVideo25Completed() {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_25_COMPLETED, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: self.pipInfo?.name ?? "",content_campaign_id: self.pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
    }
    func onVideo75Completed() {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_75_COMPLETED, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: self.pipInfo?.name ?? "",content_campaign_id: self.pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
    }
    
    func onVideo50Completed() {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_50_COMPLETED, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: self.pipInfo?.name ?? "",content_campaign_id: self.pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
    }
    
    func onVideoCompleted() {
        CGPIPHelper.shared.setIs25Completed(value: false)
        CGPIPHelper.shared.setIs50Completed(value: false)
        CGPIPHelper.shared.setIs75Completed(value: false)
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_VIDEO_COMPLETED, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: self.pipInfo?.name ?? "",content_campaign_id: self.pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
    }
    
    
    var pipInfo: CGData?
    var startTime: CMTime?
    @IBOutlet weak var pipRedirectCTA: UIButton!
    @IBOutlet weak var expandedViewCTA: UIButton!
    @IBOutlet weak var playerContainer: UIView!
    var movieView: CGVideoPlayer?
    
    var screenHeight: CGFloat?
    var screenWidth: CGFloat?
    var isMuted: Bool = true
   
    
    lazy var closeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "ic_close", in: .module, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "ic_close", in: .module, compatibleWith: nil), for: .selected)
        return button
    }()
   
    lazy var muteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)
        return button
    }()
    
    lazy var expandButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "ic_collapse", in: .module, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "ic_collapse", in: .module, compatibleWith: nil), for: .selected)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        let screenRect = UIScreen.main.bounds
        screenWidth = screenRect.width
        screenHeight = screenRect.height
        setupVideoPlayer()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(notification:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(applicationDidBecomeActive(notification:)),
              name: UIApplication.didBecomeActiveNotification,
              object: nil)
      
        CustomerGlu.getInstance.setCurrentClassName(className: "CGSCreen")
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_ENTRY_POINT_LOAD, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: pipInfo?.name ?? "",content_campaign_id: pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
        
        
    }
    @objc func applicationWillResignActive(notification: NSNotification) {
        if  movieView?.isHidden == false && movieView?.superview != nil{
        
                movieView?.mute()
               // movieView?.pause()
            //movieView?.unRegisterLooper()
            
        }
    }
              
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        movieView?.player?.seek(to: CMTime.zero)
        CGPIPHelper.shared.setIs25Completed(value:false)
        CGPIPHelper.shared.setIs50Completed(value:false)
        CGPIPHelper.shared.setIs75Completed(value:false)
        if  movieView?.isHidden == false && movieView?.superview != nil{
           // movieView?.resume()
            if  CustomerGlu.isPIPExpandedViewMuted {
                movieView?.mute()
            }else{
                movieView?.unmute()
            }
//            (self.isMuted) ? movieView?.mute() : movieView?.unmute()

            muteButton.setImage( (movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
            muteButton.setImage( (movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)
            }
        }
              
    
    
    func setupVideoPlayer(){
        movieView = CGVideoPlayer()
        movieView?.setVideoShouldLoop(with: pipInfo?.mobile.conditions.pip?.loopVideoExpanded ?? false)
        movieView?.addAppStateObservers()
        self.view.addSubview(movieView!)
        
        movieView?.translatesAutoresizingMaskIntoConstraints = false
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints  = false
        movieView?.setCGVideoCallbacks(delegate: self)


        if let pipInfo = pipInfo, let cgButton = pipInfo.mobile.content[0].action.button{
            if let ctaText = cgButton.buttonText{
                
              //  pipRedirectCTA.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)

                pipRedirectCTA.setTitle(ctaText, for: .normal)
            }
            if let textColor = cgButton.buttonTextColor{
                pipRedirectCTA.setTitleColor(UIColor(hex: textColor), for: .normal)
            }
            if let buttonColor = cgButton.buttonColor{
                pipRedirectCTA.backgroundColor = UIColor(hex: buttonColor)
            }
        }
        
        movieView?.addSubview(muteButton)
        movieView?.addSubview(expandButton)
        movieView?.addSubview(closeButton)
        
        let moviePlayerWidth  = screenWidth
        let moviePlayerHeight = 1.78 * (moviePlayerWidth ?? 0)
        
        let margins = view.layoutMarginsGuide
       
        NSLayoutConstraint.activate( [
            movieView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            movieView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            movieView!.topAnchor.constraint(equalTo: margins.topAnchor),
            movieView!.widthAnchor.constraint(equalToConstant: CGFloat(moviePlayerWidth ?? 0)),
            movieView!.heightAnchor.constraint(equalToConstant: CGFloat(moviePlayerHeight)),
            closeButton.leadingAnchor.constraint(equalTo: movieView!.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: movieView!.topAnchor, constant: 16),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            muteButton.bottomAnchor.constraint(equalTo: movieView!.bottomAnchor, constant: -16),
            muteButton.trailingAnchor.constraint(equalTo: movieView!.trailingAnchor, constant: -16),
            muteButton.heightAnchor.constraint(equalToConstant: 36),
            muteButton.widthAnchor.constraint(equalToConstant: 36),
            expandButton.trailingAnchor.constraint(equalTo: movieView!.trailingAnchor, constant: -16),
            expandButton.topAnchor.constraint(equalTo: movieView!.topAnchor, constant: 16),
            expandButton.heightAnchor.constraint(equalToConstant: 36),
            expandButton.widthAnchor.constraint(equalToConstant: 36),
            expandedViewCTA.topAnchor.constraint(equalTo: movieView!.bottomAnchor, constant: 24),
            expandedViewCTA.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        muteButton.addTarget(self, action: #selector(didTapOnMute(_:)), for: .touchUpInside)
        expandButton.addTarget(self, action: #selector(didTapOnExpand(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapOnClose(_:)), for: .touchUpInside)
    //    movieView?.setVideoShouldLoop(with: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
            self.movieView?.play(with: CustomerGlu.getInstance.getPiPLocalPath(), startTime: self.startTime)
        })
    }
    
    
    
    @objc func didTapOnMute(_ buttton: UIButton){
        
            
            (self.movieView?.isPlayerMuted())! ? self.movieView?.unmute() : self.movieView?.mute()
            self.muteButton.setImage( (self.movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
            self.muteButton.setImage( (self.movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)
            if(self.movieView?.isPlayerMuted())! {
                CustomerGlu.isPIPExpandedViewMuted = true
            }
            else{
                CustomerGlu.isPIPExpandedViewMuted = false

            }
        

     }
    
    @objc func didTapOnExpand(_ buttton: UIButton){
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.COLLAPSE_PIP_VIDEO, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: self.pipInfo?.name ?? "",content_campaign_id: self.pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "false")
        let pipInfo = pipInfo!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            self.movieView?.player?.pause()
            let currentTime = self.movieView?.player?.currentTime()
            self.dismiss(animated: true) {
                CGPIPHelper.shared.setIs25Completed(value: false)
                CGPIPHelper.shared.setIs50Completed(value: false)
                CustomerGlu.getInstance.displayPiPFromCollapseCTA(with: pipInfo, startTime: CMTime.zero)
            }
                })
        }
     
    
    @objc func didTapOnClose(_ buttton: UIButton){
        CustomerGlu.pipDismissed = true
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_ENTRY_POINT_DISMISS, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: pipInfo?.name ?? "",content_campaign_id: pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            self.closePiPExpandedView()
        })
     }
    
    
    
    

    @IBAction func onPiPCTAClicked(_ sender: Any) {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_ENTRY_POINT_CTA_CLICK, entry_point_id: self.pipInfo?._id ?? "", entry_point_name: pipInfo?.name ?? "",content_campaign_id: pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
        if let actionData = pipInfo?.mobile.content[0].action, let type = actionData.type {
            
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
            
                
                closePiPExpandedView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: postdata)
                })
            } else if type == WebViewsKey.open_weblink {
                
                // Hyperlink logic
                let nudgeConfiguration = CGNudgeConfiguration()
                nudgeConfiguration.layout = pipInfo?.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
                nudgeConfiguration.opacity = pipInfo?.mobile.conditions.backgroundOpacity ?? 0.5
                nudgeConfiguration.closeOnDeepLink = pipInfo?.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
                nudgeConfiguration.relativeHeight = pipInfo?.mobile.content[0].relativeHeight ?? 0.0
                nudgeConfiguration.absoluteHeight = pipInfo?.mobile.content[0].absoluteHeight ?? 0.0
                nudgeConfiguration.isHyperLink = true
                
                closePiPExpandedView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                    CustomerGlu.getInstance.openURLWithNudgeConfig(url: actionData.url, nudgeConfiguration: nudgeConfiguration)
                })
            } else {
                //Incase of failure / API contract breach
                // Check to open wallet or not in fallback case
                let campaignId = pipInfo?.mobile.content[0].campaignId
                guard CustomerGlu.getInstance.checkToOpenWalletOrNot(withCampaignID: campaignId ?? "") else {
                    return
                }

                // Opening Campaign using CampaignId from payload
                if let campaignId = campaignId {
                    let nudgeConfiguration = CGNudgeConfiguration()
                    nudgeConfiguration.layout = pipInfo?.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
                    nudgeConfiguration.opacity = pipInfo?.mobile.conditions.backgroundOpacity ?? 0.5
                    nudgeConfiguration.closeOnDeepLink = pipInfo?.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
                    nudgeConfiguration.relativeHeight = pipInfo?.mobile.content[0].relativeHeight ?? 0.0
                    nudgeConfiguration.absoluteHeight = pipInfo?.mobile.content[0].absoluteHeight ?? 0.0
                    
                    closePiPExpandedView()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                        CustomerGlu.getInstance.openCampaignById(campaign_id: campaignId, nudgeConfiguration: nudgeConfiguration)
                    })
                    
                } else {
                    //Incase Campaign Id is nil / unavailable
                    closePiPExpandedView()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                        CustomerGlu.getInstance.openWallet()
                    })
                }
            }
        } else {
            
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = pipInfo?.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
            nudgeConfiguration.opacity = pipInfo?.mobile.conditions.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = pipInfo?.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            nudgeConfiguration.relativeHeight = pipInfo?.mobile.content[0].relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = pipInfo?.mobile.content[0].absoluteHeight ?? 0.0
            
            closePiPExpandedView()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (self.pipInfo?.mobile.content[0].campaignId)!, nudgeConfiguration: nudgeConfiguration)
            })
        }
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (self.movieView != nil) {
            
            self.movieView?.pause()
            self.movieView?.mute()
            self.movieView?.unRegisterLooper()
            CustomerGlu.getInstance.activePIPView = nil
        }
    }
    
    
    func closePiPExpandedView(){
        if let movieView = self.movieView, !movieView.isPlayerPaused() {
            movieView.pause()
        }
        
//        CustomerGlu.getInstance.activePIPView = nil
        
        dismiss(animated: true)
    }
    
}
