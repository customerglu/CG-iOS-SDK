import Foundation

public struct CGEntryPointStates: Codable {
    var collapse: [String]?
    var expanded: [String]?

    init(fromDictionary dictionary: [String: Any]) {
        collapse = dictionary["collapse"] as? [String]
        expanded = dictionary["expanded"] as? [String]
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let collapse = collapse { dictionary["collapse"] = collapse }
        if let expanded = expanded { dictionary["expanded"] = expanded }
        return dictionary
    }
}
