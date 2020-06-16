//
//  VisitController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/5/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class VisitController: WebViewController {
    
    var visitUrl:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview from the visitUrl
        webView.load(visitUrl)
        
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        // override navigation title by getting the navigated webview's page title
        self.navigationItem.title = webView.title!.replacingOccurrences(of: "MyUW: ", with: "")
        
        // set webview scrollview to automatic
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
                
    }
        
}

