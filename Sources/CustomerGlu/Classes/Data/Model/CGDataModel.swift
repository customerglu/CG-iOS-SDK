//
//  CGDataModel.swift
//  
//
//  Created by Ankit Jain on 31/03/23.
//

import Foundation

// MARK: - CGDataModel
class CGDataModel: Codable {
    private (set) var cgData: [CGDataItemModel] = []
    
    func setCgData(_ cgDataArray: [CGDataItemModel]) {
        self.cgData.removeAll()
        self.cgData = cgDataArray
    }
    
    func remove(at index: Int) {
        self.cgData.remove(at: index)
    }
    
    func append(_ model: CGDataItemModel) {
        self.cgData.append(model)
    }
}
