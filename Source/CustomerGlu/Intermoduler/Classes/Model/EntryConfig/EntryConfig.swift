//
//	EntryConfig.swift
//
//	Create by Mukesh Yadav on 19/4/2022

import Foundation

public struct EntryConfig: Codable {
    var data: EntryPointId?
    var success: Bool?
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        if let dataData = dictionary["data"] as? [String:Any]{
            data = EntryPointId(fromDictionary: dataData)
        }
        success = dictionary["success"] as? Bool
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if data != nil{
            dictionary["data"] = data!.toDictionary()
        }
        if success != nil{
            dictionary["success"] = success
        }
        return dictionary
    }
}

public struct EntryPointId: Codable {
    
    var activityIdList: EntryConfigData?
    var embedIds: EntryConfigData?
    var bannerIds: EntryConfigData?

    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        if let dataData = dictionary["activityIdList"] as? [String:Any]{
            activityIdList = EntryConfigData(fromDictionary: dataData)
        }
        if let dataData = dictionary["embedIds"] as? [String:Any]{
            embedIds = EntryConfigData(fromDictionary: dataData)
        }
        if let dataData = dictionary["bannerIds"] as? [String:Any]{
            bannerIds = EntryConfigData(fromDictionary: dataData)
        }
//        activityIdList = dictionary["activityIdList"] as? [String:Any]
//        embedIds = dictionary["embedIds"] as? [String:Any]
//        bannerIds = dictionary["bannerIds"] as? [String:Any]
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if activityIdList != nil{
            dictionary["activityIdList"] = activityIdList!.toDictionary()
        }
        if embedIds != nil{
            dictionary["embedIds"] = embedIds!.toDictionary()
        }
        if bannerIds != nil{
            dictionary["bannerIds"] = bannerIds!.toDictionary()
        }
        return dictionary
    }
}

public struct EntryConfigData: Codable {
    
    var android: [String]?
    var ios: [String]?
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        android = dictionary["android"] as? [String]
        ios = dictionary["ios"] as? [String]
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if android != nil{
            dictionary["android"] = android
        }
        if ios != nil{
            dictionary["ios"] = ios
        }
        return dictionary
    }
}
