//
//  CustomWebViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/15/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class CustomWebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = ProcessPool.sharedPool
        
        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = true
        webView.navigationDelegate = self

        view.addSubview(webView)

        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.isHidden = true

        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        showActivityIndicator(show: false)
        
        // dynamically inject css file into webview
        guard let path = Bundle.main.path(forResource: "myuw", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
        
    }
    
    
}
