//
//  CGPreloadWKWebViewHelper.swift
//  
//
//  Created by Yasir on 20/09/23.
//

import Foundation
import WebKit
import Security
import UIKit
class CGPreloadWKWebViewHelper: NSObject, WKNavigationDelegate {
    var hiddenWebView: WKWebView?

    public func loadServiceWorkerInBackground() {
           DispatchQueue.global(qos: .background).async {
               DispatchQueue.main.async {
                   // Create the configuration for WKWebView
                   let config = WKWebViewConfiguration()
                   
                   // Create and configure the WKWebView
                   let webView = WKWebView(frame: .zero, configuration: config)
                   webView.isHidden = true
                   webView.navigationDelegate = self  // Set the navigation delegate
                   
                   // Ensure the WebView is added to a view in the main thread
                   if let window = UIApplication.shared.windows.first {
                       window.addSubview(webView)
                   }

                   // Load the URL to register the service worker
                   if let url = URL(string: "https://constellation.customerglu.com/preload") {
                       let request = URLRequest(url: url)
                       webView.load(request)
                       self.hiddenWebView = webView
                   }
               }
           }
       }


        // WKNavigationDelegate method
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Page has finished loading, remove the WebView
            webView.removeFromSuperview()
            hiddenWebView = nil  // Optional: release the reference to the WebView
            print("Service worker page loaded and WebView removed.")
        }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
          print("Failed to load URL: \(error.localizedDescription)")
      }

      // WKNavigationDelegate method to catch errors in content loading
      public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
          print("Failed to start loading URL: \(error.localizedDescription)")
      }
    
    
//
//     func viewDidLoad() {
//
//        let config = WKWebViewConfiguration()
//        let contentController = WKUserContentController()
//        config.userContentController = contentController
//        config.allowsInlineMediaPlayback = true
//
//        webView = WKWebView(frame: .zero, configuration: config)
//        webView.navigationDelegate = self
//
//        if let url = URL(string: "https://constellation.customerglu.com/preload") {
//            webView.load(URLRequest(url: url))
//        }
//    }
    
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        guard let appConfig = CustomerGlu.getInstance.appconfigdata, let enableSslPinning = appConfig.enableSslPinning, enableSslPinning else { return }
//        
//        DispatchQueue.global(qos: .background).async {
//            guard let serverTrust = challenge.protectionSpace.serverTrust,
//                  let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
//                completionHandler(.cancelAuthenticationChallenge, nil)
//                return
//            }
//
//            let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
//            ApplicationManager.encryptUserDefaultKey(str: remoteCertificateData.base64EncodedString(), userdefaultKey: CGConstants.clientSSLCertificateAsStringKey)
//            completionHandler(.useCredential, URLCredential(trust: serverTrust))
//        }
//    }
//    
}
