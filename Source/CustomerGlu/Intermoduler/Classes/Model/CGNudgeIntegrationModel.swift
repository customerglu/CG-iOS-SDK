//
//  CGNudgeIntegrationModel.swift
//  
//
//  Created by Ankit Jain on 03/03/23.
//

import Foundation

public class CGNudgeIntegrationModel: Codable {
    var success: Bool?
    var data: String?
    var error: CGNudgeErrorModel?
}

public class CGNudgeErrorModel: Codable {
    var message: String?
}
