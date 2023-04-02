//
//  CGUserDefaultManager.swift
//  
//
//  Created by Ankit Jain on 02/04/23.
//

import Foundation

class CGUserDefaultManager {
    private var userDefault: UserDefaults?
    
    func initialiseCGDataWithUserDefault(userDefault: UserDefaults) {
        self.userDefault = userDefault
    }
    
    func saveCGDataModel(_ data: CGDataModel) {
        if let userDefault, let convertToString = data.convertToString {
            userDefault.set(convertToString, forKey: CGDataConstants.CG_DATA_MODEL_KEY)
            userDefault.synchronize()
        }
    }
    
    func retrieveCGDataModel() -> CGDataModel? {
        if let userDefault,
            let str = userDefault.object(forKey: CGDataConstants.CG_DATA_MODEL_KEY) as? String,
            let dict = OtherUtils.shared.convertToDictionary(text: str),
            let model = OtherUtils.shared.dictToObject(dict: dict, type: CGDataModel.self) {
            return model
        }
        
        return nil
    }
    
    func deleteCGDataModel() {
        if let userDefault {
            userDefault.removeObject(forKey: CGDataConstants.CG_DATA_MODEL_KEY)
            userDefault.synchronize()
        }
    }
}
