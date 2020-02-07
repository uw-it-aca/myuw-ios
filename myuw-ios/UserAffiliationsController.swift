//
//  UserAffiliationsController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 2/6/20.
//  Copyright © 2020 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class UserAffiliationsController: CustomWebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview
        webView.load("\(appHost)/hybrid_login/")
        
        // override navigation title
        self.navigationItem.title = "MyUW"
    }
    
    // override base class didFinish
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        didChange = true
        
        let url = webView.url?.absoluteURL
        print("override webview url: ", url as Any)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
           // set tabControlleer as rootViewController after getting user info
           let tabControlleer = TabViewController()
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           // set the main controller as the root controller on app load
           appDelegate.window!.rootViewController = tabControlleer
        }
    
    }

}
