//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 23/10/23.
//

import Foundation


public struct CGPIP: Codable{
    
    var muteOnDefaultPIP : Bool?
    var muteOnDefaultExpanded : Bool?
    var loopVideoExpanded : Bool?
    var darkPlayer : Bool?
    var loopVideoPIP : Bool?
    var removeOnDismissExpanded : Bool?
    var removeOnDismissPIP : Bool?
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        muteOnDefaultPIP = dictionary["muteOnDefaultPIP"] as? Bool
        muteOnDefaultExpanded = dictionary["muteOnDefaultExpanded"] as? Bool
        loopVideoExpanded = dictionary["loopVideoExpanded"] as? Bool
        loopVideoPIP = dictionary["loopVideoPIP"] as? Bool
        darkPlayer = dictionary["darkPlayer"] as? Bool
        removeOnDismissExpanded = dictionary["removeOnDismissExpanded"] as? Bool
        removeOnDismissPIP = dictionary["removeOnDismissPIP"] as? Bool
        
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if muteOnDefaultPIP != nil{
            dictionary["muteOnDefaultPIP"] = muteOnDefaultPIP
        }
        if muteOnDefaultExpanded != nil{
            dictionary["muteOnDefaultExpanded"] = muteOnDefaultExpanded
        }
        if loopVideoExpanded != nil{
            dictionary["loopVideoExpanded"] = loopVideoExpanded
        }
        if loopVideoPIP != nil{
            dictionary["loopVideoPIP"] = loopVideoPIP
        }
        if darkPlayer != nil{
            dictionary["darkPlayer"] = darkPlayer
        }
        if removeOnDismissExpanded != nil{
            dictionary["removeOnDismissExpanded"] = muteOnDefaultExpanded
        }
        if removeOnDismissPIP != nil{
            dictionary["removeOnDismissPIP"] = removeOnDismissPIP
        }
        return dictionary
    }
    
}
