//
//  CGNudgeDataModel.swift
//  
//
//  Created by Ankit Jain on 12/06/23.
//

import UIKit

class CGNudgeDataModel: NSObject {
    var type: String?
    var client: String?
    var campaignId: String?
    var userId: String?
    var notificationType: String?
    var pageType: String?
    var content: CGNudgeContentModel?
    var timeRemaning: String?
    var expiry: String?
    var gluMessageType: String?
    var absoluteHeight: String?
    var relativeHeight: String?
    var closeOnDeepLink: String? // Change it to Bool
    var nudgeId: String?
    var screenNames: String?
    var opacity: String?
    var priority: String?
    var ttl: String?
    
    init(fromDictionary dictionary: [String:Any]){
        type = dictionary["type"] as? String
        client = dictionary["client"] as? String
        campaignId = dictionary["campaignId"] as? String
        userId = dictionary["userId"] as? String
        notificationType = dictionary["notificationType"] as? String
        pageType = dictionary["pageType"] as? String
        if let contentDict = dictionary["content"] as? [String: AnyHashable] {
            content = CGNudgeContentModel(fromDictionary: contentDict)
        }
        timeRemaning = dictionary["timeRemaning"] as? String
        expiry = dictionary["expiry"] as? String
        gluMessageType = dictionary["gluMessageType"] as? String
        absoluteHeight = dictionary["absoluteHeight"] as? String
        relativeHeight = dictionary["relativeHeight"] as? String
        closeOnDeepLink = dictionary["closeOnDeepLink"] as? String
        nudgeId = dictionary["nudgeId"] as? String
        screenNames = dictionary[""] as? String
        opacity = dictionary["opacity"] as? String
        priority = dictionary["priority"] as? String
        ttl = dictionary["ttl"] as? String
    }
}
