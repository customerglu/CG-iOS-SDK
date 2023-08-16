//
//  File.swift
//  
//
//  Created by Ankit Jain on 20/02/23.
//

import Foundation

// MARK: - CGLoggingSource
@objc(_TtC11CustomerGluP33_BD69E12B0D4BBE8C2A272B8204C8B2AE15CGLoggingSource) class CGLoggingSource: NSObject, NSCoding {
    var sourceClass: String?
    var sourceMethod: String?
    
    init(sourceClass: String?, sourceMethod: String?) {
        self.sourceClass = sourceClass
        self.sourceMethod = sourceMethod
    }
    
    required init(coder aDecoder: NSCoder) {
        sourceClass = aDecoder.decodeObject(forKey: "source_class") as? String
        sourceMethod = aDecoder.decodeObject(forKey: "source_method") as? String
    }
    
    func encode(with coder: NSCoder) {
        if sourceClass != nil {
            coder.encode(sourceClass, forKey: "source_class")
        }
        
        if sourceMethod != nil {
            coder.encode(sourceMethod, forKey: "source_method")
        }
    }
}

// MARK: - CGLogEventType
enum CGLogEventType: Int {
    case serviceCall
}

// MARK: - CGLoggingConstant
struct CGLoggingConstant {
    static let success = "success"
    static let failure = "failure"
}

// MARK: - CGLoggingMessage
@objc(_TtC11CustomerGluP33_BD69E12B0D4BBE8C2A272B8204C8B2AE16CGLoggingMessage) class CGLoggingMessage: NSObject, NSCoding {
    
    static let shared: CGLoggingMessage = CGLoggingMessage()
    
    var eventType: CGLogEventType?
    var source: CGLoggingSource?
    var logMessage: String?
    var parameters: [String: Any]?
    
    func logMessage(eventType: CGLogEventType, source: CGLoggingSource, logMessage: String, parameters: [String: Any]?) {
        self.eventType = eventType
        self.source = source
        self.logMessage = logMessage
        self.parameters = parameters
    }
    
    private override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        eventType = aDecoder.decodeObject(forKey: "event_type") as? CGLogEventType
        source = aDecoder.decodeObject(forKey: "source") as? CGLoggingSource
        logMessage = aDecoder.decodeObject(forKey: "log_message") as? String
    }
    
    func encode(with coder: NSCoder) {
        if eventType != nil {
            coder.encode(eventType, forKey: "event_type")
        }
        
        if source != nil {
            coder.encode(source, forKey: "source")
        }
        
        if logMessage != nil {
            coder.encode(logMessage, forKey: "log_message")
        }
    }
    
    func isRunningTests() -> Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return true
        }
        return false
    }
    
    private func getFileURL(fileName: String) -> URL? {
        var dirURL: URL?
        do {
            dirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch _ {
            
        }
        
        return dirURL?.appendingPathComponent(fileName)
    }
    
//    func readLastLog() -> CGLoggingMessage? {
//        guard let filePath = getFileURL(fileName: "data.dat")?.path else {
//            return nil
//        }
//
//        // read from file
//        let model = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? CGLoggingMessage
//        return model
//    }
//
//    private func writeToFile() {
//        guard let filePath = getFileURL(fileName: "data.dat")?.path else {
//            return
//        }
//
//        // write to file
//        NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
//    }
}

// MARK: - CGLogUtility
class CGLogUtility {
    class func classNameAsString(_ obj: Any) -> String {
        //prints more readable results for dictionaries, arrays, Int, etc
        return String(describing: type(of: obj))
    }
}
