//
//  AccountsWebView.swift
//  myuw-ios
//
//  Created by University of Washington on 10/29/19.
//  Copyright © 2019 University of Washington. All rights reserved.
//

import UIKit
import WebKit

class AccountsWebView: WebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview
        webView.load("\(appHost)/accounts/")
        
        // override navigation title
        self.navigationItem.title = "Accounts"
    }
    
}
