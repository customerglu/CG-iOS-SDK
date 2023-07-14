//
//  APIFailureQueue.swift
//  
//
//  Created by Yasir on 14/07/23.
//

import Foundation

class APIFailureQueue {
    private let userDefaults = UserDefaults.standard
    private let queueKey = "APIFailureQueue"
    
    func enqueue(with failure: APIFailure) {
        var failures = listFailures()
        failures.append(failure)
        failures.sort(by: { $0.priority.value > $1.priority.value })
        registerFailures(failures)
    }
    
    func dequeue() -> Void {
        var failures = listFailures()
        guard failures.isNotEmpty else { return }
        
        failures.removeFirst()
        registerFailures(failures)
    }
    
    func listFailures() -> [APIFailure] {
        guard let data = userDefaults.data(forKey: queueKey) else {
            return []
        }

        let decoder = JSONDecoder()
        if let failures = try? decoder.decode([APIFailure].self, from: data) {
            return failures
        }
        
        return []
    }
    
    private func registerFailures(_ failures: [APIFailure]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(failures) {
            userDefaults.set(encodedData, forKey: queueKey)
        }
    }
}
