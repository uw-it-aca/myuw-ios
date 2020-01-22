//
//  HomeViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class HomeViewController: CustomWebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // load the webview
        webView.load("\(appHost)/")
                
        // override navigation title
        self.navigationItem.title = "MyUW"
        
        // define custom user button
        let userButton = UIButton(type: .system)
        userButton.setImage(UIImage(named: "ic_user_18"), for: .normal)
        userButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        userButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5);
        userButton.setTitle(userNetID, for: .normal)
        userButton.sizeToFit()
        userButton.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        
        // define custom search button
        let searchButton = UIButton(type: .system)
        searchButton.setImage(UIImage(named: "ic_search_18"), for: .normal)
        searchButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0);
        searchButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0);
        searchButton.setTitle("Search", for: .normal)
        searchButton.sizeToFit()
        searchButton.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
        
        // define custom email button
        let signOutButton = UIButton(type: .system)
        signOutButton.setImage(UIImage(named: "ic_signout_18"), for: .normal)
        signOutButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.sizeToFit()
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
                        
        // add a user button in navbar programatically
        //let userBarButtonItem = UIBarButtonItem(title: userNetID, style: .plain,  target: self, action: #selector(showProfile))
        let userBarButtonItem = UIBarButtonItem(customView: userButton)
        
        //let emailBarButtonItem = UIBarButtonItem(title: "Email", style: .plain, target: self, action: #selector(showProfile))
        let signOutBarButtonItem = UIBarButtonItem(customView: signOutButton)
        
        //let searchBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(showSearch))
        let searchBarButtonItem = UIBarButtonItem(customView: searchButton)
        
        self.navigationItem.leftBarButtonItem = userBarButtonItem
            
        self.navigationItem.rightBarButtonItems = [signOutBarButtonItem, searchBarButtonItem]
        
    }
    
    @objc func showProfile() {
        
        // instantiate instance of ProfileViewController
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
                        
        // set style of how view controller is to be presented
        if #available(iOS 13.0, *) {
            profileViewController.modalPresentationStyle = .automatic
        } else {
            // fallback on earlier versions
            profileViewController.modalPresentationStyle = .formSheet
        }
                
        // present the profile view controller
        present(profileViewController, animated: true, completion: nil)

    }
    
    @objc func showSearch() {
        // instantiate instance of SearchViewController
        let searchViewController = SearchViewController()
        // push view controller onto the stack
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @objc func signOut() {
        
        let mainController = AppAuthTest()
        
        print("signing user out")
        
        // clear authstate to signout user
        mainController.setAuthState(nil)
        // clear state storage
        UserDefaults.standard.removeObject(forKey: kAppAuthExampleAuthStateKey)
        
        let navController = UINavigationController(rootViewController: mainController)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set appAuth controller as rootViewController
        appDelegate.window!.rootViewController = navController
        
    
    }
    
}
