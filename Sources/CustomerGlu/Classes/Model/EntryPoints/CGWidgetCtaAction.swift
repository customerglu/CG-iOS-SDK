import Foundation

public struct CGWidgetCtaAction: Codable {
    var type: String?
    var webUrl: String?
    var mobileUrl: String?

    init(fromDictionary dictionary: [String: Any]) {
        type = dictionary["type"] as? String
        webUrl = dictionary["webUrl"] as? String
        mobileUrl = dictionary["mobileUrl"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let type = type { dictionary["type"] = type }
        if let webUrl = webUrl { dictionary["webUrl"] = webUrl }
        if let mobileUrl = mobileUrl { dictionary["mobileUrl"] = mobileUrl }
        return dictionary
    }
}
