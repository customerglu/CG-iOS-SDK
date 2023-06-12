//
//  CGNudgeContentModel.swift
//  
//
//  Created by Ankit Jain on 12/06/23.
//

import UIKit

public class CGNudgeContentModel: Codable {
    var title: String?
    var body: String?
    var clickAction: String?
    var image: String?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.clickAction = try container.decodeIfPresent(String.self, forKey: .clickAction)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }
    
    init(fromDictionary dictionary: [AnyHashable: Any]) {
        title = dictionary["title"] as? String
        body = dictionary["body"] as? String
        clickAction = dictionary["campaignId"] as? String
        image = dictionary["image"] as? String
    }
}
