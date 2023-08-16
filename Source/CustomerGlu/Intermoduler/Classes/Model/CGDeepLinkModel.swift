//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/07/21.
//

import Foundation

class CGDeepLinkModel: Codable {
    var eventName = ""
    var data: CGEventLinkData?
    
    init(eventName: String = "", data: CGEventLinkData? = nil) {
        self.eventName = eventName
        self.data = data
    }
}

class CGEventLinkData: Codable {
    var name: String?
    var deepLink: String?
    
    init(name: String? = nil, deepLink: String? = nil) {
        self.name = name
        self.deepLink = deepLink
    }
}
