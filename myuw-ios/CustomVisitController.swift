//
//  CustomVisitController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/5/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class CustomVisitController: CustomWebViewController {
    
    var visitUrl:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview from the visitUrl
        webView.load(visitUrl)
        
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // on webview finish... set scroll behavior back to automatic
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        // override navigation title by getting the navigated webview's page title
        self.navigationItem.title = webView.title!.replacingOccurrences(of: "MyUW: ", with: "")
        
        // dynamically inject css file into webview
        /*
        guard let path = Bundle.main.path(forResource: "myuw", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
        */
        
    }
        
}

