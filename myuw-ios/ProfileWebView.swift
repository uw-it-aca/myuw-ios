//
//  ProfileWebView.swift
//  myuw-test
//
//  Created by University of Washington on 10/21/19.
//  Copyright © 2019 University of Washington. All rights reserved.
//

import UIKit
import WebKit
import os

class ProfileWebView: WebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load the webview
        webView.load("\(appHost)/profile/")
        
        // override navigation title
        self.navigationItem.title = "Profile"
        
        // define custom email button
        let signOutButton = UIButton(type: .system)
        signOutButton.setImage(UIImage(named: "ic_signout_18"), for: .normal)
        signOutButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0);
        signOutButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0);
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.titleLabel?.font = .systemFont(ofSize: 17)
        signOutButton.sizeToFit()
        signOutButton.addTarget(self, action: #selector(WebViewController.signOut), for: .touchUpInside)

        let signOutButtonItem = UIBarButtonItem(customView: signOutButton)
        
        //self.navigationItem.leftBarButtonItem = signOutButtonItem
        self.navigationItem.rightBarButtonItem = signOutButtonItem
        
    }

}
