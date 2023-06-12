//
//  CGNudgeContentModel.swift
//  
//
//  Created by Ankit Jain on 12/06/23.
//

import UIKit

class CGNudgeContentModel: NSObject {
    var title: String?
    var body: String?
    var clickAction: String?
    var image: String?
    
    init(fromDictionary dictionary: [AnyHashable: Any]) {
        title = dictionary["title"] as? String
        body = dictionary["body"] as? String
        clickAction = dictionary["campaignId"] as? String
        image = dictionary["image"] as? String
    }
}
