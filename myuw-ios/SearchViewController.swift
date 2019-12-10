//
//  SearchViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/8/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class SearchViewController: CustomWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load the webview
        webView.load("\(appHost)/search/")
        
        // prefer small titles
        self.navigationItem.largeTitleDisplayMode = .never
        
        // search controler and bar setup
        let mySearchController = UISearchController()
        self.navigationItem.searchController = mySearchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        mySearchController.searchBar.placeholder = "Search"
        mySearchController.searchBar.tintColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // override navigation title
        self.navigationItem.title = "Search"
    }
        
    // override the original webview didFinish and replace with custom search.css
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        // on webview finish... set scroll behavior back to automatic
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        showActivityIndicator(show: false)
  
        // dynamically inject css file into webview
        /*
        guard let path = Bundle.main.path(forResource: "search", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
        */
        
    }
    
}
