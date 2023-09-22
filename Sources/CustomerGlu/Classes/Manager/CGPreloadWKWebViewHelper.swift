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

        webView.isHidden = true
        webView.backgroundColor = .clear
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        if let url = URL(string: "https://constellation.customerglu.com/preload") {
            webView.load(URLRequest(url: url))
        }
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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


//class CGPreloadWKWebViewHelper: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
//    var webView = WKWebView()
//
//    override init() {
//        let config = WKWebViewConfiguration()
//        let contentController = WKUserContentController()
//        config.userContentController = contentController
//        config.allowsInlineMediaPlayback = true
//        self.webView = WKWebView(frame: .zero, configuration: config)
//        super.init()
//
//        let window = UIWindow(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
//        window.addSubview(webView)
//
//        if let url = URL(string: "https://constellation.customerglu.com/preload") {
//            webView.load(URLRequest(url: url))
//        }
//
//        self.webView.navigationDelegate = self
//    }
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        // Handle script messages if needed.
//    }
//
//    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        guard let serverTrust = challenge.protectionSpace.serverTrust,
//              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
//            completionHandler(.cancelAuthenticationChallenge, nil)
//            return
//        }
//
//        let knownCertificateData = CustomerGlu.getInstance.decryptUserDefaultKey(userdefaultKey: CGConstants.clientSSLCertificateAsStringKey)
//        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
//
//        if remoteCertificateData.base64EncodedString() == knownCertificateData {
//            completionHandler(.useCredential, URLCredential(trust: serverTrust))
//        } else {
//            completionHandler(.cancelAuthenticationChallenge, nil)
//        }
//    }
//}
