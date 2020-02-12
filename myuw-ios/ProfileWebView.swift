//
//  ProfileWebView.swift
//  myuw-test
//
//  Created by Charlon Palacay on 10/21/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
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
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)

        let signOutButtonItem = UIBarButtonItem(customView: signOutButton)
        
        self.navigationItem.rightBarButtonItem = signOutButtonItem
        
    }
    
    @objc func signOut() {
        
        let appAuthController = AppAuthController()
        
        os_log("Singing user out", log: .auth, type: .info)
        
        // clear authstate to signout user
        appAuthController.setAuthState(nil)
        // clear state storage
        UserDefaults.standard.removeObject(forKey: kAppAuthExampleAuthStateKey)
        
        let navController = UINavigationController(rootViewController: appAuthController)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set appAuth controller as rootViewController
        appDelegate.window!.rootViewController = navController
        
    
    }

}