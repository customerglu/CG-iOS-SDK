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

    var typeId: String?
    var widgetStates: [CGWidgetState]?
    var activityStates: [CGActivityState]?
    var contentState: CGContentState?
    var entryPointStates: CGEntryPointStates?
    var progressBarIcon: String?
    var progressMeterIcon: String?
    var nativeStyle: CGNativeStyle?
    var removeOnCompletion: Bool?
    var widgetCss: String?

    enum CodingKeys: String, CodingKey {
        case _id, campaignId, openLayout, type, url, darkUrl, lightUrl
        case relativeHeight, absoluteHeight, closeOnDeepLink
        case action, primaryCta, secondaryCta
        case closeIcon, backgroundColor, backgroundImage
        case typeId
        case widgetStates = "IWidgetState"
        case activityStates = "activityState"
        case contentState = "state"
        case entryPointStates
        case progressBarIcon, progressMeterIcon, nativeStyle
        case removeOnCompletion, widgetCss
    }

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

        typeId = dictionary["typeId"] as? String
        if let wsArray = dictionary["IWidgetState"] as? [[String: Any]] {
            widgetStates = wsArray.map { CGWidgetState(fromDictionary: $0) }
        }
        if let asArray = dictionary["activityState"] as? [[String: Any]] {
            activityStates = asArray.map { CGActivityState(fromDictionary: $0) }
        }
        if let stateDict = dictionary["state"] as? [String: Any] {
            contentState = CGContentState(fromDictionary: stateDict)
        }
        if let epStates = dictionary["entryPointStates"] as? [String: Any] {
            entryPointStates = CGEntryPointStates(fromDictionary: epStates)
        }
        progressBarIcon = dictionary["progressBarIcon"] as? String
        progressMeterIcon = dictionary["progressMeterIcon"] as? String
        if let nsDict = dictionary["nativeStyle"] as? [String: Any] {
            nativeStyle = CGNativeStyle(fromDictionary: nsDict)
        }
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

        if let typeId = typeId { dictionary["typeId"] = typeId }
        if let ws = widgetStates { dictionary["IWidgetState"] = ws.map { $0.toDictionary() } }
        if let as_ = activityStates { dictionary["activityState"] = as_.map { $0.toDictionary() } }
        if let cs = contentState { dictionary["state"] = cs.toDictionary() }
        if let eps = entryPointStates { dictionary["entryPointStates"] = eps.toDictionary() }
        if let pbi = progressBarIcon { dictionary["progressBarIcon"] = pbi }
        if let pmi = progressMeterIcon { dictionary["progressMeterIcon"] = pmi }
        if let ns = nativeStyle { dictionary["nativeStyle"] = ns.toDictionary() }

        return dictionary
    }
}
