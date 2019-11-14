//
//  TestController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/14/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import Foundation
import WebKit

class TestController: UIViewController, WKNavigationDelegate {
    
    var webView : WKWebView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        guard let url = URL(string: "https://my-test.s.uw.edu") else { return }
        
        let webConfiguraton = WKWebViewConfiguration()
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguraton)
        //webView = WKWebView(frame: self.view.frame)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = true
        webView.navigationDelegate = self

        view.addSubview(webView)

        let request = URLRequest(url: url)
        webView.load(request)
        
        // setup loading indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.isHidden = false

        view.addSubview(activityIndicator)
        
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

}
