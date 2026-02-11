import Foundation

public struct CGProgressBar: Codable {
    var progressRewardText: String?
    var progressLabel: String?

    init(fromDictionary dictionary: [String: Any]) {
        progressRewardText = dictionary["progressRewardText"] as? String
        progressLabel = dictionary["progressLabel"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let progressRewardText = progressRewardText { dictionary["progressRewardText"] = progressRewardText }
        if let progressLabel = progressLabel { dictionary["progressLabel"] = progressLabel }
        return dictionary
    }
}
