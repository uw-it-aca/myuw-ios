//
//  HomeViewController.swift
//  myuw-ios
//
//  Created by University of Washington on 10/29/19.
//  Copyright © 2019 University of Washington. All rights reserved.
//

import UIKit
import WebKit

class HomeWebView: WebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load the webview
        webView.load("\(appHost)/")
                
        // override navigation title
        self.navigationItem.title = "MyUW"
        
        // define custom user button
        let userButton = UIButton(type: .system)
        userButton.setImage(UIImage(named: "ic_person"), for: .normal)
        userButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        userButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5);
        userButton.setTitle(User.userNetID, for: .normal)
        userButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        userButton.sizeToFit()
        userButton.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
       
        // show search funtionality for ios13 devices only
        if #available(iOS 13.0, *) {
            // define custom search button
            let searchButton = UIButton(type: .system)
            searchButton.setImage(UIImage(named: "ic_search_18"), for: .normal)
            searchButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0);
            searchButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0);
            searchButton.setTitle("Search", for: .normal)
            searchButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            searchButton.sizeToFit()
            searchButton.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
            
            // add search button in navbar programatically
            let searchBarButtonItem = UIBarButtonItem(customView: searchButton)
            self.navigationItem.rightBarButtonItem = searchBarButtonItem
        }
        
        // add a user and search buttons in navbar programatically
        let userBarButtonItem = UIBarButtonItem(customView: userButton)
        self.navigationItem.leftBarButtonItem = userBarButtonItem
    
    }
    
    @objc func showProfile() {
                
        // programatically click on a tab

        if let tabbarController = UIApplication.shared.delegate?.window!?.rootViewController as? ApplicationController {
            //tabbarController.selectedIndex = 3
            tabbarController.selectedViewController = tabbarController.tabProfile
        }
    }
    
    @objc func showSearch() {
        
        // instantiate instance of SearchViewController
        let searchWebView = UINavigationController(rootViewController: SearchWebView())
        
        // set style of how view controller is to be presented
        if #available(iOS 13.0, *) {
            searchWebView.modalPresentationStyle = .automatic
        } else {
            // fallback on earlier versions
            searchWebView.modalPresentationStyle = .formSheet
        }
                
        // present the profile view controller
        present(searchWebView, animated: true, completion: nil)
    }
    
}
