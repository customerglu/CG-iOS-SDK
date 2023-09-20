//
//  CGPreloadWKWebViewHelper.swift
//  
//
//  Created by Yasir on 20/09/23.
//

import Foundation
import WebKit
import Security

class CGPreloadWKWebViewHelper: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    let config = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    var webView = WKWebView()

    override init() {
        super.init()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: config)
        self.webView.navigationDelegate = self

        let window = UIWindow(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
        window.addSubview(webView)

        if let url = URL(string: "https://constellation.customerglu.com/preload") {
            webView.load(URLRequest(url: url))
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle script messages if needed.
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let knownCertificateData = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.clientSSLCertificateAsStringKey)
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)

        if remoteCertificateData.base64EncodedString() == knownCertificateData {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}


//import UIKit
//import WebKit
//
//class CGPreloadWKWebViewHelper: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
//    let config = WKWebViewConfiguration()
//    let contentController = WKUserContentController()
//    var webView = WKWebView()
//
//    override init() {
//        super.init()
//        config.userContentController = contentController
//        config.allowsInlineMediaPlayback = true
//        webView = WKWebView(frame: .zero, configuration: config)
//        if let url = URL(string: "https://constellation.customerglu.com/preload") {
//            webView.load(URLRequest(url: url))
//        }
//        self.webView.navigationDelegate = self
//    }
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//
//    }
//
//    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        guard #available(iOS 12.0, *) else { return }
//        guard let appConfig = CustomerGlu.getInstance.appconfigdata, let enableSslPinning = appConfig.enableSslPinning, enableSslPinning else { return }
//
//        guard let serverTrust = challenge.protectionSpace.serverTrust,
//              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
//            return
//        }
//
//        let policy = NSMutableArray()
//        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
//        DispatchQueue.global(qos: .background).async {
//            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
//            let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
//
//            guard isServerTrusted == true else {
//                completionHandler(.cancelAuthenticationChallenge, nil)
//                return
//            }
//
//            if CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.clientSSLCertificateAsStringKey) != remoteCertificateData.base64EncodedString() {
//                CustomerGlu.getInstance.updateLocalCertificate()
//            }
//
//            completionHandler(.useCredential, URLCredential(trust: serverTrust))
//        }
//    }
//}
