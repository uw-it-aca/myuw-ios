//
//  AuthenticationController.swift
//  myuw-test
//
//  Created by Charlon Palacay on 7/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

// singleton class for a shared WKProcessPool
class ProcessPool {
    static var sharedPool = WKProcessPool()
}

class AuthenticationController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        let url = URL(string: "https://my-test.s.uw.edu/")!
        webView.load(URLRequest(url: url))
        
        print("auth viewDidLoad")
    }
    
    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = ProcessPool.sharedPool
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        
        self.view = webView
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // set the title using the webpage title
        title = webView.title
        print("webview title: ", self.title as Any);
        
        // check to see if webview is loading myuw (simulates being "logged" into myuw)
        if (self.title == "MyUW: Home") {
            
            print("on myuw")
            
            // once user is logged into myuw, we need to pass the user's affiliation
            // back to the native app - so it knows how to build the tab navigation
            
            userAffiliations = ["student", "seattle", "undergrad"]
            userNetID = "javerage"
            
            // tabController (main) and appDelegate instance
            let tabController = TabViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            // set tabControlleer as rootViewController after simulating the user logged in
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
