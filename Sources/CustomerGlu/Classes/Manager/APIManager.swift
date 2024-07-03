import Foundation
import UIKit
import SwiftUI

// HTTP Header Field's for API's
private enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case xapikey = "x-api-key"
    case xappname = "x-app-name"
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
    internal var method: String
    internal var path: String
    internal var baseurl: String
    
    init(serviceType: CGService) {
        self.baseurl = BaseUrls.baseurl
        switch serviceType {
        case .userRegister:
            self.method = "POST"
            self.path = "user/v1/user/sdk/generateusertoken?token=true"
        case .updateUserAttributes:
            self.method = "POST"
            self.path = "user/v1/user/sdk/updateuser?token=true"
        case .getWalletRewards:
            self.method = "GET"
            self.path = "reward/v1.1/user"
        case .getSingleCampaign:
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
            self.path = "entrypoints/v2/list/\(CustomerGlu.sdkWriteKey)"
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
        case .getReward:
            self.method = "POST"
            self.path = "reward/v2/user/reward"
        case .getProgram:
            self.method = "POST"
            self.path = "reward/v2/user/program"
        }
    }
}

enum CGService {
    case userRegister
    case updateUserAttributes
    case getWalletRewards
    case getSingleCampaign
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
    case getReward
    case getProgram
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
private class CGRequestData {
    var baseurl: String
    var methodandpath: MethodandPath
    var parametersDict: NSDictionary
    var dispatchGroup: DispatchGroup = DispatchGroup()
    var retryCount: Int = 1
    var completionBlock: ((_ status: CGAPIStatus, _ data: [String: Any]?, _ error: CGNetworkError?) -> Void)?
    
    init(baseurl: String, methodandpath: MethodandPath, parametersDict: NSDictionary, dispatchGroup: DispatchGroup, retryCount: Int, completionBlock: ((_ status: CGAPIStatus, _ data: [String: Any]?, _ error: CGNetworkError?) -> Void)?) {
        self.baseurl = baseurl
        self.methodandpath = methodandpath
        self.parametersDict = parametersDict
        self.dispatchGroup = dispatchGroup
        self.retryCount = retryCount
        self.completionBlock = completionBlock
    }
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
        var strUrl = "https://" + requestData.baseurl + requestData.methodandpath.path

        if requestData.parametersDict.count > 0 {
            if let campaignId = requestData.parametersDict["campaignId"] as? String {
                strUrl+="/"+campaignId
            }
        }
        
        guard let cleanedUrlString = OtherUtils.shared.cleanURL(url: strUrl), let url = URL(string: cleanedUrlString) else {
            print("Failed to create URL from string: \(strUrl)")
            return
        }
        print("URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        
        // HTTP Method
        urlRequest.httpMethod = requestData.methodandpath.method
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        urlRequest.setValue(CustomerGlu.sdkWriteKey, forHTTPHeaderField: HTTPHeaderField.xapikey.rawValue)
        urlRequest.setValue(CustomerGlu.appName, forHTTPHeaderField: HTTPHeaderField.xappname.rawValue)
        urlRequest.setValue("ios", forHTTPHeaderField: HTTPHeaderField.platform.rawValue)
        urlRequest.setValue(CustomerGlu.isDebugingEnabled.description, forHTTPHeaderField: HTTPHeaderField.sandbox.rawValue)
        urlRequest.setValue(APIParameterKey.cgsdkversionvalue, forHTTPHeaderField: HTTPHeaderField.cgsdkversionkey.rawValue)
        
        if let token = UserDefaults.standard.object(forKey: CGConstants.CUSTOMERGLU_TOKEN) as? String {
            let decryptedToken = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.CUSTOMERGLU_TOKEN)
            urlRequest.setValue("\(APIParameterKey.bearer) \(decryptedToken)", forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
            urlRequest.setValue("\(APIParameterKey.bearer) \(decryptedToken)", forHTTPHeaderField: HTTPHeaderField.xgluauth.rawValue)
        }
        
        if requestData.parametersDict.count > 0 {
            if CustomerGlu.isDebugingEnabled {
                print("Parameters: \(requestData.parametersDict)")
            }
            
            if requestData.methodandpath.method == "GET" {
                var urlString = ""
                for (i, (key, value)) in requestData.parametersDict.enumerated() {
                    urlString += i == 0 ? "?\(key)=\(value)" : "&\(key)=\(value)"
                }
                var absoluteStr = url.absoluteString
                absoluteStr += urlString
                urlRequest.url = URL(string: absoluteStr)
                print("GET URL with Parameters: \(absoluteStr)")
            } else {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: requestData.parametersDict as Any, options: .fragmentsAllowed)
                if let httpBody = urlRequest.httpBody {
                    print("HTTP Body: \(String(data: httpBody, encoding: .utf8) ?? "")")
                }
            }
        }
        
        if CustomerGlu.isDebugingEnabled {
            print("Request: \(urlRequest)")
        }
        
        // Enter dispatch group
        requestData.dispatchGroup.enter()
        
        let task = APIManager.shared.session.dataTask(with: urlRequest) { [weak requestData] data, response, error in
            defer {
                // Leave dispatch group
                requestData?.dispatchGroup.leave()
            }
            
            guard let requestData = requestData else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                requestData.completionBlock?(.failure, nil, error as? CGNetworkError)
                return
            }
            
