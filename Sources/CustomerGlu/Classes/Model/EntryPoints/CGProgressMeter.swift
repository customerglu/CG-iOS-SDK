import Foundation

public struct CGProgressMeter: Codable {
    var completedText: String?

    init(fromDictionary dictionary: [String: Any]) {
        completedText = dictionary["completedText"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let completedText = completedText { dictionary["completedText"] = completedText }
        return dictionary
    }
}
