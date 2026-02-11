import Foundation

public struct CGWidgetState: Codable {
    var step: Int?
    var state: String?
    var headerImage: String?
    var title: String?
    var body: String?
    var badgeTag: String?
    var ctaText: String?
    var ctaAction: CGWidgetCtaAction?
    var progressMeter: CGProgressMeter?
    var progressBar: CGProgressBar?

    init(fromDictionary dictionary: [String: Any]) {
        step = dictionary["step"] as? Int
        state = dictionary["state"] as? String
        headerImage = dictionary["headerImage"] as? String
        title = dictionary["title"] as? String
        body = dictionary["body"] as? String
        badgeTag = dictionary["badgeTag"] as? String
        ctaText = dictionary["ctaText"] as? String
        if let ctaDict = dictionary["ctaAction"] as? [String: Any] {
            ctaAction = CGWidgetCtaAction(fromDictionary: ctaDict)
        }
        if let pmDict = dictionary["progressMeter"] as? [String: Any] {
            progressMeter = CGProgressMeter(fromDictionary: pmDict)
        }
        if let pbDict = dictionary["progressBar"] as? [String: Any] {
            progressBar = CGProgressBar(fromDictionary: pbDict)
        }
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let step = step { dictionary["step"] = step }
        if let state = state { dictionary["state"] = state }
        if let headerImage = headerImage { dictionary["headerImage"] = headerImage }
        if let title = title { dictionary["title"] = title }
        if let body = body { dictionary["body"] = body }
        if let badgeTag = badgeTag { dictionary["badgeTag"] = badgeTag }
        if let ctaText = ctaText { dictionary["ctaText"] = ctaText }
        if let ctaAction = ctaAction { dictionary["ctaAction"] = ctaAction.toDictionary() }
        if let progressMeter = progressMeter { dictionary["progressMeter"] = progressMeter.toDictionary() }
        if let progressBar = progressBar { dictionary["progressBar"] = progressBar.toDictionary() }
        return dictionary
    }
}
