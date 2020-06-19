//
//  SearchWebView.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/8/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit
import os

class SearchWebView: WebViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview
        webView.load("\(appHost)/search/")
        
        // override navigation title (match UW page title)
        self.navigationItem.title = "Search the UW"
        
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // add a right button in navbar programatically
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissSearch))
        
        // search controler and bar setup
        let searchController = UISearchController()
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .white
        
        // set color of text inside input
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        
        // set color of the glass icon
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = .lightGray
        
        // search controller delegate
        searchController.searchBar.delegate = self
        
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func dismissSearch(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        
        os_log("Search bar clicked: %@", log: .search, type: .info, searchBar.text!)
        
        // clean up the searchBar text before building the query param string for visitURL
        var returnStr: String = searchBar.text!
        returnStr = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        let visitUrl:String = "https://www.washington.edu/search/?q=\(returnStr)"
    
        webView.load(visitUrl)
        
        // show the user's search term in the text field... while the results are frozen
        // clicking into the results view will clear the text field automatically
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.text = searchBar.text
        }
            
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        // override navigation title by getting the navigated webview's page title
        self.navigationItem.title = webView.title!.replacingOccurrences(of: "MyUW: ", with: "")
        
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // EXAMPLE: dynamically inject css file into webview
        guard let path = Bundle.main.path(forResource: "search", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
    
        
    }
    
}


extension OSLog {
    // log setup
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let search = OSLog(subsystem: subsystem, category: "Search")
}
