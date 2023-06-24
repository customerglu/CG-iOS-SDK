//
//  File.swift
//  
//
//  Created by hitesh on 28/10/21.
//

import Foundation
import UIKit
import SwiftUI

// HTTP Header Field's for API's
private enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case xapikey = "x-api-key"
    case platform = "platform"
    case xgluauth = "X-GLU-AUTH"
    case cgsdkversionkey = "cg-sdk-version"
    case sandbox = "sandbox"
}

// HTTP Header Value's for API's
private enum ContentType: String {
    case json = "application/json"
}

// MARK: - MethodandPath
internal class MethodandPath: Codable {
    
    // MARK: - Variables
    internal var method: String
    internal var path: String
    internal var baseurl: String
    
    init(serviceType: CGService) {
        // Default value else change it in respective enum case.
        self.baseurl = BaseUrls.baseurl
        
        switch serviceType {
        case .userRegister:
            self.method = "POST"
            self.path = "user/v1/user/sdk?token=true"
        case .getWalletRewards:
            self.method = "GET"
            self.path = "reward/v1.1/user"
        case .addToCart:
            self.method = "POST"
            self.path = "server/v4"
            self.baseurl = BaseUrls.eventUrl
        case .crashReport:
            self.method = "PUT"
            self.path = "api/v1/report"
        case .entryPointdata:
            self.method = "GET"
            self.path = "entrypoints/v1/list"
        case .entrypoints_config:
            self.method = "POST"
            self.path = "entrypoints/v1/config"
        case .send_analytics_event:
            self.method = "POST"
            self.path = "v4/sdk"
            self.baseurl = BaseUrls.streamurl
        case .appconfig:
            self.method = "GET"
            self.path = "client/v1/sdk/config"
        case .cgdeeplink:
            self.method = "GET"
            self.path = "api/v1/wormhole/sdk/url"
        case .cgMetricDiagnostics:
            self.method = "POST"
            self.path = "sdk/v4"
            self.baseurl = BaseUrls.diagnosticUrl
        case .cgNudgeIntegration:
            self.method = "POST"
            self.path = "integrations/v1/nudge/sdk/test"
        case .onboardingSDKNotificationConfig:
            self.method = "POST"
            self.path = "integrations/v1/onboarding/sdk/notification-config"
        case .onboardingSDKTestSteps:
            self.method = "POST"
            self.path = "integrations/v1/onboarding/sdk/test-steps"
        }
    }
}

enum CGService {
    case userRegister
    case getWalletRewards
    case addToCart
    case crashReport
    case entryPointdata
    case entrypoints_config
    case send_analytics_event
    case appconfig
    case cgdeeplink
    case cgMetricDiagnostics
    case cgNudgeIntegration
    case onboardingSDKNotificationConfig
    case onboardingSDKTestSteps
}

// Parameter Key's for all API's
private struct BaseUrls {
    static let baseurl = ApplicationManager.baseUrl
    static let devbaseurl = ApplicationManager.devbaseUrl
    static let streamurl = ApplicationManager.streamUrl
    static let eventUrl = ApplicationManager.eventUrl
    static let diagnosticUrl = ApplicationManager.diagnosticUrl
    static let analyticsUrl = ApplicationManager.analyticsUrl
}

// MARK: - CGRequestData
private struct CGRequestData {
    var baseurl: String
    var methodandpath: MethodandPath
    var parametersDict: NSDictionary
    var dispatchGroup:DispatchGroup = DispatchGroup()
    var retryCount: Int = 1
    var completionBlock: ((_ status: CGAPIStatus, _ data: [String: Any]?, _ error: CGNetworkError?) -> Void)?
}

// MARK: - CGAPIStatus
enum CGAPIStatus {
    case success
    case failure
}

// MARK: - CGNetworkError
enum CGNetworkError: Error, LocalizedError {
    case badURLRetry
    case unauthorized
    case bindingFailed
    case other

