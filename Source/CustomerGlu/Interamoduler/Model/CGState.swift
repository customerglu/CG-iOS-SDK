//
//  CGSTATE.swift
//  
//
//  Created by Yasir on 16/08/23.
//

import UIKit

@objc(CGState)
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
