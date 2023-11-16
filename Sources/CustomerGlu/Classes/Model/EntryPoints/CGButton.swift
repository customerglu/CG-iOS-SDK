//
//  CGActionButton.swift
//  
//
//  Created by Kausthubh adhikari on 15/11/23.
//

import Foundation

public struct CGButton : Codable {
    
    var buttonTextColor: String!
    var showButton: Bool!
    var buttonText: String!
    var buttonColor: String!
    
    init(fromDictionary dictionary: [String:Any]){
        buttonText = dictionary["buttonText"] as? String
        showButton = dictionary["showButton"] as? Bool
        buttonColor = dictionary["buttonColor"] as? String
        buttonTextColor = dictionary["buttonTextColor"] as? String
    }
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String: Any]()
        if let buttonText = buttonText{
            dictionary["buttonText"] = buttonText
        }
        
        if let showButton = showButton{
            dictionary["showButton"] = showButton
        }
        
        if let buttonColor = buttonColor {
            dictionary["buttonColor"] = buttonColor
        }
        
        if let buttonTextColor = buttonTextColor {
            dictionary["buttonTextColor"] = buttonTextColor
        }
        return dictionary
    }
    
}
