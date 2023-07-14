//
//  BackgroundTaskManager.swift
//  
//
//  Created by Yasir on 14/07/23.
//

import Foundation
import BackgroundTasks

@available(iOS 13.0, *)
class BackgroundTaskManager {
    var backgroundTaskIdentifier: String
    static let shared = BackgroundTaskManager(backgroundTaskIdentifier: "")
    
    private init(backgroundTaskIdentifier: String) {
        self.backgroundTaskIdentifier = backgroundTaskIdentifier
    }
    
    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: .main, launchHandler: handleTask(_:))
    }
    
    func handleTask(_ task: BGTask) {
        scheduleAppRefresh()

        APIFailureMonitor.shared.startObservation()
        task.setTaskCompleted(success: true)

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch(let error) {
            print("Failed to schedule the background task with error : \(error.localizedDescription)")
        }
    }
}


