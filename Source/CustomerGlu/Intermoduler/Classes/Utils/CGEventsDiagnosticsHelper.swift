//
//  File.swift
//  
//
//  Created by Kausthubh adhikari on 13/02/23.
//

import Foundation

public class CGEventsDiagnosticsHelper {
   static let shared = CGEventsDiagnosticsHelper()
    
    
    /***
        Sending DIagnostics events 
     */
    func sendDiagnosticsReport(eventName: String, eventType: String, eventMeta:[String:Any]){
        
        if eventType == CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS && !(CustomerGlu.isDiagnosticsEnabled ?? false){
            return
        }
        
        if eventType == CGDiagnosticConstants.CG_TYPE_METRICS && !(CustomerGlu.isMetricsEnabled ?? true){
            return
        }
        
        if (eventType == CGDiagnosticConstants.CG_TYPE_CRASH || eventType == CGDiagnosticConstants.CG_TYPE_EXCEPTION) && !(CustomerGlu.isCrashLogsEnabled ?? true) {
            return
        }
        
        if let sdkIsDisabled = CustomerGlu.sdk_disable, !sdkIsDisabled {
            ApplicationManager.sendEventsDiagnostics(eventLogType: eventType, eventName: eventName, eventMeta: eventMeta, completion: { [self] success, diagnosticsEventResponse in
                if success {
                    print(eventName+" SuccessFully sent")
                }else {
                    print(eventName+" Failure in sending")
                }
            })
            
        }
    }
    
    /***
        Sending Multiple Diagnostics event types
     */
    func sendMultipleDiagnosticsReport(eventName: String, eventTypes: [String], eventMeta:[String:Any]) {
        for eventType in eventTypes {
            sendDiagnosticsReport(eventName: eventName, eventType: eventType, eventMeta: eventMeta)
        }
    }
}
