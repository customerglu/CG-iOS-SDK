//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 23/07/21.
//

import Foundation

public class CGCampaignsModel: Codable {
    public var success: Bool?
    public var defaultUrl = ""
    public var campaigns: [CGCampaigns]?
    public var defaultBanner: CGDefaultBanner?
}

public class CGCampaigns: Codable {
    public var campaignId = ""
    public var url: String = ""
    public var type: String = ""
    public var status: String = ""
    public var banner: CGBanner?
}

public class CGDefaultBanner: Codable {
    public var liveCampaignCount: Int?
    public var totalRewardCount: Int?
}

public class CGBanner: Codable {
    public var title: String?
    public var body: String?
    public var totalUsers: String?
    public var imageUrl: String?
    public var completedUsers: String?
    public var inProgressUsers: String?
    public var totalSteps: String?
    public var stepsCompleted: String?
    public var stepsRemaining: String?
    public var tag: String?
    public var userCampaignStatus: String?
}
