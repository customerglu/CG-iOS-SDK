import Foundation

public struct CGButton: Codable {
    
    var buttonTextColor: String?
    var showButton: Bool?
    var buttonText: String?
    var buttonColor: String?
    
    var borderRadius: String?
    var height: String?
    var width: String?
    var textSize: String?
    var marginHorizontal: String?
    var marginVertical: String?

    init(fromDictionary dictionary: [String: Any]) {
        buttonText = dictionary["buttonText"] as? String
        showButton = dictionary["showButton"] as? Bool
        buttonColor = dictionary["buttonColor"] as? String
        buttonTextColor = dictionary["buttonTextColor"] as? String
        
        borderRadius = dictionary["borderRadius"] as? String
        height = dictionary["height"] as? String
        width = dictionary["width"] as? String
        textSize = dictionary["textSize"] as? String
        marginHorizontal = dictionary["marginHorizontal"] as? String
        marginVertical = dictionary["marginVertical"] as? String
    }

    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let buttonText = buttonText {
            dictionary["buttonText"] = buttonText
        }
        if let showButton = showButton {
            dictionary["showButton"] = showButton
        }
        if let buttonColor = buttonColor {
            dictionary["buttonColor"] = buttonColor
        }
        if let buttonTextColor = buttonTextColor {
            dictionary["buttonTextColor"] = buttonTextColor
        }
        if let borderRadius = borderRadius {
            dictionary["borderRadius"] = borderRadius
        }
        if let height = height {
            dictionary["height"] = height
        }
        if let width = width {
            dictionary["width"] = width
        }
        if let textSize = textSize {
            dictionary["textSize"] = textSize
        }
        if let marginHorizontal = marginHorizontal {
            dictionary["marginHorizontal"] = marginHorizontal
        }
        if let marginVertical = marginVertical {
            dictionary["marginVertical"] = marginVertical
        }
        return dictionary
    }
}
