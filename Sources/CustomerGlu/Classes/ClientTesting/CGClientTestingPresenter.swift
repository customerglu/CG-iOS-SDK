//
//  CGClientTestingViewModel.swift
//  
//
//  Created by Ankit Jain on 22/02/23.
//

import UIKit
import WebKit

// MARK: - CGClientTestingStatus
public enum CGClientTestingStatus: Int {
    case header
    case pending
    case success
    case failure
}

// MARK: - CGCustomAlertTag
public enum CGCustomAlertTag: Int {
    case callbackHandingTag = 1001
    case nudgeHandlingTag = 1002
    case onelinkHandlingTag = 1003
}

// MARK: - CGClientTestingRowItem
public enum CGClientTestingRowItem {
    case basicIntegration(status: CGClientTestingStatus)
    case sdkInitialised(status: CGClientTestingStatus)
    case userRegistered(status: CGClientTestingStatus)
    case callbackHanding(status: CGClientTestingStatus)
    case advanceIntegration(status: CGClientTestingStatus)
    case nudgeHandling(status: CGClientTestingStatus)
    case onelinkHandling(status: CGClientTestingStatus)
    case entryPointSetup(status: CGClientTestingStatus)
    case entryPointScreeNameSetup(status: CGClientTestingStatus)
    case entryPointBannerIDSetup(status: CGClientTestingStatus)
    case entryPointEmbedIDSetup(status: CGClientTestingStatus)
    
    func getTitle() -> String {
        switch self {
        case .basicIntegration:
            return "Basic Integration"
        case .sdkInitialised:
            return "SDK Initialised"
        case .userRegistered:
            return "User Registered"
        case .callbackHanding:
            return "Callback Handing"
        case .advanceIntegration:
            return "Advance Integration"
        case .nudgeHandling:
            return "Nudge Handling"
        case .onelinkHandling:
            return "Onelink Handling"
        case .entryPointSetup:
            return "Entry Point Set up"
        case .entryPointScreeNameSetup:
            return "Entry Point Screen Name Set up"
        case .entryPointBannerIDSetup:
            return "Entry Point BannerId Set up"
        case .entryPointEmbedIDSetup:
            return "Entry Point EmbedId Set up"
        }
    }
    
    func getStatus() -> CGClientTestingStatus {
        switch self {
        case .basicIntegration(let status):
            return status
        case .sdkInitialised(let status):
            return status
        case .userRegistered(let status):
            return status
        case .callbackHanding(let status):
            return status
        case .advanceIntegration(let status):
            return status
        case .nudgeHandling(let status):
            return status
        case .onelinkHandling(let status):
            return status
        case .entryPointSetup(let status):
            return status
        case .entryPointScreeNameSetup(let status):
            return status
        case .entryPointBannerIDSetup(let status):
            return status
        case .entryPointEmbedIDSetup(let status):
            return status
        }
    }
    
    func getAlertTitleAndMessage() -> (title: String, message: String, tag: Int)? {
        switch self {
        case .basicIntegration:
            return nil
        case .sdkInitialised:
            return nil
        case .userRegistered:
            return nil
        case .callbackHanding:
            return ("CustomerGlu", "Do you receive callback?", CGCustomAlertTag.callbackHandingTag.rawValue)
        case .advanceIntegration:
            return nil
        case .nudgeHandling:
            return ("CustomerGlu", "Do you see a nudge?", CGCustomAlertTag.nudgeHandlingTag.rawValue)
        case .onelinkHandling:
            return ("CustomerGlu", "Has CG Deeplink successfully redirected?", CGCustomAlertTag.onelinkHandlingTag.rawValue)
        case .entryPointSetup:
            return nil
        case .entryPointScreeNameSetup:
            return nil
        case .entryPointBannerIDSetup:
            return nil
        case .entryPointEmbedIDSetup:
            return nil
        }
    }
    
    func getDocumentationURL() -> URL? {
        switch self {
        case .basicIntegration:
            return nil
        case .sdkInitialised:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#initialise-sdk")
        case .userRegistered:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#register-user-mandatory")
        case .callbackHanding:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#handling-events")
        case .advanceIntegration:
            return nil
        case .nudgeHandling:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#handle-customerglu-nudges")
        case .onelinkHandling:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#handling-events")
        case .entryPointSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#enable-entry-points")
        case .entryPointScreeNameSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#setting-up-floating-buttons-and-popups")
        case .entryPointBannerIDSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#setting-up-banners")
        case .entryPointEmbedIDSetup:
            return URL(string: "https://docs.customerglu.com/sdk/mobile-sdks#setting-up-embed-view")
        }
    }
}

