//
//  SearchViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/8/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class SearchViewController: CustomWebViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview
        webView.load("\(appHost)/search/")
        
        // override navigation title
        self.navigationItem.title = "Search"
        
        // prefer small titles
        //self.navigationItem.largeTitleDisplayMode = .never
        
        // must turn off translucense to prevent auto scrolling with large titles
        self.navigationController?.navigationBar.isTranslucent = false
        
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
        
    }
    
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        print("serach bar clicked: ", searchBar.text! )
        let visitUrl:String = "https://www.washington.edu/search/?q=\(searchBar.text ?? "")"
        
        webView.load(visitUrl)
        
        searchBar.searchTextField.text = searchBar.text
                
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        // override navigation title by getting the navigated webview's page title
        self.navigationItem.title = webView.title!.replacingOccurrences(of: "MyUW: ", with: "")
        
        // dynamically inject css file into webview

        guard let path = Bundle.main.path(forResource: "search", ofType: "css") else { return }
        let css = try! String(contentsOfFile: path).replacingOccurrences(of: "\\n", with: "", options: .regularExpression)
        let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(js)
    
        
    }
    
}

