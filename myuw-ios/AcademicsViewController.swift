//
//  AcademicsViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class AcademicsViewController: CustomWebViewController {
    
    var deepAction:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load the webview
        webView.load("\(appHost)/academics/")
        
        // override navigation title
        self.navigationItem.title = "Academics"
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        didChange = true
        
        let url = webView.url?.absoluteURL
        print("navi webview url: ", url as Any)
        
        // handle deep actions
        
        if (deepAction.count > 0) {
            print(deepAction)
            //webView.evaluateJavaScript(deepAction)
            deepAction = ""
        }
    
    }
    
}
