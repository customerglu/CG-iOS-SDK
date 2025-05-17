//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 25/07/21.
//

import Foundation

class CGEventShareModel: Codable {
    var eventName: String?
    var data: CGEventShareData?
}

class CGEventShareData: Codable {
    var channelName: String?
    var text: String?
    var image: String?
}
