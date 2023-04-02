//
//  CGDataItemModel.swift
//  
//
//  Created by Ankit Jain on 02/04/23.
//

import Foundation

// MARK: - CGDataItemModel
struct CGDataItemModel: Codable {
    private (set) var dataValue: String?
    private (set) var dataKey: String?
    
    init(dataValue: String, dataKey: String) {
        self.dataValue = dataValue
        self.dataKey = dataKey
    }
}

// MARK: - Extension - Equatable & Hashable
extension CGDataItemModel: Equatable, Hashable {
    static func == (lhs: CGDataItemModel, rhs: CGDataItemModel) -> Bool {
        return lhs.dataKey == rhs.dataKey && lhs.dataValue == rhs.dataValue
    }
}
