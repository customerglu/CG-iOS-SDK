//
//  CGProxyHelper.swift
//  
//
//  Created by Yasir on 21/08/23.
//

import Foundation

class CGProxyHelper {
    static let shared = CGProxyHelper()
    private let userDefaults = UserDefaults.standard
    
    private init() { }
    
    func getProgram() -> Void {
        var campaignIds: [String : Any] = [:]
        
        for id in CustomerGlu.allCampaignsIds {
            campaignIds[id] = true
        }
        
        let campaignId: [String : Any] = [
            "campaignId" : campaignIds
        ]
        
        let request: NSDictionary = [
            "filter" : campaignId,
            "limit" : 50,
            "page" : 1
        ]
        
        APIManager.getProgram(queryParameters: request) { result in
            switch result {
            case .success(let response):
                if let response = response {
                    self.encryptUserDefaultKey(str: response, userdefaultKey: CGConstants.CGGetProgramResponse)
                }
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "getProgram", posttoserver: false)
            }
        }
    }
    
    func getReward() -> Void {
        var campaignIds: [String : Any] = [:]
        
        for id in CustomerGlu.allCampaignsIds {
            campaignIds[id] = true
        }
        
        let campaignId: [String : Any] = [
            "campaignId" : campaignIds
        ]
        
        let request: NSDictionary = [
            "filter" : campaignId,
            "limit" : 50,
            "page" : 1
        ]
        
        APIManager.getReward(queryParameters: request) { result in
            switch result {
            case .success(let response):
                if let response = response {
                    self.encryptUserDefaultKey(str: response, userdefaultKey: CGConstants.CGGetRewardResponse)
                }
            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "getReward", posttoserver: false)
            }
        }
    }
    
    private func encryptUserDefaultKey(str: String, userdefaultKey: String) {
        self.userDefaults.set(EncryptDecrypt.shared.encryptText(str: str), forKey: userdefaultKey)
    }
}
