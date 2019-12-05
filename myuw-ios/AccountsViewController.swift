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
        
        let url = URL(string: "\(appHost)/accounts/")!
        var customRequest = URLRequest(url: url)
        customRequest.setValue("True", forHTTPHeaderField: "Myuw-Hybrid")
        webView.load(customRequest)
        
        // override navigation title
        self.navigationItem.title = "Accounts"
    }
    
}
