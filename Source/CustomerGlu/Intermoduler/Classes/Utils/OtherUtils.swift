//
//  File.swift
//  
//
//  Created by kapil on 23/12/21.
//

import Foundation
import UIKit

class OtherUtils {
    
    // Singleton Instance
    static let shared = OtherUtils()
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "OtherUtils-convertToDictionary", posttoserver: false)
            }
        }
        return nil
    }
    
    
    /***
        Add Query Parameters to URL
     */
    func addQueryParamsToURL(with urlWithoutParams: String, paramsToAdd: [String: Any]) -> URL{
        let urlComponents = NSURLComponents(string: urlWithoutParams)!

        for paramsData in paramsToAdd {
            urlComponents.queryItems?.append(NSURLQueryItem(name: paramsData.key, value: paramsData.value as? String) as URLQueryItem)
        }
        return urlComponents.url!
    }
    
    
    func getCrashInfo() -> [String: Any]? {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let osName = UIDevice.current.systemName
        let udid = UIDevice.current.identifierForVendor?.uuidString
        let timestamp = Date.currentTimeStamp
        let timezone = TimeZone.current.abbreviation()!
        let dict = [APIParameterKey.app_name: displayName,
                    APIParameterKey.device_name: deviceModel,
                    APIParameterKey.os_version: "\(systemName) \(systemVersion)",
                    APIParameterKey.app_version: "\(shortVersion)(\(version))",
                    APIParameterKey.platform: osName,
                    APIParameterKey.device_id: udid!,
                    APIParameterKey.timestamp: timestamp,
                    APIParameterKey.timezone: timezone] as [String: Any]
        return dict
    }
    
    func getUniqueEntryData(fromExistingData arr1: [CGData], byComparingItWithNewEntryData arr2: [CGData]) -> [CGData] {
        var uniqueData: [CGData] = []
        for data in arr2 {
            if !arr1.contains(where: { model in
                model._id == data._id
            }) {
                uniqueData.append(data)
            }
        }
        
        return uniqueData
    }
    
    func validateCampaign(withCampaignID campaignID: String, in campaigns: [CGCampaigns]) -> Bool {
        for campaignsModel in campaigns {
            if campaignsModel.campaignId == campaignID {
                return true
            }
        }
        
        return false
    }
}
