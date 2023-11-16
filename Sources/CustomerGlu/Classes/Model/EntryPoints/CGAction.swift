//
//  File.swift
//  
//
//  Created by Kausthubh adhikari on 28/03/23.
//

import Foundation

public struct CGAction : Codable {
    
    var isHandledBySDK: Bool!
    var type: String!
    var url: String!
    var button: CGButton!
    

    
    init(fromDictionary dictionary: [String:Any]){
        isHandledBySDK = dictionary["isHandledBySDK"] as? Bool
        type = dictionary["type"] as? String
        url = dictionary["url"] as? String
        if let buttonData = dictionary["button"] as? [String:Any]{
            button = CGButton(fromDictionary: buttonData)
        }
    }
    
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        if isHandledBySDK != nil {
            dictionary["isHandledBySDK"] = isHandledBySDK
        }
        if type != nil {
            dictionary["type"] = type
        }
        if url != nil {
            dictionary["url"] = url
        }
        
        if let cgbutton = button {
            dictionary["button"] = cgbutton
        }
        
        return dictionary
    }
    
}
