//
//  CGSTATE.swift
//  
//
//  Created by Yasir on 16/08/23.
//

import UIKit

@objc(CGState)
@available(*, deprecated, renamed: "success")
@available(*, deprecated, renamed: "userNotSignedIn")
@available(*, deprecated, renamed: "invalidURL")
@available(*, deprecated, renamed: "invalidCampaign")
@available(*, deprecated, renamed: "campaignUnavailable")
@available(*, deprecated, renamed: "networkException")
@available(*, deprecated, renamed: "deepLinkURL")
@available(*, deprecated, renamed: "exception")
public enum CGState: Int {
    case success
    case userNotSignedIn
    case invalidURL
    case invalidCampaign
    case campaignUnavailable
    case networkException
    case deepLinkURL
    case exception
}
