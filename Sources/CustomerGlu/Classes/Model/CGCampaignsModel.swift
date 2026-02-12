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
    public var stepCompleted: Int?
    public var activityCount: Int?
    public var activityExpiry: String?
    public var checkAccepted: Bool?
    public var accepted: Bool?

    private enum CodingKeys: String, CodingKey {
        case title, body, totalUsers, imageUrl, completedUsers, inProgressUsers
        case totalSteps, stepsCompleted, stepsRemaining, tag, userCampaignStatus
        case stepCompleted, activityCount, activityExpiry, checkAccepted, accepted
        case campaignName, totalCampaignParticipants, isSkeleton
    }

    // Extra fields from API that we ignore but must accept to avoid decode failures
    public var campaignName: String?
    public var totalCampaignParticipants: Int?
    public var isSkeleton: Bool?

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        totalUsers = try container.decodeIfPresent(String.self, forKey: .totalUsers)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        completedUsers = try container.decodeIfPresent(String.self, forKey: .completedUsers)
        inProgressUsers = try container.decodeIfPresent(String.self, forKey: .inProgressUsers)
        totalSteps = try container.decodeIfPresent(String.self, forKey: .totalSteps)
        stepsCompleted = try container.decodeIfPresent(String.self, forKey: .stepsCompleted)
        stepsRemaining = try container.decodeIfPresent(String.self, forKey: .stepsRemaining)
        tag = try container.decodeIfPresent(String.self, forKey: .tag)
        userCampaignStatus = try container.decodeIfPresent(String.self, forKey: .userCampaignStatus)
        stepCompleted = try container.decodeIfPresent(Int.self, forKey: .stepCompleted)
        activityCount = try container.decodeIfPresent(Int.self, forKey: .activityCount)
        checkAccepted = try container.decodeIfPresent(Bool.self, forKey: .checkAccepted)
        accepted = try container.decodeIfPresent(Bool.self, forKey: .accepted)
        campaignName = try container.decodeIfPresent(String.self, forKey: .campaignName)
        totalCampaignParticipants = try container.decodeIfPresent(Int.self, forKey: .totalCampaignParticipants)
        isSkeleton = try container.decodeIfPresent(Bool.self, forKey: .isSkeleton)

        // activityExpiry can be String or Number from API
        if let str = try? container.decodeIfPresent(String.self, forKey: .activityExpiry) {
            activityExpiry = str
        } else if let num = try? container.decodeIfPresent(Double.self, forKey: .activityExpiry) {
            activityExpiry = String(Int(num))
        }
    }
}