// MARK: - CGClientTestingProtocol
public protocol CGClientTestingProtocol: NSObjectProtocol {
    func updateTable(atIndexPath indexPath: IndexPath, forEvent event: CGClientTestingRowItem)
    func showCallBackAlert(forEvent event: CGClientTestingRowItem, isRetry: Bool)
    func testOneLinkDeeplink(withDeeplinkURL deeplinkURL: String)
}

// MARK: - CGClientTestingViewModel
public class CGClientTestingViewModel: NSObject {
    
    weak var delegate: CGClientTestingProtocol?
    var eventsSectionsArray: [CGClientTestingRowItem] = [.basicIntegration(status: .header), .sdkInitialised(status: .pending), .userRegistered(status: .pending), .callbackHanding(status: .pending), .advanceIntegration(status: .header), .nudgeHandling(status: .pending), .onelinkHandling(status: .pending), .entryPointSetup(status: .pending), .entryPointScreeNameSetup(status: .pending), .entryPointBannerIDSetup(status: .pending), .entryPointEmbedIDSetup(status: .pending)]
    
    func numberOfSections() -> Int {
        1
    }
    
    func numberOfCells(forSection section: Int) -> Int {
        switch section {
        case 0:
            return eventsSectionsArray.count
        default:
            return 0
        }
    }
    
    func getRowItemForEventsSection(withIndexPath indexPath: IndexPath) -> CGClientTestingRowItem {
        eventsSectionsArray[indexPath.row]
    }
    
    func getIndexOfItem(_ item: CGClientTestingRowItem) -> (index: Int?, indexPath: IndexPath?) {
        let firstIndex = eventsSectionsArray.firstIndex { event in
            event.getTitle() == item.getTitle()
        }
        
        var indexPath: IndexPath?
        if let index = firstIndex {
            indexPath = IndexPath(row: index, section: 0)
        }
        
        return (firstIndex, indexPath)
    }
    
    private func updateTableDelegate(atIndexPath indexPath: IndexPath, forEvent event: CGClientTestingRowItem) {
        if let delegate = delegate {
            delegate.updateTable(atIndexPath: indexPath, forEvent: event)
        }
    }
    
