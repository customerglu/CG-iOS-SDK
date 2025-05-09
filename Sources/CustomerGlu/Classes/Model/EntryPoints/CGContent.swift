//
//	Content.swift
//
//	Create by Mukesh Yadav on 5/4/2022

import Foundation

public struct CGContent: Codable {
    
    var _id: String!
    var campaignId: String!
    var openLayout: String!
    var type: String!
    var url: String!
    var darkUrl: String?
    var lightUrl: String?
    
    var relativeHeight: Double? = 0.0
    var absoluteHeight: Double? = 0.0
    var closeOnDeepLink: Bool? = CustomerGlu.auto_close_webview!
    
    var action: CGAction!
    var primaryCta: CGAction?
    var secondaryCta: CGAction?
    
    var closeIcon: String?
    var backgroundColor: String?
    var backgroundImage: String?

    init(fromDictionary dictionary: [String: Any]) {
        _id = dictionary["_id"] as? String
        campaignId = dictionary["campaignId"] as? String
        openLayout = dictionary["openLayout"] as? String
        type = dictionary["type"] as? String
        url = dictionary["url"] as? String
        relativeHeight = dictionary["relativeHeight"] as? Double ?? 0.0
        absoluteHeight = dictionary["absoluteHeight"] as? Double ?? 0.0
        closeOnDeepLink = dictionary["closeOnDeepLink"] as? Bool ?? CustomerGlu.auto_close_webview
        darkUrl = dictionary["darkUrl"] as? String
        lightUrl = dictionary["lightUrl"] as? String

        if let actionDict = dictionary["action"] as? [String: Any] {
            action = CGAction(fromDictionary: actionDict)
        }

        if let primaryDict = dictionary["primaryCta"] as? [String: Any] {
            primaryCta = CGAction(fromDictionary: primaryDict)
        }

        if let secondaryDict = dictionary["secondaryCta"] as? [String: Any] {
            secondaryCta = CGAction(fromDictionary: secondaryDict)
        }

        closeIcon = dictionary["closeIcon"] as? String
        backgroundColor = dictionary["backgroundColor"] as? String
        backgroundImage = dictionary["backgroundImage"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["_id"] = _id
        dictionary["campaignId"] = campaignId
        dictionary["openLayout"] = openLayout
        dictionary["type"] = type
        dictionary["url"] = url
        dictionary["relativeHeight"] = relativeHeight
        dictionary["absoluteHeight"] = absoluteHeight
        dictionary["closeOnDeepLink"] = closeOnDeepLink
        dictionary["darkUrl"] = darkUrl
        dictionary["lightUrl"] = lightUrl

        if let action = action {
            dictionary["action"] = action.toDictionary()
        }
        if let primaryCta = primaryCta {
            dictionary["primaryCta"] = primaryCta.toDictionary()
        }
        if let secondaryCta = secondaryCta {
            dictionary["secondaryCta"] = secondaryCta.toDictionary()
        }

        dictionary["closeIcon"] = closeIcon
        dictionary["backgroundColor"] = backgroundColor
        dictionary["backgroundImage"] = backgroundImage

        return dictionary
    }
}
