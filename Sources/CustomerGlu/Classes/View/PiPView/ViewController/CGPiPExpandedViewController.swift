//
//  CGPiPViewController.swift
//  
//
//  Created by Kausthubh adhikari on 15/10/23.
//

import Foundation
import UIKit

class CGPiPExpandedViewController : UIViewController, CGPiPMoviePlayerProtocol {
   
 
    var pipInfo: CGData?
  
    @IBOutlet weak var expandedViewCTA: UIButton!
    @IBOutlet weak var movieView: CGPiPMoviePlayer!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    init(btnInfo: CGData) {
        super.init(nibName: nil, bundle: nil)
        pipInfo = btnInfo
    }
    override func loadView() {
        movieView.delegate = self
    }

    func onPiPCloseClicked() {
        dismiss(animated: true)
    }
    
    func onPiPExpandClicked() {
        dismiss(animated: true)
    }
    func onPiPPlayerClicked() {
    
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
                
            } else if type == WebViewsKey.open_weblink {
                
                // Hyperlink logic
                let nudgeConfiguration = CGNudgeConfiguration()
                nudgeConfiguration.layout = pipInfo?.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
                nudgeConfiguration.opacity = pipInfo?.mobile.conditions.backgroundOpacity ?? 0.5
                nudgeConfiguration.closeOnDeepLink = pipInfo?.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
                nudgeConfiguration.relativeHeight = pipInfo?.mobile.content[0].relativeHeight ?? 0.0
                nudgeConfiguration.absoluteHeight = pipInfo?.mobile.content[0].absoluteHeight ?? 0.0
                nudgeConfiguration.isHyperLink = true
                
                CustomerGlu.getInstance.openURLWithNudgeConfig(url: actionData.url, nudgeConfiguration: nudgeConfiguration)
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
                    
                    CustomerGlu.getInstance.openCampaignById(campaign_id: campaignId, nudgeConfiguration: nudgeConfiguration)
                } else {
                    //Incase Campaign Id is nil / unavailable
                    CustomerGlu.getInstance.openWallet()
                }
            }
        } else {
            
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = pipInfo?.mobile.content[0].openLayout.lowercased() ?? CGConstants.FULL_SCREEN_NOTIFICATION
            nudgeConfiguration.opacity = pipInfo?.mobile.conditions.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = pipInfo?.mobile.content[0].closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            nudgeConfiguration.relativeHeight = pipInfo?.mobile.content[0].relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = pipInfo?.mobile.content[0].absoluteHeight ?? 0.0
            
            CustomerGlu.getInstance.openCampaignById(campaign_id: (pipInfo?.mobile.content[0].campaignId)!, nudgeConfiguration: nudgeConfiguration)
        }
        
    }
    
}
