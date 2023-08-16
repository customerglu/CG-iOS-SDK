//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 28/02/23.
//

import Foundation

@objc(CGEntryPointIdListModel)
public class CGEntryPointIdListModel: NSObject, Codable {
    public var activityIdList: [String]?
    public var bannerIds: [String]?
    public var embedIds: [String]?

}
