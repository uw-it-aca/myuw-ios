//
//  AuthenticationController.swift
//  myuw-test
//
//  Created by Charlon Palacay on 7/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

// singleton class for a shared WKProcessPool
class ProcessPool {
    static var sharedPool = WKProcessPool()
}

class AuthenticationController: UINavigationController, WKNavigationDelegate, SFSafariViewControllerDelegate {
    
    var webView: WKWebView!

    override func viewDidLoad() {
        view.backgroundColor = .brown
        let url = URL(string: "https://my-test.s.uw.edu/")!
        webView.load(URLRequest(url: url))
        
        print("viewDidLoad")
    }
    
    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = ProcessPool.sharedPool
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        
        self.view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // set the title using the webpage title
        title = webView.title
        print("webview title: ", self.title as Any);
        
        // check to see if webview is loading myuw
        if (self.title == "MyUW: Home") {
            
            print("on myuw")
            
            // tabController (main) and appDelegate instance
            let tabController = TabViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            // set tabControlleer as rootViewController after simulating the user login
            appDelegate.window!.rootViewController = tabController
    
        }
            
    }
    
    // get the cookies
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            
            //debugPrint(cookies.debugDescription)
            print("**********")
            for cookie in cookies {
                print("name: \(cookie.name) value: \(cookie.value)")
            }
            
        }

        decisionHandler(.allow)
    }
    

    
}
