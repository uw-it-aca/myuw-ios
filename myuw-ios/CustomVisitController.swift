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

        let url = URL(string: visitUrl)!
        var customRequest = URLRequest(url: url)
        customRequest.setValue("True", forHTTPHeaderField: "Myuw-Hybrid")
        webView.load(customRequest)

    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        showActivityIndicator(show: false)
        
        // override navigation title by getting the navigated webview's page title
        self.navigationItem.title = webView.title!.replacingOccurrences(of: "MyUW: ", with: "")
        
        // mocking this for now
        // self.navigationItem.title = "Page Title"
        // self.navigationController?.navigationBar.backItem?.title = "Prev"
        
        // dynamically inject css file into webview
        /*
        guard let path = Bundle.main.path(forResource: "myuw", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
        */
        
    }
        
}

