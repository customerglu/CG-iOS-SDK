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
    
    func dictToObject <T: Decodable>(dict: Dictionary<String, Any>, type: T.Type) -> T? {
        do {
            // Convert Dictionary to JSON Data
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            
            // Decode data to model object
            let jsonDecoder = JSONDecoder()
            let object = try jsonDecoder.decode(type, from: jsonData)
            return object
        } catch let error { // response with error
            print("JSON decode failed: \(error.localizedDescription)")
            return nil
        }
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
}
