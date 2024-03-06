//
//  File.swift
//  
//
//  Created by Ankit Jain on 20/02/23.
//

import Foundation
@testable import CustomerGlu

// MARK: - ApplicationManagerMock
class ApplicationManagerMock: ApplicationManager {
    var apiCalled: Bool = false
    private var parent: ApplicationManager?
    
    init(parent: ApplicationManager) {
        super.init()
        apiCalled = false
        self.parent = parent
        
        APIManager.shared.crashReport(queryParameters: NSDictionary()) { result in
            print("result")
        }
    }
    
    func testMyCode() {
        
    }
    
}
