//
//  AccountsViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 10/29/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class AccountsViewController: CustomWebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview
        webView.load("\(appHost)/accounts/")
        
        // override navigation title
        self.navigationItem.title = "Accounts"
    }
    
}
