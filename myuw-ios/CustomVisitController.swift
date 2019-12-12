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
        
        // load the webview
        webView.load(visitUrl)
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // MARK: - Pull to Refresh setup (duplicated on this controller since it is an override
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: UIControl.Event.valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.bounces = true
        webView.scrollView.refreshControl = refreshControl
        refreshControl.backgroundColor = .gray
        
        view.addSubview(webView)
        
        // override navigation title by getting the navigated webview's page title - doing some text cleanup!
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

