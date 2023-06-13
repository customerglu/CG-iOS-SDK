//
//  CGNudgeDataManager.swift
//  
//
//  Created by Ankit Jain on 13/06/23.
//

import UIKit

//MARK: - CGNudgeDataManager
class CGNudgeDataManager: NSObject {
    static let shared = CGNudgeDataManager()
    private let userDefault = UserDefaults.standard
    private let udKey: String = "CGNudgeDataModel"
    private var cacheNudgeDataModelsArray: [CGNudgeDataModel] = []
    
    private override init() {
        super.init()
        let _ = self.getCacheNudgeDataModelsArray()
    }
    
    func getCacheNudgeDataModelsArray() -> [CGNudgeDataModel] {
        cacheNudgeDataModelsArray = getDataFromUserDefaults()
        return cacheNudgeDataModelsArray
    }

    func saveNudgeData(with model: CGNudgeDataModel) {
        cacheNudgeDataModelsArray.append(model)
        saveDataToUserDefaults()
    }
    
    func deleteNudgeData(with model: CGNudgeDataModel) {
        if let firstIndex = cacheNudgeDataModelsArray.firstIndex(where: { data in
            data.nudgeId == model.nudgeId
        }) {
            cacheNudgeDataModelsArray.remove(at: firstIndex)
            saveDataToUserDefaults()
        }
    }
    
    private func saveDataToUserDefaults() {
        let data = convertDataToDict()
        userDefault.set(data, forKey: udKey)
    }
    
    private func getDataFromUserDefaults() -> [CGNudgeDataModel] {
        if let cacheData = userDefault.object(forKey: udKey) as? [[AnyHashable: Any]] {
            var data: [CGNudgeDataModel] = []
            for dict in cacheData {
                data.append(CGNudgeDataModel(fromDictionary: dict))
            }
            return data
        }
        
        return []
    }
    
    private func convertDataToDict() -> [[AnyHashable: Any]] {
        var data: [[AnyHashable: Any]] = []
        for model in cacheNudgeDataModelsArray {
            data.append(model.convertToDict())
        }
        return data
    }
    
    private func updateCacheNudgeDataModelsArray() -> [[AnyHashable: Any]] {
        var data: [[AnyHashable: Any]] = []
        for model in cacheNudgeDataModelsArray {
            data.append(model.convertToDict())
        }
        return data
    }
}
