//
//  File.swift
//  
//
//  Created by Himanshu Trehan on 22/07/21.
//

import Foundation

@objc(RegistrationModel)
public class RegistrationModel: NSObject, Codable {
    public var success: Bool?
    public var data: MyData?
}

@objc(MyData)
public class MyData: NSObject, Codable {
    public var token: String?
    public var user: User?
}

@objc(User)
public class User: NSObject, Codable {
    public var id: String?
    public var userId: String?
    public var anonymousId: String?
    public var gluId: String?
    public var userName: String?
    public var email: String?
    public var phone: String?
    public var cookieId: String?
    public var appVersion: String?
    public var client: String?
    public var referralLink: String?
    public var referredBy: String?
    public var identities: Identities?
    public var profile: Profile?
    public var sessionId: String?
    public var deviceId: String?
    public var deviceType: String?
    public var deviceName: String?
}

@objc(Identities)
public class Identities: NSObject, Codable {
    public var facebook_id: String?
    public var google_id: String?
    public var android_id: String?
    public var ios_id: String?
    public var clevertap_id: String?
    public var mparticle_id: String?
    public var segment_id: String?
    public var moengage_id: String?
}

@objc(Profile)
public class Profile: NSObject, Codable {
    public var firstName: String?
    public var lastName: String?
    public var age: String?
    public var city: String?
    public var country: String?
    public var timezone: String?
}
