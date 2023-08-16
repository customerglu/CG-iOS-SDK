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
    
    
    init(fromDictionary dictionary: [String:Any]){
        isHandledBySDK = dictionary["isHandledBySDK"] as? Bool
        type = dictionary["type"] as? String
        url = dictionary["url"] as? String
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
        return dictionary
    }
    
}
