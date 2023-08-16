//
//  CGMqttClientHelper.swift
//  
//
//  Created by Ankit Jain on 02/03/23.
//

import UIKit
import CommonCrypto

// MARK: - CGMqttLaunchScreenType
enum CGMqttLaunchScreenType: String {
    case ENTRYPOINT = "ENTRYPOINT" // Entrypoint API refresh
    case OPEN_CLIENT_TESTING_PAGE = "OPEN_CLIENT_TESTING_PAGE"
    case CAMPAIGN_STATE_UPDATED = "CAMPAIGN_STATE_UPDATED" // loadCampaign & Entrypoints API.
    case SDK_CONFIG_UPDATED = "SDK_CONFIG_UPDATED" // SDK Config Updation call & SDK re-initialised.
    case USER_SEGMENT_UPDATED = "USER_SEGMENT_UPDATED" // User re-registration.
}

// MARK: - CGMqttClientDelegate
protocol CGMqttClientDelegate: NSObjectProtocol {
    func openScreen(_ screenType: CGMqttLaunchScreenType, withMqttMessage mqttMessage: CGMqttMessage?)
}

//MARK: - CGMqttClientHelper
class CGMqttClientHelper: NSObject {
    static let shared = CGMqttClientHelper()
    
    private weak var delegate: CGMqttClientDelegate?
    private var client: LightMQTT?
    private var config: CGMqttConfig?
    
    /**
     * MQTT Client can be setup using the following parameters -
     *
     * @param config   - Pass all config requried for setting up Mqtt
     */
    func setupMQTTClient(withConfig config: CGMqttConfig, delegate: CGMqttClientDelegate) {
        // Save config for future reference and make it nil for disconnect state
        self.config = config
        
        // DIAGNOSTICS
        var eventData: [String: Any] = [:]
        eventData["username"] = config.username
        eventData["password"] = config.password
        eventData["serverHost"] = config.serverHost
        eventData["topics"] = config.topics
        eventData["port"] = config.port
        eventData["mqttIdentifier"] = config.mqttIdentifier
                
        // DIAGNOSTICS
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_INITIALIZE, eventType: CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        
        // METRICS
        CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_INITIALIZE, eventType: CGDiagnosticConstants.CG_TYPE_METRICS, eventMeta:["Initialize": "YES"])
        
        self.delegate = delegate
        
        DispatchQueue.main.async {
            var options = LightMQTT.Options()
            options.allowUntrustCACertificate = true
            options.useTLS = false
            options.securityLevel = .none
            options.networkServiceType = .background
            options.username = config.username
            options.password = config.password
            options.clientId = config.mqttIdentifier
            options.pingInterval = 30
            options.bufferSize = 4096
            options.readQosClass = .background

            self.client = LightMQTT(host: config.serverHost, options: options)
            guard let client = self.client else { return }
            
            client.connect() { success in
                // DIAGNOSTICS
                var eventData: [String: Any] = [:]
                eventData["username"] = config.username
                eventData["password"] = config.password
                eventData["serverHost"] = config.serverHost
                eventData["topics"] = config.topics
                eventData["port"] = config.port
                eventData["mqttIdentifier"] = config.mqttIdentifier
                
                let eventName = (success) ? CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_CONNECTION_SUCCESS : CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_CONNECTION_FAILURE
                CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: eventName, eventType: CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
                
                if success {
                    // use the client to subscribe to topics here
                    self.subscribeToTopics(topics: config.topics)
                }
            }
            
            client.receivingMessage = { (topic: String, message: String) in
                // parse buffer to JSON here
                
                DispatchQueue.main.async {
                    let jsonString = message.fromBase64() ?? ""
                    
                    // DIAGNOSTICS
                    CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_RECEIVING_MESSAGE, eventType: CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:["topic": topic, "message": message])
                    
                    // METRICS
                    CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_RECEIVING_MESSAGE, eventType: CGDiagnosticConstants.CG_TYPE_METRICS, eventMeta:["message": "YES"])
                    
                    let jsonData = Data(jsonString.utf8)
                    let decoder = JSONDecoder()
                    do {
                        if(jsonData.count > 0) {
                            let model = try decoder.decode(CGMqttMessage.self, from: jsonData)
                            if let delegate = self.delegate,
                                let type = model.type,
                                let screenType = CGMqttLaunchScreenType(rawValue: type) {
                                delegate.openScreen(screenType, withMqttMessage: model)
                            }
                        }
                    } catch {
                        // Add Diagnostics
                        //print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    /**
     * Subscription topic should be shared
     *
     * @param topic
     */
    func subscribeToTopics(topics: [String]) {
        guard let client = client else { return }
        
        for topic in topics {
            client.subscribe(to: topic)
            if CustomerGlu.isDebugingEnabled {
                print("Topic name \(topic)")
            }
            
            // DIAGNOSTICS
            var eventData: [String: Any] = [:]
            eventData["topic"] = topic
            
            CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_SUBSCRIBE, eventType: CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        }
    }
    
    func checkIsMQTTConnected() -> Bool {
        return client?.isConnected ?? false
    }
    
    func disconnectMQTT() {
        guard let client = self.client else { return }
        
        // DIAGNOSTICS
        if let config = config {
            var eventData: [String: Any] = [:]
            eventData["username"] = config.username
            eventData["password"] = config.password
            eventData["serverHost"] = config.serverHost
            eventData["topics"] = config.topics
            eventData["port"] = config.port
            eventData["mqttIdentifier"] = config.mqttIdentifier
            
            CGEventsDiagnosticsHelper.shared.sendDiagnosticsReport(eventName: CGDiagnosticConstants.CG_DIAGNOSTICS_MQTT_DISCONNECT, eventType:CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS, eventMeta:eventData)
        }
        
        // Disconnect
        client.disconnect()
        config = nil // reset the value
    }
}

// MARK: - Data
extension Data {
    public func sha256() -> String {
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

// MARK: - String
public extension String {
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}
