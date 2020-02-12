//
//  NoticesWebView.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/13/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class NoticesWebView: WebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // load the webview
        webView.load("\(appHost)/notices/")
        
        // override navigation title
        self.navigationItem.title = "Notices"
    }
    
}
