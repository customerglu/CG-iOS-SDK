//
//  File.swift
//  
//
//  Created by Ankit Jain on 06/03/23.
//

import Foundation

struct CGMqttConfig {
    var username: String!
    var password: String!
    var serverHost: String!
    /*
     - The topics to be subscribed in MQTT are as follows -
         - **User level**   `/nudges/<client-id>/sha256(userID)` (Used for Event based Nudges)
         - **Client level**  `/state/global/<client-id>`
     */
    var topics: [String]!
    var port: UInt16!
    var mqttIdentifier: String!
    
    init(username: String, password: String, serverHost: String, topics: [String], port: UInt16, mqttIdentifier: String) {
        self.username = username
        self.password = password
        self.serverHost = serverHost
        self.topics = topics
        self.port = port
        self.mqttIdentifier = mqttIdentifier
    }
}
