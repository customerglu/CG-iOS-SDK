//
//  CGPreloadWKWebViewHelper.swift
//  
//
//  Created by Yasir on 20/09/23.
//

import Foundation
import WebKit
import Security

class CGPreloadWKWebViewHelper: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)

        if let url = URL(string: "https://constellation.customerglu.com/preload") {
            webView.load(URLRequest(url: url))
        }
    }
    private var checked: Bool = false
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let appConfig = CustomerGlu.getInstance.appconfigdata, let enableSslPinning = appConfig.enableSslPinning, enableSslPinning else { return }
        
        DispatchQueue.global(qos: .background).async {
            guard let serverTrust = challenge.protectionSpace.serverTrust,
                  let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            let alreadySavedCertificate = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.clientSSLCertificateAsStringKey)
            let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
            
            if self.checked {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
            
            if remoteCertificateData.base64EncodedString() == alreadySavedCertificate {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } else {
                CustomerGlu.getInstance.updateLocalCertificate()
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            
            self.checked = true
        }
    }
}