    private func showCallBackAlert(forEvent event: CGClientTestingRowItem, isRetry: Bool) {
        // Wait 5 seconds and than perform this action
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if let delegate = self.delegate {
                delegate.showCallBackAlert(forEvent: event, isRetry: isRetry)
            }
        }
    }
        
    // MARK: - Event Execution Methods
    func executeClientTesting() {
        // Execute SDKInitialised
        let itemInfo = getIndexOfItem(.sdkInitialised(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

        if CustomerGlu.getInstance.appconfigdata != nil {
            eventsSectionsArray[index] = .sdkInitialised(status: .success)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
            
            // Execute next event
            executeUserRegistered()
        } else {
            eventsSectionsArray[index] = .sdkInitialised(status: .failure)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
        }
    }
    
    func executeUserRegistered() {
        let itemInfo = getIndexOfItem(.userRegistered(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
        
        if CustomerGlu.getInstance.cgUserData.userId != nil {
            eventsSectionsArray[index] = .userRegistered(status: .success)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])

            // Execute all event
            executecallbackHanding()
        } else {
            eventsSectionsArray[index] = .userRegistered(status: .failure)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
        }
    }
    
    func executecallbackHanding(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.callbackHanding(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
                        
        let webController = CustomerWebViewController()
        let message: WKScriptMessage = WKScriptMessage()
        
        if let callbackConfigurationUrl = CustomerGlu.getInstance.appconfigdata?.callbackConfigurationUrl {
            let eventLinkData = CGEventLinkData(deepLink: callbackConfigurationUrl)
            let model = CGDeepLinkModel(eventName: "OPEN_DEEPLINK", data: eventLinkData)
            
            do {
                let jsonData = try JSONEncoder().encode(model)

                var diagnosticsEventData: [String: Any] = [:]
                webController.handleDeeplinkEvent(withEventName: WebViewsKey.open_deeplink, bodyData: jsonData, message: message, diagnosticsEventData: &diagnosticsEventData)

                // just show alert - Yes show green tick - No show cross UI
                // Add retry button next to call back, nudge and onelink
                // Retry only for NETWORK_EXCEPTION
                
                eventsSectionsArray[index] = .callbackHanding(status: .pending)
                updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])

                // Wait 5 seconds and than perform this action & Next step NudgeHandling will happen on alert response Yes or No
                self.showCallBackAlert(forEvent: eventsSectionsArray[index], isRetry: isRetry)
            } catch {
                // nothing
            }
        }
    }
    
    func executeNudgeHandling(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.nudgeHandling(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

        var queryParameters: [String: Any] = [:]
        queryParameters[APIParameterKey.userId] = CustomerGlu.getInstance.cgUserData.userId
        if CustomerGlu.fcm_apn != "fcm" {
            queryParameters["flag"] = "staging"
        }
        
        APIManager.nudgeIntegration(queryParameters: queryParameters as NSDictionary) {[weak self] result in
            switch result {
            case .success(_):
                let event: CGClientTestingRowItem = .nudgeHandling(status: .pending)
                // Wait 5 seconds and than perform this action
                self?.showCallBackAlert(forEvent: event, isRetry: isRetry)
            case .failure(_):
                let event: CGClientTestingRowItem = .nudgeHandling(status: .failure)
                self?.eventsSectionsArray[index] = event
                self?.updateTableDelegate(atIndexPath: indexPath, forEvent: event)
                
                // Execute next steps
                self?.executeOnelinkHandling()
            }
        }
    }
    
    @objc func executeOnelinkHandling(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.onelinkHandling(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
        
        if let callbackConfigurationUrl = CustomerGlu.getInstance.appconfigdata?.callbackConfigurationUrl {
            if let delegate = self.delegate {
                delegate.testOneLinkDeeplink(withDeeplinkURL: callbackConfigurationUrl)
            }

            // Wait 5 seconds and than perform this action
            self.showCallBackAlert(forEvent: .onelinkHandling(status: .pending), isRetry: isRetry)
        } else {
            eventsSectionsArray[index] = .onelinkHandling(status: .failure)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
            
            // Execute next steps
            executeEntryPointSetup()
        }
    }

    func executeEntryPointSetup(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.entryPointSetup(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

        if let enableEntryPoints = CustomerGlu.getInstance.appconfigdata?.enableEntryPoints, enableEntryPoints {
            eventsSectionsArray[index] = .entryPointSetup(status: .success)
        } else {
            eventsSectionsArray[index] = .entryPointSetup(status: .failure)
        }
        updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
        
        if !isRetry {
            // Execute next steps +2 second to avoid app crash on reload table
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.executeEntryPointScreenNameSetup()
            }
        }
    }
    
    func executeEntryPointScreenNameSetup(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.entryPointScreeNameSetup(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

        if let activityIdList = CustomerGlu.getInstance.appconfigdata?.activityIdList, let ios = activityIdList.ios, !ios.isEmpty {
            eventsSectionsArray[index] = .entryPointScreeNameSetup(status: .success)
        } else {
            eventsSectionsArray[index] = .entryPointScreeNameSetup(status: .failure)
        }
        updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
        
        if !isRetry {
            // Execute next steps +2 second to avoid app crash on reload table
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.executeEntryPointBannerIDSetup()
            }
        }
    }
    
    func executeEntryPointBannerIDSetup(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.entryPointBannerIDSetup(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

        if let bannerIds = CustomerGlu.getInstance.appconfigdata?.bannerIds, let ios = bannerIds.ios, !ios.isEmpty {
            eventsSectionsArray[index] = .entryPointBannerIDSetup(status: .success)
        } else {
            eventsSectionsArray[index] = .entryPointBannerIDSetup(status: .failure)
        }
        updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
        
        if !isRetry {
            // Execute next steps +2 second to avoid app crash on reload table
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.executeEntryPointEmbedIDSetup()
            }
        }
    }
    
    func executeEntryPointEmbedIDSetup(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.entryPointEmbedIDSetup(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

        if let embedIds = CustomerGlu.getInstance.appconfigdata?.embedIds, let ios = embedIds.ios, !ios.isEmpty {
            eventsSectionsArray[index] = .entryPointEmbedIDSetup(status: .success)
        } else {
            eventsSectionsArray[index] = .entryPointEmbedIDSetup(status: .failure)
        }
        updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
    }
}
