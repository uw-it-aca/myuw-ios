//
//  ProfileViewController.swift
//  myuw-test
//
//  Created by Charlon Palacay on 10/21/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class ProfileViewController: WebViewController {
    
    // override the viewDidLoad with "profile url"
    override func viewDidLoad() {
        view.backgroundColor = .brown
        let url = URL(string: "https://my-test.s.uw.edu/profile/")!
        webView.load(URLRequest(url: url))
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("alert('hello');")
    }
        
}
