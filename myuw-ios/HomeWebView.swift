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
        
        let userButton = UIButton(type: .system)
        userButton.setImage(UIImage(named: "ic_person"), for: .normal)
        userButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        userButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        userButton.setTitle(User.userNetID, for: .normal)
        userButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        userButton.sizeToFit()
        userButton.addTarget(self, action: #selector(showProfile), for: .touchUpInside)

        // Set a minimum width
        let minWidth: CGFloat = 100
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: max(userButton.frame.width, minWidth), height: userButton.frame.height))
        userButton.frame = containerView.bounds
        containerView.addSubview(userButton)
       
        // show search funtionality for ios13 devices only
        if #available(iOS 13.0, *) {
            // define custom search button
            let searchButton = UIButton(type: .system)
            searchButton.setImage(UIImage(named: "ic_search_18"), for: .normal)
            searchButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10);
            searchButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
            searchButton.setTitle("Search", for: .normal)
            searchButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            searchButton.sizeToFit()
            searchButton.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
            
            // add search button in navbar programatically
            let minSearchWidth: CGFloat = 80
            let searchContainerView = UIView(frame: CGRect(x: 0, y: 0, width: max(searchButton.frame.width, minSearchWidth), height: searchButton.frame.height))
            searchButton.frame = searchContainerView.bounds
            searchContainerView.addSubview(searchButton)

            let searchBarButtonItem = UIBarButtonItem(customView: searchContainerView)
            self.navigationItem.rightBarButtonItem = searchBarButtonItem
        }
        
        // add a user and search buttons in navbar programatically
        //let userBarButtonItem = UIBarButtonItem(customView: userButton)
        let userBarButtonItem = UIBarButtonItem(customView: containerView)
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
