//
//  File.swift
//
//
//  Created by kapil on 1/2/22.
//

import UIKit
import Foundation
import WebKit

public class BannerView: UIView, UIScrollViewDelegate {
    
    var view = UIView()
    var arrContent = [CGContent]()
    var condition : CGCondition?
    var timer : Timer?
    private var code = true
    var finalHeight = 0
    private var loadedapicalled = false
    
    
    @IBOutlet weak private var imgScrollView: UIScrollView!
    @IBOutlet weak private var pageControl: UIPageControl!
    
    @IBInspectable var bannerId: String? {
        didSet {
            backgroundColor = UIColor.clear
            CustomerGlu.getInstance.postBannersCount()
            callLoadBannerAnalytics()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.entryPointLoaded),
                name: Notification.Name("EntryPointLoaded"),
                object: nil)
        }
    }
    
    var commonBannerId: String {

            get {
                return self.bannerId ?? ""
            }
            set(newWeight) {
                bannerId = newWeight
            }
        }
    
    public init(frame: CGRect, bannerId: String) {
        //CODE
        super.init(frame: frame)
        self.commonBannerId = bannerId
        code = true
    }
    
    @objc private func entryPointLoaded(notification: NSNotification) {
        DispatchQueue.main.async {
            if self.imgScrollView != nil {
                self.imgScrollView.removeFromSuperview()
            }
            self.view.removeFromSuperview()
            self.xibSetup()
            self.callLoadBannerAnalytics()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // XIB
        super.init(coder: aDecoder)
        code = false
    }
    
    
    public override func layoutSubviews() {
        if imgScrollView != nil {
            imgScrollView.removeFromSuperview()
        }
        view.removeFromSuperview()
        xibSetup()
    }
    
    public override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: self.frame.size.width, height: CGFloat(finalHeight))
    }
    
    private func callLoadBannerAnalytics(){
        
        if (false == loadedapicalled){
            let bannerViews = CustomerGlu.entryPointdata.filter {
                $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId == self.bannerId ?? ""
            }
            
            if bannerViews.count != 0 {
                let mobile = bannerViews[0].mobile!
                arrContent = [CGContent]()
                condition = mobile.conditions
                
                if mobile.content.count != 0 {
                    for content in mobile.content {
                        var actionType = ""
                        if content.campaignId.count == 0 {
                            actionType = "WALLET"
                        } else if content.campaignId.contains("http://") || content.campaignId.contains("https://"){
                            actionType = "CUSTOM_URL"
                        } else {
                            actionType = "CAMPAIGN"
                        }
                        
                        eventPublishNudge(pageName: CustomerGlu.getInstance.activescreenname, nudgeId: content._id, actionName: "LOADED", actionType: actionType, openType: content.openLayout, campaignId: content.campaignId)
                    }
                    loadedapicalled = true
                    
                }
                
            }

        }
    }
    
    // MARK: - Nib handlers
    private func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        imgScrollView.frame = bounds
        imgScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        reloadBannerView(element_id: self.bannerId ?? "")
    }
    
    private func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: "BannerView", bundle: .module)
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view!
    }
    
    public func reloadBannerView(element_id: String) {
        
        let bannerViews = CustomerGlu.entryPointdata.filter {
            $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId == element_id
        }
        
        if bannerViews.count != 0 {
            let mobile = bannerViews[0].mobile!
            arrContent = [CGContent]()
            condition = mobile.conditions
            
            if mobile.content.count != 0 {
                for content in mobile.content {
                    arrContent.append(content)
                }
                
                self.setBannerView(height: Int(mobile.container.height)!, isAutoScrollEnabled: mobile.conditions.autoScroll, autoScrollSpeed: mobile.conditions.autoScrollSpeed)
            } else {
                bannerviewHeightZero()
            }
        } else {
            bannerviewHeightZero()
        }
    }
    
    private func bannerviewHeightZero() {
        if code == true {
            self.frame.size.height = CGFloat(0)
            if(self.imgScrollView != nil){
                self.imgScrollView.frame.size.height = CGFloat(0)
            }
        } else {
            if let heightconstraint = (self.constraints.filter{$0.firstAttribute == .height}.first) {
                heightconstraint.constant = CGFloat(0)
                if(self.imgScrollView != nil){
                    self.imgScrollView.frame.size.height = CGFloat(0)
                }
            } else {
                self.frame.size.height = CGFloat(0)
                if(self.imgScrollView != nil){
                    self.imgScrollView.frame.size.height = CGFloat(0)
                }
            }
        }
        finalHeight = 0
        invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    private func setBannerView(height: Int, isAutoScrollEnabled: Bool, autoScrollSpeed: Int){
        
        let screenWidth = self.frame.size.width
        let screenHeight = UIScreen.main.bounds.height
        finalHeight = (Int(screenHeight) * height)/100
        
        if code == true {
            self.frame.size.height = CGFloat(finalHeight)
            self.imgScrollView.frame.size.height = CGFloat(finalHeight)
        } else {
            if let heightconstraint = (self.constraints.filter{$0.firstAttribute == .height}.first) {
                heightconstraint.constant = CGFloat(finalHeight)
                self.imgScrollView.frame.size.height = CGFloat(heightconstraint.constant)
            } else {
                self.frame.size.height = CGFloat(finalHeight)
                self.imgScrollView.frame.size.height = CGFloat(finalHeight)
            }
        }
        
        invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
        imgScrollView.delegate = self
        
        for i in 0..<arrContent.count {
            let dict = arrContent[i]
            if dict.type == "IMAGE" {
                var imageView: UIImageView
                let xOrigin = screenWidth * CGFloat(i)
                
                imageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: screenWidth, height: self.imgScrollView.frame.size.height))
                imageView.isUserInteractionEnabled = true
                imageView.tag = i
                let urlStr = dict.url
                imageView.downloadImage(urlString: urlStr!)
                imageView.contentMode = .scaleToFill
                self.imgScrollView.addSubview(imageView)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                imageView.addGestureRecognizer(tap)
            } else {
                let containerView =  UIView()
                containerView.tag = i
                var webView: WKWebView
                let xOrigin = screenWidth * CGFloat(i)
                containerView.frame  = CGRect.init(x: xOrigin, y: 0, width: screenWidth, height: self.imgScrollView.frame.size.height)
                webView = WKWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: self.imgScrollView.frame.size.height))
                webView.isUserInteractionEnabled = false
                webView.tag = i
                let urlStr = dict.url
                webView.load(URLRequest(url: URL(string: urlStr!)!))
                containerView.addSubview(webView)
                self.imgScrollView.addSubview(containerView)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                containerView.addGestureRecognizer(tap)
            }
        }
        self.imgScrollView.isPagingEnabled = true
        self.imgScrollView.bounces = false
        self.imgScrollView.showsVerticalScrollIndicator = false
        self.imgScrollView.showsHorizontalScrollIndicator = false
        self.imgScrollView.contentSize = CGSize(width: screenWidth * CGFloat(arrContent.count), height: self.imgScrollView.frame.size.height)
        
        // Timer in viewdidload()
        if isAutoScrollEnabled {
            if(timer != nil){
                timer?.invalidate()
                timer = nil
            }
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(autoScrollSpeed), target: self, selector: #selector(moveToNextImage), userInfo: nil, repeats: true)
        }
        
        if arrContent.count > 1 {
            self.pageControl.numberOfPages = arrContent.count
        }
        self.pageControl.currentPage = 0
    }
    
    @objc func moveToNextImage() {
        let imgsCount: CGFloat = CGFloat(arrContent.count)
        let pageWidth: CGFloat = self.imgScrollView.frame.width
        let maxWidth: CGFloat = pageWidth * imgsCount
        let contentOffset: CGFloat = self.imgScrollView.contentOffset.x
        var slideToX = contentOffset + pageWidth
        if  contentOffset + pageWidth == maxWidth {
            slideToX = 0
            self.imgScrollView.scrollRectToVisible(CGRect(x: slideToX, y: 0, width: pageWidth, height: self.imgScrollView.frame.height), animated: false)
        } else {
            self.imgScrollView.scrollRectToVisible(CGRect(x: slideToX, y: 0, width: pageWidth, height: self.imgScrollView.frame.height), animated: true)
        }
        
        let pageNumber = round(slideToX / self.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {

        let dict = arrContent[sender?.view?.tag ?? 0]
        if dict.campaignId != nil {
            if dict.openLayout == "FULL-DEFAULT" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: dict.campaignId, page_type: Constants.FULL_SCREEN_NOTIFICATION, backgroundAlpha: condition?.backgroundOpacity ?? 0.5)
            } else if dict.openLayout == "BOTTOM-DEFAULT" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: dict.campaignId, page_type: Constants.BOTTOM_DEFAULT_NOTIFICATION, backgroundAlpha: condition?.backgroundOpacity ?? 0.5)
            }  else if dict.openLayout == "BOTTOM-SLIDER" {
                CustomerGlu.getInstance.openCampaignById(campaign_id: dict.campaignId, page_type: Constants.BOTTOM_SHEET_NOTIFICATION, backgroundAlpha: condition?.backgroundOpacity ?? 0.5)
            } else {
                CustomerGlu.getInstance.openCampaignById(campaign_id: dict.campaignId, page_type: Constants.MIDDLE_NOTIFICATIONS, backgroundAlpha: condition?.backgroundOpacity ?? 0.5)
            }
            
            var actionType = ""
            if dict.campaignId.count == 0 {
                actionType = "WALLET"
            } else if dict.campaignId.contains("http://") || dict.campaignId.contains("https://"){
                actionType = "CUSTOM_URL"
            } else {
                actionType = "CAMPAIGN"
            }
            
            eventPublishNudge(pageName: CustomerGlu.getInstance.activescreenname, nudgeId: dict._id, actionName: "OPEN", actionType: actionType, openType: dict.openLayout, campaignId: dict.campaignId)
        }
    }
    
    private func eventPublishNudge(pageName: String, nudgeId: String, actionName: String, actionType: String, openType: String, campaignId: String) {
        var eventInfo = [String: AnyHashable]()
        eventInfo[APIParameterKey.nudgeType] = "BANNER"
        
        eventInfo[APIParameterKey.pageName] = pageName
        eventInfo[APIParameterKey.nudgeId] = nudgeId
        eventInfo[APIParameterKey.actionName] = actionName
        eventInfo[APIParameterKey.actionType] = actionType
        eventInfo[APIParameterKey.openType] = openType
        eventInfo[APIParameterKey.eventId] = UUID().uuidString

        if(campaignId.count > 0 && actionType == "CAMPAIGN"){
            eventInfo[APIParameterKey.actionPayload] = [APIParameterKey.deviceType:"iOS",APIParameterKey.campaignId:campaignId]
        }else{
            eventInfo[APIParameterKey.actionPayload] = [APIParameterKey.deviceType:"iOS"]
        }
        ApplicationManager.publishNudge(eventNudge: eventInfo) { success, _ in
            if success {
                
            } else {
                CustomerGlu.getInstance.printlog(cglog: "Fail to call eventPublishNudge", isException: false, methodName: "BannerView-eventPublishNudge", posttoserver: true)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}