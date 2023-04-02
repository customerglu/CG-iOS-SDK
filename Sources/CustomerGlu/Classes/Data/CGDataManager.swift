//
//  CGDataManager.swift
//  
//
//  Created by Ankit Jain on 31/03/23.
//

import Foundation

class CGDataManager: NSObject {
    private var dataModel: CGDataModel?
    private var connector: CGDataConnector?
    private var userDefaultManager: CGUserDefaultManager?
    
    private override init() {
        super.init()
    }
    
    init(dataModel: CGDataModel, connector: CGDataConnector, userDefaultManager: CGUserDefaultManager?) {
        super.init()
        self.dataModel = dataModel
        self.connector = connector
        self.userDefaultManager = userDefaultManager
    }
    
    /**
     * Retrieve CGModel
     */
    func retrieveCGDataModel() {
        //Retrieve from User Default
        if let userDefaultManager {
            if let dataModel = userDefaultManager.retrieveCGDataModel(), let connector {
                connector.onCGDataRetrieved(dataModel: dataModel)
            }
        }
    }

    /**
     * Update CGDataModel in the SharedPreferences.
     *
     * @param key
     * @param value
     */
    func updateCGDataModel(key: String, value: String) {
        guard let dataModel else { return }
        let currentData = CGDataItemModel(dataValue: value, dataKey: key)
        if dataModel.cgData.contains(currentData), let index = dataModel.cgData.firstIndex(of: currentData) {
            dataModel.remove(at: index)
            dataModel.append(currentData)
        } else {
            dataModel.append(currentData)
        }
        
        //Saving the data in background.
        DispatchQueue.global(qos: .userInitiated).async {
            if let userDefaultManager = self.userDefaultManager {
                userDefaultManager.saveCGDataModel(dataModel)
            }
        }
    }
    
    /**
     * Delete CGModel Data from Device
     */    
    func purgeCGDataModel() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let userDefaultManager = self.userDefaultManager {
                userDefaultManager.deleteCGDataModel()
            }
        }
    }
}
