//
//  EntrypointVisibility.swift
//  Pods
//
//  Created by Himanshu Trehan on 13/05/25.
//

public class EntryPointVisibility: Codable {
    
    var entryPointClicked: Bool?
    var entryPointCompleteStateViewed: Bool?
    
    init(fromDictionary dictionary: [String: Any]) {
        entryPointClicked = dictionary["entryPointClicked"] as? Bool
        entryPointCompleteStateViewed = dictionary["entryPointCompleteStateViewed"] as? Bool
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        
        if let entryPointClicked = entryPointClicked {
            dictionary["entryPointClicked"] = entryPointClicked
        }
        if let entryPointCompleteStateViewed = entryPointCompleteStateViewed {
            dictionary["entryPointCompleteStateViewed"] = entryPointCompleteStateViewed
        }
        
        return dictionary
    }
}
