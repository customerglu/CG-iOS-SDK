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
    var webView = WKWebView()

    override init() {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        
        let window = UIWindow(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
        window.addSubview(webView)
        
        if let url = URL(string: "https://constellation.customerglu.com/reward/?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4MTEiLCJnbHVJZCI6Ijk2YjdmYjc3LTU3ZGItNGY2Yi05MzM4LTY0ZThmNzhjNWI5ZiIsImNsaWVudCI6Ijg0YWNmMmFjLWIyZTAtNDkyNy04NjUzLWNiYTJiODM4MTZjMiIsImRldmljZUlkIjoiODExX2RlZmF1bHQiLCJkZXZpY2VUeXBlIjoiYW5kcm9pZCIsImlzTG9nZ2VkSW4iOnRydWUsImlhdCI6MTY5NTI5NTA2NCwiZXhwIjoxNzI2ODMxMDY0fQ.Hzz5jcK18LUvuFpwk35MN4JV0GXrm1sjX0mCPzSS8D4&rewardUserId=fb211c78-3c00-4540-924c-753b91b2d003") {
            webView.load(URLRequest(url: url))
        }
        
        self.webView.navigationDelegate = self
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
