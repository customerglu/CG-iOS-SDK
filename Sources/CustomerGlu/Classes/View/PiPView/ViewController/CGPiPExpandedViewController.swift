//
//  CGPiPViewController.swift
//  
//
//  Created by Kausthubh adhikari on 20/10/23.
//

import Foundation
import UIKit

class CGPiPExpandedViewController : UIViewController {
   
    var pipInfo: CGData?
  
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
       
    }
    
    
    
    func setupVideoPlayer(){
        movieView = CGVideoPlayer()
        self.view.addSubview(movieView!)
        
        movieView?.translatesAutoresizingMaskIntoConstraints = false
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints  = false
        
        
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
            self.movieView?.play(with: CustomerGlu.getInstance.getPiPLocalPath())
        })
    }
    
    
    
    @objc func didTapOnMute(_ buttton: UIButton){
        (movieView?.isPlayerMuted())! ? movieView?.unmute() : movieView?.mute()
        muteButton.setImage( (movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .normal)
        muteButton.setImage( (movieView?.isPlayerMuted())! ? UIImage(named: "ic_mute", in: .module, compatibleWith: nil) : UIImage(named: "ic_unmute", in: .module, compatibleWith: nil), for: .selected)
     }
    
    @objc func didTapOnExpand(_ buttton: UIButton){
        dismiss(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: { [self] in
            CustomerGlu.getInstance.displayPiPFromCollapseCTA(with: pipInfo!)
        })
     }
    
    @objc func didTapOnClose(_ buttton: UIButton){
        dismiss(animated: true)
     }
    
    
    
    

    @IBAction func onPiPCTAClicked(_ sender: Any) {
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
            
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CUSTOMERGLU_DEEPLINK_EVENT").rawValue), object: nil, userInfo: postdata)
                closePiPExpandedView()
                dismiss(animated: true)
                
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
                dismiss(animated: true)
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
                    self.dismiss(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                        CustomerGlu.getInstance.openCampaignById(campaign_id: campaignId, nudgeConfiguration: nudgeConfiguration)
                    })
                  
                   
                    
                } else {
                    //Incase Campaign Id is nil / unavailable
                    closePiPExpandedView()
                    dismiss(animated: true)
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
            dismiss(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                CustomerGlu.getInstance.openCampaignById(campaign_id: (self.pipInfo?.mobile.content[0].campaignId)!, nudgeConfiguration: nudgeConfiguration)
            })
        }
        
       
    }
    
    
    func closePiPExpandedView(){
        if let movieView = self.movieView, !movieView.isPlayerPaused() {
            movieView.pause()
        }
    }
    
}
