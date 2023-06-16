//
//  CGOtherUtilsTests.swift
//  
//
//  Created by Ankit Jain on 08/05/23.
//

import XCTest
@testable import CustomerGlu

// MARK: - CGOtherUtilsTests
final class CGOtherUtilsTests: CGBaseTestCase {
    var otherUtils: OtherUtils?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        otherUtils = OtherUtils.shared
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConvertToDictionary() {
        // CASE 1 :: Valid JSON
        let jsonText = "{\"data\":{\"bannerID\":\"BANNER_ID_TEST\",\"pref_url\":\"about:config\"}}"
        let dict = otherUtils?.convertToDictionary(text: jsonText)
        if let dict {
            XCTAssertTrue(((dict["data"] as? [AnyHashable: Any]) != nil))
            
            let data = dict["data"] as? [AnyHashable: Any] ?? [:]
            XCTAssertTrue(data["bannerID"] as! String == "BANNER_ID_TEST")
            XCTAssertTrue(data["pref_url"] as! String == "about:config")
        } else {
            XCTAssertThrowsError("Failed to convert Json to Dict")
        }
        
        // CASE 2 :: Invalid JSON String
        let invalidJsonText = "{\"data\"{\"bannerID\"\"BANNER_ID_TEST\"\"pref_url\":\"about:config\"}}"
        let invalidDict = otherUtils?.convertToDictionary(text: invalidJsonText)
        XCTAssertNil(invalidDict)
    }
    
    func testGetCrashInfo() {
        let crashInfo = otherUtils?.getCrashInfo()
        XCTAssertNotNil(crashInfo)
        
        if let crashInfo {
            XCTAssertNotNil(crashInfo["os_version"])
            XCTAssertNotNil(crashInfo["app_name"])
            XCTAssertNotNil(crashInfo["platform"])
            XCTAssertNotNil(crashInfo["timezone"])
            XCTAssertNotNil(crashInfo["app_version"])
            XCTAssertNotNil(crashInfo["device_name"])
            XCTAssertNotNil(crashInfo["timestamp"])
            XCTAssertNotNil(crashInfo["device_id"])
        }
    }
    
    func testGetUniqueEntryData() {
        // Construct Data
        let data1 = CGData(fromDictionary: ["_id": "1"])
        let data2 = CGData(fromDictionary: ["_id": "2"])
        let data3 = CGData(fromDictionary: ["_id": "3"])
        let data4 = CGData(fromDictionary: ["_id": "4"])
        
        // CASE 1 :: Return Unique Data
        // Input Array
        var inputDataArray1: [CGData] = [data1, data2, data3]
        var inputDataArray2: [CGData] = [data1, data3, data4]
        
        // Here the comparision is to get all unique data in array2 when compared to array1 -> So output should return data4
        var outputDataArray = otherUtils?.getUniqueEntryData(fromExistingData: inputDataArray1, byComparingItWithNewEntryData: inputDataArray2) ?? []
        XCTAssertTrue(outputDataArray.count > 0)
        XCTAssertTrue(outputDataArray[0]._id == "4")
        
        
        // CASE 2 :: Return No Unique Data
        inputDataArray1 = [data1, data2, data3, data4]
        inputDataArray2 = [data1, data3, data4]
        
        // Here the comparision is to get all unique data in array2 when compared to array1 -> So output will not return any unique data
        outputDataArray = otherUtils?.getUniqueEntryData(fromExistingData: inputDataArray1, byComparingItWithNewEntryData: inputDataArray2) ?? []
        XCTAssertTrue(outputDataArray.count == 0)
    }
    
    func testValidateCampaign() {
        // Case 1 - Invalid Campaign ID
        let campaign1 = CGCampaigns()
        campaign1.campaignId = "9"
        
        let campaign2 = CGCampaigns()
        campaign2.campaignId = "8"
        
        let campaign3 = CGCampaigns()
        campaign3.campaignId = "9"
        
        var campaigns: [CGCampaigns] = [campaign1, campaign2, campaign3]
        
        if let invalidCampaignFlag = otherUtils?.validateCampaign(withCampaignID: "123456", in: campaigns) {
            XCTAssertFalse(invalidCampaignFlag)
        }
        
        // Case 2 - Valid Campaign ID
        let campaign4 = CGCampaigns()
        campaign4.campaignId = "123456"
        
        campaigns = [campaign1, campaign2, campaign3, campaign4]
        
        if let validCampaignFlag = otherUtils?.validateCampaign(withCampaignID: "123456", in: campaigns) {
            XCTAssertTrue(validCampaignFlag)
        }
    }
    
