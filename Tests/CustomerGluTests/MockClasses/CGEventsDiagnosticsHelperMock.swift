//
//  File.swift
//  
//
//  Created by Ankit Jain on 20/02/23.
//

import Foundation
@testable import CustomerGlu

// MARK: - CGEventsDiagnosticsHelperMock
class CGEventsDiagnosticsHelperMock: CGEventsDiagnosticsHelper {
    var sendDiagnosticsReportCalled: Bool = false
     var parent: CGEventsDiagnosticsHelper
    
//    init(parent: CGEventsDiagnosticsHelper) {
//        super.init()
//        sendDiagnosticsReportCalled = false
//        self.parent = parent
//    }
    
    override func sendDiagnosticsReport(eventName: String, eventType: String, eventMeta:[String:Any]) {
        sendDiagnosticsReportCalled = true
//        self.parent.sendDiagnosticsReport(eventName: eventName, eventType: eventType, eventMeta: eventMeta)
    }
}