    public var errorDescription: String? {
        switch self {
        case .badURLRetry:
            return NSLocalizedString("Bad URL Type, please retry", comment: "CGNetworkError")
        case .unauthorized:
            return NSLocalizedString("Unauthorized user logout", comment: "CGNetworkError")
        case .bindingFailed:
            return NSLocalizedString("Data binding failed", comment: "CGNetworkError")
        case .other:
            return NSLocalizedString("Other Error", comment: "CGNetworkError")
        }
    }
}

// Class contain Helper Methods Used in Overall Application Related to API Calls
// MARK: - APIManager
class APIManager {
    public var session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // Singleton Instance
    static let shared = APIManager()
    
    private static func performRequest(withData requestData: CGRequestData) {
        
        //Grouped compelete API-call work flow into a DispatchGroup so that it can maintanted the oprational queue for task completion
        // Enter into DispatchGroup
        //   if(MethodNameandPath.getWalletRewards.path == methodandpath.path){
        requestData.dispatchGroup.enter()
        //    }
        
        var urlRequest: URLRequest!
        var url: URL!
        let strUrl = "https://" + requestData.baseurl
        url = URL(string: strUrl + requestData.methodandpath.path)!
        urlRequest = URLRequest(url: url)
        
        // HTTP Method
        urlRequest.httpMethod = requestData.methodandpath.method//method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        urlRequest.setValue(CustomerGlu.sdkWriteKey, forHTTPHeaderField: HTTPHeaderField.xapikey.rawValue)
        urlRequest.setValue("ios", forHTTPHeaderField: HTTPHeaderField.platform.rawValue)
        urlRequest.setValue(CustomerGlu.isDebugingEnabled.description, forHTTPHeaderField: HTTPHeaderField.sandbox.rawValue)
        urlRequest.setValue(APIParameterKey.cgsdkversionvalue, forHTTPHeaderField: HTTPHeaderField.cgsdkversionkey.rawValue)
        
        if UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) != nil {
            urlRequest.setValue("\(APIParameterKey.bearer) " + CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN), forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
            urlRequest.setValue("\(APIParameterKey.bearer) " + CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN), forHTTPHeaderField: HTTPHeaderField.xgluauth.rawValue)
        }
        
        if requestData.parametersDict.count > 0 { // Check Parameters & Move Accordingly
            if(true == CustomerGlu.isDebugingEnabled){
                print(requestData.parametersDict as Any)
            }
            if requestData.methodandpath.method == "GET" {
                var urlString = ""
                for (i, (keys, values)) in requestData.parametersDict.enumerated() {
                    urlString += i == 0 ? "?\(keys)=\(values)" : "&\(keys)=\(values)"
                }
                // Append GET Parameters to URL
                var absoluteStr = url.absoluteString
                absoluteStr += urlString
                absoluteStr = absoluteStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                urlRequest.url = URL(string: absoluteStr)!
            } else {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: requestData.parametersDict as Any, options: .fragmentsAllowed)
            }
        }
        
        if(true == CustomerGlu.isDebugingEnabled) {
            print(urlRequest!)
        }
        
        let task = shared.session.dataTask(with: urlRequest) { data, response, error in
            
            // Leave from dispachgroup
            requestData.dispatchGroup.leave()
            
            
            
            var isRetry = false
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    CustomerGlu.getInstance.clearGluData()
                    return
                } else if httpResponse.statusCode == 429 || httpResponse.statusCode == 502 || httpResponse.statusCode == 408 {
                    isRetry = true
                }
            }
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                // Get JSON, Clean it and Convert to Object
                let JSON = json
                JSON?.printJson()
                let cleanedJSON = cleanJSON(json: JSON!, isReturn: true)
                if isRetry {
                    requestData.completionBlock?(.success, cleanedJSON, CGNetworkError.badURLRetry)
                } else {
                    requestData.completionBlock?(.success, cleanedJSON, nil)
                }
            } catch let error {
                if(true == CustomerGlu.isDebugingEnabled){
                    print(error)
                }
                
                if isRetry {
                    requestData.completionBlock?(.failure, nil, CGNetworkError.badURLRetry)
                } else {
                    requestData.completionBlock?(.failure, nil, error as? CGNetworkError)
                }
            }
        }
        task.resume()
        
        // wait untill dispatchGroup.leave() not called
        requestData.dispatchGroup.wait()
    }
    
    private static func blockOperationForService(withRequestData requestData: CGRequestData) {
        // create a blockOperation for avoiding miltiple API call at same time
        let blockOperation = BlockOperation()
        
        // Added Task into Queue
        blockOperation.addExecutionBlock {
            performRequest(withData: requestData)
        }
        
        // Add dependency to finish previus task before starting new one
        if(ApplicationManager.operationQueue.operations.count > 0){
            blockOperation.addDependency(ApplicationManager.operationQueue.operations.last!)
        }
        
        //Added task into Queue
        ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    private static func blockOperationForServiceWithDelay(andRequestData requestData: CGRequestData) {
        // Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            // Background thread
            DispatchQueue.global(qos: .userInitiated).async {
                blockOperationForService(withRequestData: requestData)
            }
        })
    }
    
    private static func serviceCall<T: Decodable>(for type: CGService, parametersDict: NSDictionary, dispatchGroup: DispatchGroup = DispatchGroup(), completion: @escaping (Result<T, CGNetworkError>) -> Void) {
        let methodandpath = MethodandPath(serviceType: type)
        var requestData = CGRequestData(baseurl: methodandpath.baseurl, methodandpath: methodandpath, parametersDict: parametersDict, dispatchGroup: dispatchGroup, retryCount: CustomerGlu.getInstance.appconfigdata?.allowedRetryCount ?? 1)
        
        // Call Login API with API Router
        let block: (_ status: CGAPIStatus, _ data: [String: Any]?, _ error: CGNetworkError?) -> Void = { (status, data, error) in
            switch status {
            case .success:
                if let data {
                    requestData.retryCount = requestData.retryCount - 1
                    if let error, error == .badURLRetry, requestData.retryCount >= 1 {
                        blockOperationForServiceWithDelay(andRequestData: requestData)
                    } else {
                        if let error, error == .badURLRetry {
                            completion(.failure(CGNetworkError.badURLRetry))
                        } else if let object = dictToObject(dict: data, type: T.self) {
                            completion(.success(object))
                        } else {
                            completion(.failure(CGNetworkError.other))
                        }
                    }
                } else {
                    completion(.failure(CGNetworkError.bindingFailed))
                }
                
            case .failure:
                requestData.retryCount = requestData.retryCount - 1
                if let error, error == .badURLRetry, requestData.retryCount >= 1 {
                    blockOperationForServiceWithDelay(andRequestData: requestData)
                } else {
                    completion(.failure(CGNetworkError.other))
                }
            }
        }
        
        requestData.completionBlock = block
        blockOperationForService(withRequestData: requestData)
    }
    
    static func userRegister(queryParameters: NSDictionary, completion: @escaping (Result<CGRegistrationModel, CGNetworkError>) -> Void) {
        serviceCall(for: .userRegister, parametersDict: queryParameters,completion: completion)
    }
    
    static func getWalletRewards(queryParameters: NSDictionary, completion: @escaping (Result<CGCampaignsModel, CGNetworkError>) -> Void) {
        serviceCall(for: .getWalletRewards, parametersDict: queryParameters,completion: completion)
    }
    
    static func addToCart(queryParameters: NSDictionary, completion: @escaping (Result<CGAddCartModel, CGNetworkError>) -> Void) {
        serviceCall(for: .addToCart, parametersDict: queryParameters, completion: completion)
    }
    
    static func crashReport(queryParameters: NSDictionary, completion: @escaping (Result<CGAddCartModel, CGNetworkError>) -> Void) {
        serviceCall(for: .crashReport, parametersDict: queryParameters, completion: completion)
    }
    
    static func getEntryPointdata(queryParameters: NSDictionary, completion: @escaping (Result<CGEntryPoint, CGNetworkError>) -> Void) {
        serviceCall(for: .entryPointdata, parametersDict: queryParameters, completion: completion)
    }
    
    static func entrypoints_config(queryParameters: NSDictionary, completion: @escaping (Result<EntryConfig, CGNetworkError>) -> Void) {
        serviceCall(for: .entrypoints_config, parametersDict: queryParameters, completion: completion)
    }
    
    static func sendAnalyticsEvent(queryParameters: NSDictionary, completion: @escaping (Result<CGAddCartModel, CGNetworkError>) -> Void) {
        serviceCall(for: .send_analytics_event, parametersDict: queryParameters, completion: completion)
    }
    
    static func sendEventsDiagnostics(queryParameters: NSDictionary, completion: @escaping (Result<CGAddCartModel, CGNetworkError>) -> Void) {
        serviceCall(for: .cgMetricDiagnostics, parametersDict: queryParameters, completion: completion)
    }
    
    static func getCGDeeplinkData(queryParameters: NSDictionary, completion: @escaping (Result<CGDeeplink, CGNetworkError>) -> Void) {
        serviceCall(for: .cgdeeplink, parametersDict: queryParameters, completion: completion)
    }
    
    static func appConfig(queryParameters: NSDictionary, completion: @escaping (Result<CGAppConfig, CGNetworkError>) -> Void) {
        serviceCall(for: .appconfig, parametersDict: queryParameters, completion: completion)
    }
    
    static func nudgeIntegration(queryParameters: NSDictionary, completion: @escaping (Result<CGNudgeIntegrationModel, CGNetworkError>) -> Void) {
        serviceCall(for: .cgNudgeIntegration, parametersDict: queryParameters, completion: completion)
    }
    
    static func onboardingSDKNotificationConfig(queryParameters: NSDictionary, completion: @escaping (Result<CGClientTestingModel, CGNetworkError>) -> Void) {
        serviceCall(for: .onboardingSDKNotificationConfig, parametersDict: queryParameters, completion: completion)
    }
    
    static func onboardingSDKTestSteps(queryParameters: NSDictionary, completion: @escaping (Result<CGSDKTestStepsResponseModel, CGNetworkError>) -> Void) {
        serviceCall(for: .onboardingSDKTestSteps, parametersDict: queryParameters, completion: completion)
    }
    
    // MARK: - Private Class Methods
    
    // Recursive Method
    @discardableResult
    static private func cleanJSON(json: Dictionary<String, Any>, isReturn: Bool = false) -> Dictionary<String, Any> {
        
        // Create Local Object to Mutate
        var actualJson = json
        
        // Iterate Over All Pairs
        for (key, value) in actualJson {
            
            if let dict = value as? Dictionary<String, Any> { // If Value is Dictionary then call itself with new value
                cleanJSON(json: dict)
            } else if let array = value as? [Dictionary<String, Any>] {
                
                // If Value is Array then call itself according to number of elements
                for element in array {
                    cleanJSON(json: element)
                }
            }
            
            // If value if not null then move inside
            if !(value is NSNull) {
                
                // If value is "_null" String then remove it
                if let text = value as? String, text == "_null" {
                    actualJson.removeValue(forKey: key)
                }
            } else {
                
                // remove null value
                actualJson.removeValue(forKey: key)
            }
        }
        
        // If called with isReturn as true then only return actual object
        if isReturn {
            return actualJson
        } else { // else return dummy object
            return Dictionary<String, Any>()
        }
    }
    
    static private func dictToObject <T: Decodable>(dict: Dictionary<String, Any>, type: T.Type) -> T? {
        do {
            // Convert Dictionary to JSON Data
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            // Decode data to model object
            let jsonDecoder = JSONDecoder()
            let object = try jsonDecoder.decode(type, from: jsonData)
            return object
        } catch let error { // response with error
            print("JSON decode failed: \(error.localizedDescription)")
            return nil
        }
    }
}

// We create a partial mock by subclassing the original class
class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?
    
    override func dataTask(
        with url: URLRequest,
        completionHandler: @escaping CompletionHandler
    ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}
