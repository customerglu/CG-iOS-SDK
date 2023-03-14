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
    var imgScrollView: UIScrollView!
    var pageControl: UIPageControl!
    
    @IBInspectable var bannerId: String? {
        didSet {
            backgroundColor = UIColor.clear
            CustomerGlu.getInstance.postBannersCount()
            reloadBannerView()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.entryPointLoaded),
                name: Notification.Name("EntryPointLoaded"),
                object: nil)
        }
    }
    
    @objc private func entryPointLoaded(notification: NSNotification) {
        self.reloadBannerView()
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
        code = true
        self.xibSetup()
        self.commonBannerId = bannerId
    }
    
    required init?(coder aDecoder: NSCoder) {
        // XIB
        super.init(coder: aDecoder)
        code = false
        self.xibSetup()
    }
    
    public override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(finalHeight))
    }
    
    // MARK: - Nib handlers
    private func xibSetup() {
        self.autoresizesSubviews = true
        view = UIView()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizesSubviews = true
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        imgScrollView = UIScrollView()
        imgScrollView.frame = bounds
        imgScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgScrollView.translatesAutoresizingMaskIntoConstraints = true
        imgScrollView.delegate = self
        imgScrollView.isPagingEnabled = true
        imgScrollView.autoresizesSubviews = true
        view.addSubview(imgScrollView)
        
        pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        view.addSubview(pageControl)
        
        addSubview(view)
    }
    
    public func reloadBannerView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            
            if self.imgScrollView != nil {
                self.imgScrollView.subviews.forEach({ $0.removeFromSuperview() })
            }
            
            let bannerViews = CustomerGlu.entryPointdata.filter {
                $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId == self.bannerId
            }
            
            if bannerViews.count != 0, let mobile = bannerViews[0].mobile {
                arrContent = [CGContent]()
                condition = mobile.conditions
                
                if mobile.content.count != 0 {
                    for content in mobile.content {
                        arrContent.append(content)
                    }
                    self.setBannerView(height: Int(mobile.container.height)!, isAutoScrollEnabled: mobile.conditions.autoScroll, autoScrollSpeed: mobile.conditions.autoScrollSpeed)
                    callLoadBannerAnalytics()
                } else {
                    bannerviewHeightZero()
                }
            } else {
                bannerviewHeightZero()
            }
        }
    }
    
    private func bannerviewHeightZero() {
        
        finalHeight = 0
        
        self.constraints.filter{$0.firstAttribute == .height}.forEach({ $0.constant = CGFloat(finalHeight) })
        self.frame.size.height = CGFloat(finalHeight)
        self.view.frame.size.height = CGFloat(finalHeight)
        
        if self.imgScrollView != nil {
            self.imgScrollView.frame.size.height = CGFloat(finalHeight)
        }
        
        let postInfo: [String: Any] = [self.bannerId ?? "" : finalHeight]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CGBANNER_FINAL_HEIGHT").rawValue), object: nil, userInfo: postInfo)
        
        invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    private func setBannerView(height: Int, isAutoScrollEnabled: Bool, autoScrollSpeed: Int){
        
        let screenWidth = self.frame.size.width
        let screenHeight = UIScreen.main.bounds.height
        finalHeight = (Int(screenHeight) * height)/100
        if !CustomerGlu.bannerIds.contains(self.bannerId ?? "")
        {
            CustomerGlu.bannerIds.append(self.bannerId ?? "")
            CustomerGlu.getInstance.sendEntryPointsIdLists()
        }
        let postInfo: [String: Any] = [self.bannerId ?? "" : finalHeight]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.Name("CGBANNER_FINAL_HEIGHT").rawValue), object: nil, userInfo: postInfo)
        
        self.constraints.filter{$0.firstAttribute == .height}.forEach({ $0.constant = CGFloat(finalHeight) })
        self.frame.size.height = CGFloat(finalHeight)
        self.view.frame.size.height = CGFloat(finalHeight)
        
        if self.imgScrollView != nil {
            self.imgScrollView.frame.size.height = CGFloat(finalHeight)
        }
        
        for i in 0..<arrContent.count {
            let dict = arrContent[i]
            if dict.type == "IMAGE" {
                var imageView: UIImageView
                let xOrigin = screenWidth * CGFloat(i)
                
                imageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: screenWidth, height: CGFloat(finalHeight)))
                imageView.isUserInteractionEnabled = true
                imageView.tag = i
                let urlStr = (dict.darkUrl == nil || dict.lightUrl == nil) ? dict.url : (CustomerGlu.getInstance.isDarkModeEnabled() ? dict.darkUrl : dict.lightUrl)
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
                containerView.frame  = CGRect.init(x: xOrigin, y: 0, width: screenWidth, height: CGFloat(finalHeight))
                webView = WKWebView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: CGFloat(finalHeight)))
                webView.isUserInteractionEnabled = false
                webView.tag = i
                let urlStr = dict.url
                //                webView.load(URLRequest(url: URL(string: urlStr!)!))
                webView.load(URLRequest(url: CustomerGlu.getInstance.validateURL(url: URL(string: urlStr!)!)))
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
        
        pageControl.frame = CGRect(x: 0, y: finalHeight - 26, width: Int(self.frame.size.width), height: 26)
        
        invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    public override func layoutSubviews() {
        reloadBannerView()
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
            
            let nudgeConfiguration = CGNudgeConfiguration()
            nudgeConfiguration.layout = dict.openLayout.lowercased()
            nudgeConfiguration.opacity = condition?.backgroundOpacity ?? 0.5
            nudgeConfiguration.closeOnDeepLink = dict.closeOnDeepLink ?? CustomerGlu.auto_close_webview!
            nudgeConfiguration.relativeHeight = dict.relativeHeight ?? 0.0
            nudgeConfiguration.absoluteHeight = dict.absoluteHeight ?? 0.0
            
            CustomerGlu.getInstance.openCampaignById(campaign_id: dict.campaignId, nudgeConfiguration: nudgeConfiguration)
            
            let bannerViews = CustomerGlu.entryPointdata.filter {
                $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId == self.bannerId ?? ""
            }
            
            if bannerViews.count != 0 {
                let name = bannerViews[0].name ?? ""
                CustomerGlu.getInstance.postAnalyticsEventForEntryPoints(event_name: "ENTRY_POINT_CLICK", entry_point_id: dict._id, entry_point_name: name, entry_point_container: bannerViews[0].mobile.container.type, content_campaign_id: dict.url, open_container:dict.openLayout, action_c_campaign_id: dict.campaignId)
            }
            
        }
    }
    
    private func callLoadBannerAnalytics(){
        
        if (false == loadedapicalled){
            let bannerViews = CustomerGlu.entryPointdata.filter {
                $0.mobile.container.type == "BANNER" && $0.mobile.container.bannerId == self.bannerId ?? ""
            }
            
            if bannerViews.count != 0, let mobile = bannerViews[0].mobile {
                arrContent = [CGContent]()
                condition = mobile.conditions
                
                if mobile.content.count != 0 {
                    for content in mobile.content {
                        arrContent.append(content)
                        
                        CustomerGlu.getInstance.postAnalyticsEventForEntryPoints(event_name: "ENTRY_POINT_LOAD", entry_point_id: content._id, entry_point_name: bannerViews[0].name ?? "", entry_point_container: mobile.container.type, content_campaign_id: content.url, open_container:content.openLayout, action_c_campaign_id: content.campaignId)
                    }
                    loadedapicalled = true
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
