//
//  File.swift
//
//
//  Created by kapil on 29/10/21.
//

import Foundation

@objc(CGNudgeConfiguration)
public class CGNudgeConfiguration:NSObject {
    
    @objc public var closeOnDeepLink = CustomerGlu.auto_close_webview!
    @objc public var opacity = 0.5
    @objc public var layout = ""
    @objc public var url = ""
    @objc public var absoluteHeight = 0.0
    @objc public var relativeHeight = 0.0
    @objc public var isHyperLink = false
    //    public var notificationHandler = false
    
    public override init() {
        
    }
    
    @objc public init(closeOnDeepLink : Bool = CustomerGlu.auto_close_webview!, opacity : Double = 0.5, layout : String = "",url : String = "", absoluteHeight : Double = 0.0, relativeHeight : Double = 0.0/*, notificationHandler : Bool = false*/) {
        
        self.closeOnDeepLink = closeOnDeepLink
        self.opacity = opacity
        self.layout = layout
        self.url = url
        self.absoluteHeight = absoluteHeight
        self.relativeHeight = relativeHeight
        //        self.notificationHandler = notificationHandler
    }
    
    
    /***
       Added isHyperlink support  for Entrypoint s
     */
    @objc public init(closeOnDeepLink : Bool = CustomerGlu.auto_close_webview!, opacity : Double = 0.5, layout : String = "",url : String = "", absoluteHeight : Double = 0.0, relativeHeight : Double = 0.0,isHyperLink: Bool) {
        
        self.closeOnDeepLink = closeOnDeepLink
        self.opacity = opacity
        self.layout = layout
        self.url = url
        self.absoluteHeight = absoluteHeight
        self.relativeHeight = relativeHeight
        self.isHyperLink = isHyperLink
    }
    
}
