import Foundation

public struct CGContentStateItem: Codable {
    var body: String?
    var title: String?

    init(fromDictionary dictionary: [String: Any]) {
        body = dictionary["body"] as? String
        title = dictionary["title"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let body = body { dictionary["body"] = body }
        if let title = title { dictionary["title"] = title }
        return dictionary
    }
}

public struct CGContentState: Codable {
    var completed: CGContentStateItem?
    var inProgress: CGContentStateItem?
    var inProgressDayCompleted: CGContentStateItem?
    var pristine: CGContentStateItem?

    enum CodingKeys: String, CodingKey {
        case completed
        case inProgress = "in-progress"
        case inProgressDayCompleted = "in-progress-daycompleted"
        case pristine
    }

    init(fromDictionary dictionary: [String: Any]) {
        if let d = dictionary["completed"] as? [String: Any] {
            completed = CGContentStateItem(fromDictionary: d)
        }
        if let d = dictionary["in-progress"] as? [String: Any] {
            inProgress = CGContentStateItem(fromDictionary: d)
        }
        if let d = dictionary["in-progress-daycompleted"] as? [String: Any] {
            inProgressDayCompleted = CGContentStateItem(fromDictionary: d)
        }
        if let d = dictionary["pristine"] as? [String: Any] {
            pristine = CGContentStateItem(fromDictionary: d)
        }
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let completed = completed { dictionary["completed"] = completed.toDictionary() }
        if let inProgress = inProgress { dictionary["in-progress"] = inProgress.toDictionary() }
        if let inProgressDayCompleted = inProgressDayCompleted { dictionary["in-progress-daycompleted"] = inProgressDayCompleted.toDictionary() }
        if let pristine = pristine { dictionary["pristine"] = pristine.toDictionary() }
        return dictionary
    }
}
