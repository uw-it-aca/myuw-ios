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
        
        // override navigation title
        self.navigationItem.title = "Search"
        
        // prefer small titles
        self.navigationItem.largeTitleDisplayMode = .never
        
        // MARK: - Search controller and bar setup
        let mySearchController = UISearchController()
        self.navigationItem.searchController = mySearchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        mySearchController.searchBar.placeholder = "Search"
        mySearchController.searchBar.tintColor = .white
        
    }
        
}
