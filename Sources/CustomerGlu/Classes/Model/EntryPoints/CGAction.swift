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
    var openLayout: String!
    var relativeHeight: Double? = 0.0
    var absoluteHeight: Double? = 0.0
    var shareText: String!
    var shareImage: String!
    var button: CGButton!
    

    
    init(fromDictionary dictionary: [String:Any]){
        isHandledBySDK = dictionary["isHandledBySDK"] as? Bool
        type = dictionary["type"] as? String
        url = dictionary["url"] as? String
        relativeHeight = dictionary["relativeHeight"] as? Double ?? 0.0
        absoluteHeight = dictionary["absoluteHeight"] as? Double ?? 0.0
        openLayout = dictionary["openLayout"] as? String
        shareText = dictionary["shareText"] as? String
        shareImage = dictionary["shareImage"] as? String
        if let buttonData = dictionary["button"] as? [String:Any]{
            button = CGButton(fromDictionary: buttonData)
        }
    }
    
    
    func toDictionary() -> [String:Any]{
        var dictionary = [String:Any]()
        if isHandledBySDK != nil {
            dictionary["isHandledBySDK"] = isHandledBySDK
        }
        if openLayout != nil{
            dictionary["openLayout"] = openLayout
        }
        
        if relativeHeight != nil{
            dictionary["relativeHeight"] = relativeHeight
        }
        
        if absoluteHeight != nil{
            dictionary["absoluteHeight"] = absoluteHeight
        }
   
        if type != nil {
            dictionary["type"] = type
        }
        if url != nil {
            dictionary["url"] = url
        }
        if shareText != nil {
            dictionary["shareText"] = shareText
        }
        if shareImage != nil {
            dictionary["shareImage"] = shareImage
        }
        
        if let cgbutton = button {
            dictionary["button"] = cgbutton
        }
        
      
        
        return dictionary
    }
    
}
