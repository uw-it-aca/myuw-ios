//
//  ProfileViewController.swift
//  myuw-test
//
//  Created by Charlon Palacay on 10/21/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class ProfileViewController: CustomWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://my-test.s.uw.edu/profile/")!
        webView.load(URLRequest(url: url))
        
        // override navigation title
        self.navigationItem.title = "Profile"
        
        // prefer small titles
        self.navigationItem.largeTitleDisplayMode = .never
        
        // add a right button in navbar programatically
        let testUIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissProfile))
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem
                
    }
    
    @objc private func dismissProfile(){
        self.dismiss(animated: true, completion: nil)
    }

}