    func testGetListOfScreenNames() {
        // Case 1 - Wild Card
        var screenNames = OtherUtils.shared.getListOfScreenNames(from: "*")
        XCTAssertTrue(screenNames.count == 1)
        
        // Case 2
        screenNames = OtherUtils.shared.getListOfScreenNames(from: "Home")
        XCTAssertTrue(screenNames.count == 1)
        
        // Case 3
        screenNames = OtherUtils.shared.getListOfScreenNames(from: "Home,Cart,Profile")
        XCTAssertTrue(screenNames.count == 3)
    }
    
    func testGetNudgeConfiguration() {
        // Input Data
        let inputModel = CGNudgeDataModel(fromDictionary: ["type": "CustomerGlu",
                                                           "client": "06319b7d-c724-49e5-8233-3cdbeea59c0e",
                                                           "campaignId": "38bcd854-0d48-430c-8a02-aed462e69092",
                                                           "userId": "6395edb98ffdbe671ceb8c71",
                                                           "notificationType": "push",
                                                           "pageType": "full-default",
                                                           "title": "Congrats! You won a reward! ✨Check it out.",
                                                           "body": "For referring a friend. Claim your Reward Now!",
                                                           "clickAction": "https://d3guhyj4wa8abr.cloudfront.net/reward/?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2Mzk1ZWRiOThmZmRiZTY3MWNlYjhjNzEiLCJjbGllbnQiOiIwNjMxOWI3ZC1jNzI0LTQ5ZTUtODIzMy0zY2RiZWVhNTljMGUiLCJpYXQiOjE2NzA3NzE2OTgsImV4cCI6MTcwMjMwNzY5OH0.nLuKuZc2fX4NIiCCVOh6yczHbbhphq-vfetS5bnpRak&campaignId=38bcd854-0d48-430c-8a02-aed462e69092&rewardUserId=bc4abbe4-c5b7-4fb3-9084-1b481c669510",
                                                           "image": "https://assets.customerglu.com/zolve/cards/scratch-card/card.png",
                                                           "timeRemaning": "",
                                                           "expiry": "",
                                                           "gluMessageType": "push",
                                                           "absoluteHeight": "1200",
                                                           "relativeHeight": "0",
                                                           "closeOnDeepLink": "false",
                                                           "nudgeId": "98472-32494fa-sdpo3-4kn423",
                                                           "screenNames": "*",
                                                           "opacity": "0.5",
                                                           "priority": "1",
                                                           "ttl": ""])
        
        // Test
        let nudgeConfiguration = OtherUtils.shared.getNudgeConfiguration(fromData: inputModel)
        XCTAssertTrue(nudgeConfiguration.layout == "full-default")
        XCTAssertTrue(nudgeConfiguration.absoluteHeight == 1200)
        XCTAssertTrue(nudgeConfiguration.relativeHeight == 0)
        XCTAssertFalse(nudgeConfiguration.closeOnDeepLink)
    }
    
    func testCheckTTLIsExpired() {
        // Case 1 - Tommorrow - Date is in future not expired
        if let tomorrow = Date().tomorrow?.timeIntervalSince1970 {
            XCTAssertFalse(OtherUtils.shared.checkTTLIsExpired("\(tomorrow)"))
        } else {
            // To fail the test
            XCTAssertTrue(1 == 0)
        }
        
        // Case 2 - Yesterday - Date is in Past expired
        if let yesterday = Date().yesterday?.timeIntervalSince1970 {
            XCTAssertTrue(OtherUtils.shared.checkTTLIsExpired("\(yesterday)"))
        }  else {
            // To fail the test
            XCTAssertTrue(1 == 0)
        }
        
        // Case 3 - Current Date
        let currentDate = Date().timeIntervalSince1970
        XCTAssertTrue(OtherUtils.shared.checkTTLIsExpired("\(currentDate)"))
    }
}
