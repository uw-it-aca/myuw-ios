//
//  SearchViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/8/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import Foundation
import WebKit

class SearchViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!

    override func viewDidLoad() {
        
        //addNavigationBar()
        
        let url = URL(string: "https://www.washington.edu/search/?q=tuition")!
        webView.load(URLRequest(url: url))
        
        // override navigation title
        self.navigationItem.title = "Search"
        
        // prefer small titles
        self.navigationItem.largeTitleDisplayMode = .never
        
        // add a right button in navbar programatically
        let testUIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissProfile))
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem
        
        // search controler and bar setup
        let mySearchController = UISearchController()
        self.navigationItem.searchController = mySearchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        mySearchController.searchBar.placeholder = "Search"
        mySearchController.searchBar.tintColor = .white
                
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        // dynamically inject css file into webview
        guard let path = Bundle.main.path(forResource: "search", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
        
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
        
    @objc private func dismissProfile(){
        self.dismiss(animated: true, completion: nil)
    }

    
    
}

extension WKWebView {
    
    func loadHTML(fromString: String, colorHEX: String = "#757575", fontFamily: String = "Gotham-Book", fontSize: String = "14") {
        let htmlString = """
        <link rel="stylesheet" type="text/css" href="myCSSFile.css">
        <span style="font-family: '\(fontFamily)'; font-weight: normal; font-size: \(fontSize); color: \(colorHEX)">\(fromString)</span>
        """
        self.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
}