            guard let data = data else {
                print("No data received")
                requestData.completionBlock?(.failure, nil, CGNetworkError.other)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                guard let JSON = json else {
                    print("Failed to parse JSON")
                    requestData.completionBlock?(.failure, nil, CGNetworkError.bindingFailed)
                    return
                }
                JSON.printJson()
                let cleanedJSON = cleanJSON(json: JSON, isReturn: true)
                requestData.completionBlock?(.success, cleanedJSON, nil)
            } catch let parseError {
                print("JSON Parsing Error: \(parseError)")
                requestData.completionBlock?(.failure, nil, CGNetworkError.bindingFailed)
            }
        }
        task.resume()
        requestData.dispatchGroup.wait()
    }
    
    private static func blockOperationForService(withRequestData requestData: CGRequestData) {
        let blockOperation = BlockOperation()
        
        blockOperation.addExecutionBlock {
            performRequest(withData: requestData)
        }
        
        if let lastOperation = ApplicationManager.operationQueue.operations.last {
            blockOperation.addDependency(lastOperation)
        }
        
        ApplicationManager.operationQueue.addOperation(blockOperation)
    }
    
    private static func blockOperationForServiceWithDelay(andRequestData requestData: CGRequestData) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            DispatchQueue.global(qos: .userInitiated).async {
                blockOperationForService(withRequestData: requestData)
            }
        }
    }
    
    private static func serviceCall<T: Decodable>(for type: CGService, parametersDict: NSDictionary, dispatchGroup: DispatchGroup = DispatchGroup(), completion: @escaping (Result<T, CGNetworkError>) -> Void) {
        let methodandpath = MethodandPath(serviceType: type)
        var url = methodandpath.baseurl
        if (type == CGService.getSingleCampaign){
            url = methodandpath.baseurl
        }
        print("My Url " + url)

        let requestData = CGRequestData(baseurl: methodandpath.baseurl, methodandpath: methodandpath, parametersDict: parametersDict, dispatchGroup: dispatchGroup, retryCount: CustomerGlu.getInstance.appconfigdata?.allowedRetryCount ?? 1, completionBlock: nil)
        
        let block: (_ status: CGAPIStatus, _ data: [String: Any]?, _ error: CGNetworkError?) -> Void = { [weak requestData] (status, data, error) in
            guard let requestData = requestData else { return }
            switch status {
            case .success:
                if let data {
                    requestData.retryCount = requestData.retryCount - 1
                    if let error, error == .badURLRetry, requestData.retryCount >= 1 {
                        blockOperationForServiceWithDelay(andRequestData: requestData)
                    } else {
                        if let error, error == .badURLRetry {
                            completion(.failure(CGNetworkError.badURLRetry))
                        } else if type == .getReward || type == .getProgram {
                            completion(.success(APIManager.dictionaryToString(data) as! T))
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
    
    static func dictionaryToString(_ dictionary: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .ascii) {
                return jsonString
            }
        } catch {
            print("Error converting dictionary to string: \(error)")
        }
        return nil
    }
        
    static func userRegister(queryParameters: NSDictionary, completion: @escaping (Result<CGRegistrationModel, CGNetworkError>) -> Void) {
        serviceCall(for: .userRegister, parametersDict: queryParameters, completion: completion)
    }
    
    static func updateUserAttributes(queryParameters: NSDictionary, completion: @escaping (Result<CGRegistrationModel, CGNetworkError>) -> Void) {
        serviceCall(for: .updateUserAttributes, parametersDict: queryParameters, completion: completion)
    }
    
    static func getWalletRewards(queryParameters: NSDictionary, completion: @escaping (Result<CGCampaignsModel, CGNetworkError>) -> Void) {
        serviceCall(for: .getWalletRewards, parametersDict: queryParameters, completion: completion)
    }
    
    static func getSingleCampaign(queryParameters: NSDictionary, completion: @escaping (Result<CGCampaignsModel, CGNetworkError>) -> Void) {
        serviceCall(for: .getSingleCampaign, parametersDict: queryParameters, completion: completion)
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
    
    static func getReward(queryParameters: NSDictionary, completion: @escaping (Result<String?, CGNetworkError>) -> Void) {
        serviceCall(for: .getReward, parametersDict: queryParameters, completion: completion)
    }
    
    static func getProgram(queryParameters: NSDictionary, completion: @escaping (Result<String?, CGNetworkError>) -> Void) {
        serviceCall(for: .getProgram, parametersDict: queryParameters, completion: completion)
    }
    
    // MARK: - Private Class Methods
    
    @discardableResult
    static private func cleanJSON(json: Dictionary<String, Any>, isReturn: Bool = false) -> Dictionary<String, Any> {
        var actualJson = json
        
        for (key, value) in actualJson {
            if let dict = value as? Dictionary<String, Any> {
                cleanJSON(json: dict)
            } else if let array = value as? [Dictionary<String, Any>] {
                for element in array {
                    cleanJSON(json: element)
                }
            }
            
            if !(value is NSNull) {
                if let text = value as? String, text == "_null" {
                    actualJson.removeValue(forKey: key)
                }
            } else {
                actualJson.removeValue(forKey: key)
            }
        }
        
        if isReturn {
            return actualJson
        } else {
            return Dictionary<String, Any>()
        }
    }
    
    static private func dictToObject<T: Decodable>(dict: Dictionary<String, Any>, type: T.Type) -> T? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let jsonDecoder = JSONDecoder()
            let object = try jsonDecoder.decode(type, from: jsonData)
            return object
        } catch let error {
            CustomerGlu.getInstance.printlog(cglog: error.localizedDescription, isException: false, methodName: "dictToObject", posttoserver: false)
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
    
    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var error: Error?
    
    override func dataTask(with url: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}
