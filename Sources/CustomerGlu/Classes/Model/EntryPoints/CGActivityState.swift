import Foundation

public struct CGActivityState: Codable {
    var badgeTag: String?
    var body: String?
    var ctaAction: CGWidgetCtaAction?
    var ctaText: String?
    var rewardData: String?
    var title: String?

    init(fromDictionary dictionary: [String: Any]) {
        badgeTag = dictionary["badgeTag"] as? String
        body = dictionary["body"] as? String
        if let ctaDict = dictionary["ctaAction"] as? [String: Any] {
            ctaAction = CGWidgetCtaAction(fromDictionary: ctaDict)
        }
        ctaText = dictionary["ctaText"] as? String
        rewardData = dictionary["rewardData"] as? String
        title = dictionary["title"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let badgeTag = badgeTag { dictionary["badgeTag"] = badgeTag }
        if let body = body { dictionary["body"] = body }
        if let ctaAction = ctaAction { dictionary["ctaAction"] = ctaAction.toDictionary() }
        if let ctaText = ctaText { dictionary["ctaText"] = ctaText }
        if let rewardData = rewardData { dictionary["rewardData"] = rewardData }
        if let title = title { dictionary["title"] = title }
        return dictionary
    }
}
