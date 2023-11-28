//
//  CGPiPViewController.swift
//  
//
//  Created by Kausthubh adhikari on 20/10/23.
//

import Foundation
import UIKit
import AVFoundation

class CGPiPExpandedViewController : UIViewController {
   
    var pipInfo: CGData?
    var startTime: CMTime?
    @IBOutlet weak var pipRedirectCTA: UIButton!
    @IBOutlet weak var expandedViewCTA: UIButton!
    @IBOutlet weak var playerContainer: UIView!
    var movieView: CGVideoPlayer?
    
    var screenHeight: CGFloat?
    var screenWidth: CGFloat?
   
    
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
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.ENTRY_POINT_LOAD, entry_point_id: pipInfo?.mobile._id ?? "", entry_point_name: pipInfo?.name ?? "",content_campaign_id: pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
        
    }
    
    
    
    func setupVideoPlayer(){
        movieView = CGVideoPlayer()
        movieView?.addAppStateObservers()
        self.view.addSubview(movieView!)
        
        movieView?.translatesAutoresizingMaskIntoConstraints = false
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints  = false
        
        if let pipInfo = pipInfo, let cgButton = pipInfo.mobile.content[0].action.button{
            if let ctaText = cgButton.buttonText{
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
        movieView?.setVideoShouldLoop(with: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
            self.movieView?.play(with: CustomerGlu.getInstance.getPiPLocalPath(), startTime: self.startTime)
        })
    }
    
    
    
    @objc func didTapOnMute(_ buttton: UIButton){
        (movieView?.isPlayerMuted())! ? movieView?.unmute() : movieView?.mute()
        muteButton.setImage( (movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
        muteButton.setImage( (movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)
     }
    
    @objc func didTapOnExpand(_ buttton: UIButton){
        let pipInfo = pipInfo!
        movieView?.player?.pause()
        let currentTime = movieView?.player?.currentTime()
        dismiss(animated: true) {
            CustomerGlu.getInstance.displayPiPFromCollapseCTA(with: pipInfo, startTime: currentTime)
        }
     }
    
    @objc func didTapOnClose(_ buttton: UIButton){
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.ENTRY_POINT_DISMISS, entry_point_id: pipInfo?.mobile._id ?? "", entry_point_name: pipInfo?.name ?? "",content_campaign_id: pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
        dismiss(animated: true)
     }
    
    
    
    

    @IBAction func onPiPCTAClicked(_ sender: Any) {
        CustomerGlu.getInstance.postAnalyticsEventForPIP(event_name: CGConstants.PIP_ENTRY_POINT_CTA_CLICK, entry_point_id: pipInfo?.mobile._id ?? "", entry_point_name: pipInfo?.name ?? "",content_campaign_id: pipInfo?.mobile.content[0].campaignId ?? "",entry_point_is_expanded: "true")
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
    
    
    func closePiPExpandedView(){
        if let movieView = self.movieView, !movieView.isPlayerPaused() {
            movieView.pause()
        }
        
        CustomerGlu.getInstance.activePIPView = nil
        
        dismiss(animated: true)
    }
    
}
