//
//  CGEventsDiagnosticsHelperTests.swift
//
//
//  Created by Ankit Jain on 20/02/23.
//

import XCTest
@testable import CustomerGlu

// MARK: - CGEventsDiagnosticsHelperTests
final class CGEventsDiagnosticsHelperTests: CGBaseTestCase {

    var eventsDiagnosticsHelper: CGEventsDiagnosticsHelperMock?
    
    // MARK: - Setup Methods
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        eventsDiagnosticsHelper = CGEventsDiagnosticsHelperMock(parent: CGEventsDiagnosticsHelper.shared)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        eventsDiagnosticsHelper = nil
    }

    // MARK: - Test Methods
    func test_SendDiagnosticsReport_test1() {
        guard let eventsDiagnosticsHelper = eventsDiagnosticsHelper else {
            // To fail the test case
            failTestCase()
            return
        }
        
        // Given
        let eventName = CGDiagnosticConstants.CG_DIAGNOSTICS_LOAD_CAMPAIGN_START
        let eventType = CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS
        var eventData: [String: Any] = [:]
        eventData["token"] = "1234567890"
        
        // Call
        eventsDiagnosticsHelper.sendDiagnosticsReport(eventName: eventName, eventType: eventType, eventMeta: eventData)
        
        // Verify
        XCTAssertTrue(eventsDiagnosticsHelper.sendDiagnosticsReportCalled)
        XCTAssertTrue(CGLoggingMessage.shared.eventType == .serviceCall)
        
        if let source = CGLoggingMessage.shared.source {
            XCTAssertTrue(source.sourceClass ?? "" == "CGEventsDiagnosticsHelper")
            XCTAssertTrue(source.sourceMethod ?? "" == "sendDiagnosticsReport")
        } else {
            // To fail the test case
            failTestCase()
        }
        
        if let logMessage = CGLoggingMessage.shared.logMessage {
            XCTAssertTrue(logMessage == CGLoggingConstant.failure)
        } else {
            // To fail the test case
            failTestCase()
        }
        
        if let parameters = CGLoggingMessage.shared.parameters {
            XCTAssertTrue(parameters["eventName"] as! String == CGDiagnosticConstants.CG_DIAGNOSTICS_LOAD_CAMPAIGN_START)
            XCTAssertTrue(parameters["eventType"] as! String == CGDiagnosticConstants.CG_TYPE_DIAGNOSTICS)
        } else {
            // To fail the test case
            failTestCase()
        }
    }
}
