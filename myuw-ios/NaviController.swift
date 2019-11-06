//
//  WebViewNavigationController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/5/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import Foundation
import WebKit

class NaviController: UIViewController, WKNavigationDelegate {
    
    var visitUrl:String = ""
    var webView: WKWebView!

    override func viewDidLoad() {
        
        let url = URL(string: visitUrl)!
        webView.load(URLRequest(url: url))
                
        // override navigation title
        self.navigationItem.title = "NaviControl"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func loadView() {
        let configuration = WKWebViewConfiguration()
        
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.processPool = ProcessPool.sharedPool
        
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = self
        self.view = webView
    }
    
}
