//
//  CGPreloadWKWebViewHelper.swift
//  
//
//  Created by Yasir on 20/09/23.
//

import UIKit
import WebKit

class CGPreloadWKWebViewHelper: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    let config = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    var webView = WKWebView()
    
    override init() {
        super.init()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: config)
        if let url = URL(string: "https://constellation.customerglu.com/preload") {
            webView.load(URLRequest(url: url))
        }
        self.webView.navigationDelegate = self
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard #available(iOS 12.0, *) else { return }
        guard let appConfig = CustomerGlu.getInstance.appconfigdata, let enableSslPinning = appConfig.enableSslPinning, enableSslPinning else { return }
        
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return
        }
        
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        DispatchQueue.global(qos: .background).async {
            let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
            let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
            
            guard isServerTrusted == true else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            if CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.clientSSLCertificateAsStringKey) != remoteCertificateData.base64EncodedString() {
                CustomerGlu.getInstance.updateLocalCertificate()
            }
            
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
}
