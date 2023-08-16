//
//  PopUpModel.swift
//  
//
//  Created by Yasir on 16/08/23.
//

import Foundation

struct PopUpModel: Codable {
    public var _id: String?
    public var showCount: CGShowCount?
    public var delay: Int?
    public var backgroundOpacity: Double?
    public var priority: Int?
    public var popUpDate: Date?
    public var type: String?
}
