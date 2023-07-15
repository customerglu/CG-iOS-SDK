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
    var title: String?
    var body: String?
    var clickAction: String?
    var image: String?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.client = try container.decodeIfPresent(String.self, forKey: .client)
        self.campaignId = try container.decodeIfPresent(String.self, forKey: .campaignId)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
        self.notificationType = try container.decodeIfPresent(String.self, forKey: .notificationType)
        self.pageType = try container.decodeIfPresent(String.self, forKey: .pageType)
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
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.clickAction = try container.decodeIfPresent(String.self, forKey: .clickAction)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }
    
    init(fromDictionary dictionary: [AnyHashable: Any]) {
        type = dictionary["type"] as? String
        client = dictionary["client"] as? String
        campaignId = dictionary["campaignId"] as? String
        userId = dictionary["userId"] as? String
        notificationType = dictionary["notificationType"] as? String
        pageType = dictionary["pageType"] as? String
        timeRemaning = dictionary["timeRemaning"] as? String
        expiry = dictionary["expiry"] as? String
        gluMessageType = dictionary["gluMessageType"] as? String
        absoluteHeight = dictionary["absoluteHeight"] as? String
        relativeHeight = dictionary["relativeHeight"] as? String
        closeOnDeepLink = dictionary["closeOnDeepLink"] as? String
        nudgeId = dictionary["nudgeId"] as? String
        screenNames = dictionary["screenNames"] as? String
        opacity = dictionary["opacity"] as? String
        priority = dictionary["priority"] as? String
        ttl = dictionary["ttl"] as? String
        title = dictionary["title"] as? String
        body = dictionary["body"] as? String
        clickAction = dictionary["clickAction"] as? String
        image = dictionary["image"] as? String
    }
    
    func convertToDict() -> [AnyHashable: Any] {
        var dictionary: [AnyHashable: Any] = [:]
        
        if let type {
            dictionary["type"] = type
        }
        
        if let client {
            dictionary["client"] = client
        }
        
        if let campaignId {
            dictionary["campaignId"] = campaignId
        }
        
        if let userId {
            dictionary["userId"] = userId
        }
        
        if let notificationType {
            dictionary["notificationType"] = notificationType
        }
        
        if let pageType {
            dictionary["pageType"] = pageType
        }
        
        if let timeRemaning {
            dictionary["timeRemaning"] = timeRemaning
        }
        
        if let expiry {
            dictionary["expiry"] = expiry
        }
        
        if let gluMessageType {
            dictionary["gluMessageType"] = gluMessageType
        }
        
        if let absoluteHeight {
            dictionary["absoluteHeight"] = absoluteHeight
        }
        
        if let relativeHeight {
            dictionary["relativeHeight"] = relativeHeight
        }
        
        if let closeOnDeepLink {
            dictionary["closeOnDeepLink"] = closeOnDeepLink
        }
        
        if let nudgeId {
            dictionary["nudgeId"] = nudgeId
        }
        
        if let screenNames {
            dictionary["screenNames"] = screenNames
        }
        
        if let opacity {
            dictionary["opacity"] = opacity
        }
        
        if let priority {
            dictionary["priority"] = priority
        }
        
        if let ttl {
            dictionary["ttl"] = ttl
        }
        
        if let title {
            dictionary["title"] = title
        }
        
        if let body {
            dictionary["body"] = body
        }
        
        if let clickAction {
            dictionary["clickAction"] = clickAction
        }
        
        if let image {
            dictionary["image"] = image
        }
        
        return dictionary
    }
    
    func printNudgeData() {
        print("** Printing Nudge Model Data **")
        
        if let type {
            print("type :: \(type)")
        }
        
        if let client {
            print("client :: \(client)")
        }
        
        if let campaignId {
            print("campaignId :: \(campaignId)")
        }
        
        if let userId {
            print("userId :: \(userId)")
        }
        
        if let notificationType {
            print("notificationType :: \(notificationType)")
        }
        
        if let pageType {
            print("pageType :: \(pageType)")
        }
        
        if let timeRemaning {
            print("timeRemaning :: \(timeRemaning)")
        }
        
        if let expiry {
            print("expiry :: \(expiry)")
        }
        
        if let gluMessageType {
            print("gluMessageType :: \(gluMessageType)")
        }
        
        if let absoluteHeight {
            print("absoluteHeight :: \(absoluteHeight)")
        }
        
        if let relativeHeight {
            print("relativeHeight :: \(relativeHeight)")
        }
        
        if let closeOnDeepLink {
            print("closeOnDeepLink :: \(closeOnDeepLink)")
        }
        
        if let nudgeId {
            print("nudgeId :: \(nudgeId)")
        }
        
        if let screenNames {
            print("screenNames :: \(screenNames)")
        }
        
        if let opacity {
            print("opacity :: \(opacity)")
        }
        
        if let priority {
            print("priority :: \(priority)")
        }
        
        if let ttl {
            print("ttl :: \(ttl)")
        }
        
        if let title {
            print("title :: \(title)")
        }
        
        if let body {
            print("body :: \(body)")
        }
        
        if let clickAction {
            print("clickAction :: \(clickAction)")
        }
        
        if let image {
            print("image :: \(image)")
        }
    }
}
