//
//  EntryPointVisibilityModel.swift
//  Pods
//
//  Created by Himanshu Trehan on 13/05/25.
//

import Foundation

public class EntryPointVisibilityModel: Codable {
    public var  success: Bool
    public var  data: [EntryPointVisibilityData]
}


public class EntryPointVisibilityData: Codable {
        let id: String?
        let entrypointId: String?
        let client: String?
        let userId: String?
        let campaignId: String?
        let v: Int?
        let entryPointClicked: Bool
        let entryPointCompleteStateViewed: Bool
    }

