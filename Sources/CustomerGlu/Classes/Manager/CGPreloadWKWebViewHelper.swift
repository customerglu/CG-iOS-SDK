//
//  CGPreloadWKWebViewHelper.swift
//  
//
//  Created by Yasir on 20/09/23.
//

import Foundation
import WebKit
import Security

class CGPreloadWKWebViewHelper: NSObject, WKNavigationDelegate {
    var webView: WKWebView!

     func viewDidLoad() {
     
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self

        if let url = URL(string: "https://constellation.customerglu.com/preload") {
            webView.load(URLRequest(url: url))
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let appConfig = CustomerGlu.getInstance.appconfigdata, let enableSslPinning = appConfig.enableSslPinning, enableSslPinning else { return }
        
        DispatchQueue.global(qos: .background).async {
            guard let serverTrust = challenge.protectionSpace.serverTrust,
                  let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
            ApplicationManager.encryptUserDefaultKey(str: remoteCertificateData.base64EncodedString(), userdefaultKey: CGConstants.clientSSLCertificateAsStringKey)
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
}
