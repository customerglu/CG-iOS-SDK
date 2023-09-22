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
        modalPresentationStyle = .overFullScreen

        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .init(x: 0, y: 0, width: 20, height: 20), configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)

        webView.isHidden = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.heightAnchor.constraint(equalToConstant: 0),
            webView.widthAnchor.constraint(equalToConstant: 0),
        ])

        webView.backgroundColor = .clear

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
