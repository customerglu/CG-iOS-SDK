//
//  APIFailureMonitor.swift
//  
//
//  Created by Yasir on 14/07/23.
//

import Foundation

class APIFailureMonitor {
    static let shared = APIFailureMonitor()
    private let failureQueue = APIFailureQueue()
    private let dispatchGroup = DispatchGroup()
    private var observationState: APIObservationState = .neutral
    private var timer: Timer?
    
    private init() { }
    
    func startObservation() -> Void {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.startRetryProcess()
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func startRetryProcess() -> Void {
        guard failureQueue.listFailures().isNotEmpty, observationState == .neutral else { return }
        
        observationState = .observing
        let failedAPICalls = failureQueue.listFailures()
        
        for item in failedAPICalls {
            dispatchGroup.enter()
            makeRequest(with: item.param)
        }
        
        dispatchGroup.notify(queue: .main) {
            self.observationState = .neutral
        }
    }
    
    private func makeRequest(with param: NSDictionary) -> Void {
        APIManager.addToCart(queryParameters: param) { result in
            self.failureQueue.dequeue()
            self.dispatchGroup.leave()
        }
    }
}
