//
//  CGClientTestingViewModel.swift
//
//
//  Created by Ankit Jain on 22/02/23.
//

import UIKit
import WebKit

// MARK: - CGClientTestingProtocol
public protocol CGClientTestingProtocol: NSObjectProtocol {
    func updateTable(atIndexPath indexPath: IndexPath, forEvent event: CGClientTestingRowItem)
    func updateTable(atIndexPaths indexPaths: [IndexPath])
    func showCallBackAlert(forEvent event: CGClientTestingRowItem, isRetry: Bool)
    func testOneLinkDeeplink(withDeeplinkURL deeplinkURL: String)
    func reloadOnSDKNotificationConfigSuccess()
}

// MARK: - CGClientTestingViewModel
public class CGClientTestingViewModel: NSObject {
    
    weak var delegate: CGClientTestingProtocol?
    var eventsSectionsArray: [CGClientTestingRowItem] = []
    
    private var sdkTestStepsArray: [CGSDKTestStepsModel] = []
    var clientTestingModel: CGClientTestingModel?
    var testStepsResponseModel: CGSDKTestStepsResponseModel?
    var isRelaunch: Bool = false // On Deeplink relaunch use this flag
    
    public override init() {
        super.init()
        
        self.sdkTestStepsArray = []
        
        self.eventsSectionsArray = []
        eventsSectionsArray.append(.basicIntegration(status: .header))
        eventsSectionsArray.append(.sdkInitialised(status: .pending))
        eventsSectionsArray.append(.userRegistered(status: .pending))
        eventsSectionsArray.append(.callbackHanding(status: .pending))
        eventsSectionsArray.append(.advanceIntegration(status: .header))
        eventsSectionsArray.append(.firebaseSetup(status: .pending))
        eventsSectionsArray.append(.firebaseToken(status: .pending))
        eventsSectionsArray.append(.firebaseServerKey(status: .pending))
        eventsSectionsArray.append(.apnsDeviceToken(status: .pending))
        eventsSectionsArray.append(.privateKeyApns(status: .pending))
        eventsSectionsArray.append(.nudgeHandling(status: .pending))
        eventsSectionsArray.append(.cgDeeplinkHandling(status: .pending))
        eventsSectionsArray.append(.entryPointSetup(status: .pending))
        eventsSectionsArray.append(.entryPointScreeNameSetup(status: .pending))
        eventsSectionsArray.append(.entryPointBannerIDSetup(status: .pending))
        eventsSectionsArray.append(.entryPointEmbedIDSetup(status: .pending))
        
        // Make the API call
        self.onboardingSDKNotificationConfig()
    }
    
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
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: eventsSectionsArray[index], status: .success))
            
            // Execute next event
            executeUserRegistered()
        } else {
            eventsSectionsArray[index] = .sdkInitialised(status: .failure)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: eventsSectionsArray[index], status: .failure))
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
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: eventsSectionsArray[index], status: .success))
        } else {
            eventsSectionsArray[index] = .userRegistered(status: .failure)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: eventsSectionsArray[index], status: .failure))
        }
    }
    
    func executecallbackHanding(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.callbackHanding(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
        
        if let _ = CustomerGlu.getInstance.appconfigdata?.callbackConfigurationUrl {
            // just show alert - Yes show green tick - No show cross UI
            // Add retry button next to call back, nudge and onelink
            // Retry only for NETWORK_EXCEPTION
            
            eventsSectionsArray[index] = .callbackHanding(status: .pending)
            updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: eventsSectionsArray[index], status: .success))
            
            // Wait 5 seconds and than perform this action & Next step NudgeHandling will happen on alert response Yes or No
            if isRelaunch {
                eventsSectionsArray[index] = .callbackHanding(status: .success)
                updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
                
                // Record Test Steps
                updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: eventsSectionsArray[index], status: .success))
                
                //Execute Next Step
                executeNudgeHandling()
            } else {
                self.showCallBackAlert(forEvent: eventsSectionsArray[index], isRetry: isRetry)
            }
        } else {
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: .callbackHanding(status: .failure), status: .failure))
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
                
                // Record Test Steps
                self?.updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .success))
                
                // Wait 5 seconds and than perform this action
                self?.showCallBackAlert(forEvent: event, isRetry: isRetry)
            case .failure(_):
                let event: CGClientTestingRowItem = .nudgeHandling(status: .failure)
                self?.eventsSectionsArray[index] = event
                self?.updateTableDelegate(atIndexPath: indexPath, forEvent: event)
                
                // Record Test Steps
                self?.updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .success))
                
                // Execute next steps
                self?.executeCGDeeplinkHandling()
            }
        }
    }
    
    @objc func executeCGDeeplinkHandling(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.cgDeeplinkHandling(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }
        
        if let callbackConfigurationUrl = CustomerGlu.getInstance.appconfigdata?.callbackConfigurationUrl {
            if let delegate = self.delegate {
                delegate.testOneLinkDeeplink(withDeeplinkURL: callbackConfigurationUrl)
            }

            let event: CGClientTestingRowItem = .cgDeeplinkHandling(status: .pending)

            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .success))

            // Wait 5 seconds and than perform this action
            self.showCallBackAlert(forEvent: event, isRetry: isRetry)
        } else {
            let event: CGClientTestingRowItem = .cgDeeplinkHandling(status: .failure)
            eventsSectionsArray[index] = event
            updateTableDelegate(atIndexPath: indexPath, forEvent: event)
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .failure))
            
            // Execute next steps
            executeEntryPointSetup()
        }
    }

    func executeEntryPointSetup(isRetry: Bool = false) {
        let itemInfo = getIndexOfItem(.entryPointSetup(status: .pending))
        guard let index = itemInfo.index, let indexPath = itemInfo.indexPath else { return }

        if let enableEntryPoints = CustomerGlu.getInstance.appconfigdata?.enableEntryPoints, enableEntryPoints {
            let event: CGClientTestingRowItem = .entryPointSetup(status: .success)
            eventsSectionsArray[index] = event
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .success))
        } else {
            let event: CGClientTestingRowItem = .entryPointSetup(status: .failure)
            eventsSectionsArray[index] = event
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .failure))
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
            let event: CGClientTestingRowItem = .entryPointScreeNameSetup(status: .success)
            eventsSectionsArray[index] = event
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .success))
        } else {
            let event: CGClientTestingRowItem = .entryPointScreeNameSetup(status: .failure)
            eventsSectionsArray[index] = event

            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .failure))
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
            let event: CGClientTestingRowItem = .entryPointBannerIDSetup(status: .success)
            eventsSectionsArray[index] = event
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .success))
        } else {
            let event: CGClientTestingRowItem = .entryPointBannerIDSetup(status: .failure)
            eventsSectionsArray[index] = event
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .failure))
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
            let event: CGClientTestingRowItem = .entryPointEmbedIDSetup(status: .success)
            eventsSectionsArray[index] = event

            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .success))
        } else {
            let event: CGClientTestingRowItem = .entryPointEmbedIDSetup(status: .failure)
            eventsSectionsArray[index] = event
            
            // Record Test Steps
            updateSdkTestStepsArray(withModel:CGSDKTestStepsModel(name: event, status: .failure))
        }
        updateTableDelegate(atIndexPath: indexPath, forEvent: eventsSectionsArray[index])
        
        // Make the SDK Test Steps API Call
        onboardingSDKTestSteps()
    }
    
    private func updateSdkTestStepsArray(withModel model: CGSDKTestStepsModel) {
        if let index = sdkTestStepsArray.firstIndex(where: { result in
            result.name?.getSDKTestStepName() == model.name?.getSDKTestStepName()
        }) {
            // if already exist replace it
            sdkTestStepsArray[index] = model
        } else {
            // Else add it to array
            sdkTestStepsArray.append(model)
        }
    }
    
    // MARK: - API Calls
    func onboardingSDKNotificationConfig() {
        guard let userId = CustomerGlu.getInstance.cgUserData.userId else { return }
        let queryParameters: [String: Any] = [APIParameterKey.userId: userId]
        
        APIManager.onboardingSDKNotificationConfig(queryParameters: queryParameters as NSDictionary) { result in
            switch result {
            case .success(let response):
                self.clientTestingModel = response
                
                var firebaseSetupEvent: CGClientTestingRowItem = .firebaseSetup(status: .failure)
                var firebaseTokenEvent: CGClientTestingRowItem = .firebaseToken(status: .failure)
                var firebaseServerKeyEvent: CGClientTestingRowItem = .firebaseServerKey(status: .failure)
                var apnsDeviceTokenEvent: CGClientTestingRowItem = .apnsDeviceToken(status: .failure)
                var privateKeyApnsEvent: CGClientTestingRowItem = .privateKeyApns(status: .failure)

                if let clientTestingModel = self.clientTestingModel, let data = clientTestingModel.data {
                    if data.firebaseToken ?? false, data.privateKeyFirebase ?? false  {
                        firebaseSetupEvent = .firebaseSetup(status: .success)
                    }
                    
                    if data.firebaseToken ?? false  {
                        firebaseTokenEvent = .firebaseToken(status: .success)
                    }
                    
                    if data.privateKeyFirebase ?? false  {
                        firebaseServerKeyEvent = .firebaseServerKey(status: .success)
                    }
                    
                    if data.apnsDeviceToken ?? false  {
                        apnsDeviceTokenEvent = .apnsDeviceToken(status: .success)
                    }
                    
                    if data.privateKeyApns ?? false  {
                        privateKeyApnsEvent = .privateKeyApns(status: .success)
                    }
                }
                
                // Record Test Steps
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: firebaseTokenEvent, status: firebaseTokenEvent.getStatus()))
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: firebaseServerKeyEvent, status: firebaseServerKeyEvent.getStatus()))
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: apnsDeviceTokenEvent, status: apnsDeviceTokenEvent.getStatus()))
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: privateKeyApnsEvent, status: privateKeyApnsEvent.getStatus()))

                self.update(events: [firebaseSetupEvent, firebaseTokenEvent, firebaseServerKeyEvent, apnsDeviceTokenEvent, privateKeyApnsEvent])

            case .failure(let error):
                let firebaseSetupEvent: CGClientTestingRowItem = .firebaseSetup(status: .failure)
                let firebaseTokenEvent: CGClientTestingRowItem = .firebaseToken(status: .failure)
                let firebaseServerKeyEvent: CGClientTestingRowItem = .firebaseServerKey(status: .failure)
                let apnsDeviceTokenEvent: CGClientTestingRowItem = .apnsDeviceToken(status: .failure)
                let privateKeyApnsEvent: CGClientTestingRowItem = .privateKeyApns(status: .failure)

                // Record Test Steps
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: firebaseTokenEvent, status: firebaseTokenEvent.getStatus()))
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: firebaseServerKeyEvent, status: firebaseServerKeyEvent.getStatus()))
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: apnsDeviceTokenEvent, status: apnsDeviceTokenEvent.getStatus()))
                self.updateSdkTestStepsArray(withModel: CGSDKTestStepsModel(name: privateKeyApnsEvent, status: privateKeyApnsEvent.getStatus()))

                self.update(events: [firebaseSetupEvent, firebaseTokenEvent, firebaseServerKeyEvent, apnsDeviceTokenEvent, privateKeyApnsEvent])

                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CGClientTestingViewModel-onboardingSDKNotificationConfig", posttoserver: true)
            }
        }
    }
    
    // Update Multiple Event or Cell at Same time
    func update(events: [CGClientTestingRowItem]) {
        var indexPathArray: [IndexPath] = []
        for event in events {
            let itemInfo = self.getIndexOfItem(event)
            if let index = itemInfo.index, let indexPath = itemInfo.indexPath {
                self.eventsSectionsArray[index] = event
                indexPathArray.append(indexPath)
            }
        }
        
        if let delegate {
            delegate.updateTable(atIndexPaths: indexPathArray)
        }
    }
    
    func onboardingSDKTestSteps() {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let user_id = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_USERID)

        var queryParameters: [String: Any] = [:]
        queryParameters[APIParameterKey.user_id] = user_id
        queryParameters["platform"] = "ios"
        queryParameters["cg_sdk_platform"] = "cg-native-ios"
        queryParameters["cg_sdk_version"] = APIParameterKey.cgsdkversionvalue
        queryParameters[APIParameterKey.app_version] = "\(shortVersion)(\(version))"
        queryParameters["manufacturer"] = "Apple"
        queryParameters["model"] = deviceModel
        queryParameters["os_version"] = systemVersion

        var dataArray: [[String: Any]] = []
        for model in sdkTestStepsArray {
            dataArray.append(model.asDictionary())
        }
        queryParameters["data"] = dataArray
        
        APIManager.onboardingSDKTestSteps(queryParameters: queryParameters as NSDictionary) { result in
            switch result {
            case .success(let response):
                self.testStepsResponseModel = response

            case .failure(let error):
                CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "CGClientTestingViewModel-onboardingSDKTestSteps", posttoserver: true)
            }
        }
    }
}
