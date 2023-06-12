//
//  CGNudgeDataModel.swift
//  
//
//  Created by Ankit Jain on 12/06/23.
//

import UIKit

public class CGNudgeDataModel: Codable {
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
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.client = try container.decodeIfPresent(String.self, forKey: .client)
        self.campaignId = try container.decodeIfPresent(String.self, forKey: .campaignId)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.notificationType = try container.decodeIfPresent(String.self, forKey: .notificationType)
        self.pageType = try container.decodeIfPresent(String.self, forKey: .pageType)
        self.content = try container.decodeIfPresent(CGNudgeContentModel.self, forKey: .content)
        self.timeRemaning = try container.decodeIfPresent(String.self, forKey: .timeRemaning)
        self.expiry = try container.decodeIfPresent(String.self, forKey: .expiry)
        self.gluMessageType = try container.decodeIfPresent(String.self, forKey: .gluMessageType)
        self.absoluteHeight = try container.decodeIfPresent(String.self, forKey: .absoluteHeight)
        self.relativeHeight = try container.decodeIfPresent(String.self, forKey: .relativeHeight)
        self.closeOnDeepLink = try container.decodeIfPresent(String.self, forKey: .closeOnDeepLink)
        self.nudgeId = try container.decodeIfPresent(String.self, forKey: .nudgeId)
        self.screenNames = try container.decodeIfPresent(String.self, forKey: .screenNames)
        self.opacity = try container.decodeIfPresent(String.self, forKey: .opacity)
        self.priority = try container.decodeIfPresent(String.self, forKey: .priority)
        self.ttl = try container.decodeIfPresent(String.self, forKey: .ttl)
    }
    
    init(fromDictionary dictionary: [AnyHashable: Any]) {
        type = dictionary["type"] as? String
        client = dictionary["client"] as? String
        campaignId = dictionary["campaignId"] as? String
        userId = dictionary["userId"] as? String
        notificationType = dictionary["notificationType"] as? String
        pageType = dictionary["pageType"] as? String
        if let contentDict = dictionary["content"] as? [AnyHashable: Any] {
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
