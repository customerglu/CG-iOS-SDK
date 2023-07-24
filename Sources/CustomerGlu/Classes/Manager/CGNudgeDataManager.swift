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
        if CustomerGlu.isDebugingEnabled {
            print("** Init CGNudgeDataManager **")
        }
        let _ = self.getCacheNudgeDataModelsArray()
    }
    
    func getCacheNudgeDataModelsArray() -> [CGNudgeDataModel] {
        if CustomerGlu.isDebugingEnabled {
            print("** CGNudgeDataManager :: Get Nudge Data Array **")
        }
        cacheNudgeDataModelsArray = getDataFromUserDefaults()
        return cacheNudgeDataModelsArray
    }

    func saveNudgeData(with model: CGNudgeDataModel) {
        // Save only if the nudge is not already available
        if getFirstIndex(for: model) == nil {
            if CustomerGlu.isDebugingEnabled {
                print("** CGNudgeDataManager :: Save Nudge Data **")
            }
            
            cacheNudgeDataModelsArray.append(model)
            saveDataToUserDefaults()
        } else {
            if CustomerGlu.isDebugingEnabled {
                print("** CGNudgeDataManager :: Duplicate Nudge Data **")
            }
        }
    }
    
    func deleteNudgeData(with model: CGNudgeDataModel) {
        if CustomerGlu.isDebugingEnabled {
            print("** CGNudgeDataManager :: Start Delete Nudge Data **")
        }
        
        if let firstIndex = getFirstIndex(for: model) {
            if CustomerGlu.isDebugingEnabled {
                print("** CGNudgeDataManager :: End Delete Nudge Data **")
            }
            cacheNudgeDataModelsArray.remove(at: firstIndex)
            saveDataToUserDefaults()
        }
    }
    
    private func getFirstIndex(for model: CGNudgeDataModel) -> Int? {
        if let firstIndex = cacheNudgeDataModelsArray.firstIndex(where: { data in
            data.nudgeId == model.nudgeId
        }) {
            return firstIndex
        }
        return nil
    }
    
    private func saveDataToUserDefaults() {
        if CustomerGlu.isDebugingEnabled {
            print("** CGNudgeDataManager :: Save to User Defaults **")
        }
        let data = convertDataToDict()
        userDefault.set(data, forKey: udKey)
        printInfo()
    }
    
    private func getDataFromUserDefaults() -> [CGNudgeDataModel] {
        if CustomerGlu.isDebugingEnabled {
            print("** CGNudgeDataManager :: Get from User Defaults **")
        }
        
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
    
    private func printInfo() {
        if CustomerGlu.isDebugingEnabled {
            print("** CGNudgeDataManager :: All Saved Nudge ID's **")
            for (index, model) in cacheNudgeDataModelsArray.enumerated() {
                print("** CGNudgeDataManager :: Index : \(index), Nudge ID : \(model.nudgeId ?? "") **")
            }
        }
    }
    
    func clearNudgeDataOnLogout() {
        userDefault.removeObject(forKey: udKey)
        cacheNudgeDataModelsArray = []
        if CustomerGlu.isDebugingEnabled {
            print("** CGNudgeDataManager :: Clearing nudge data **")
        }
    }
}
