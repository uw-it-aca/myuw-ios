//
//  HuskyExpViewController.swift
//  myuw-ios
//
//  Created by Charlon Palacay on 11/13/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import UIKit
import WebKit

class HuskyExpViewController: WebViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the webview
        webView.load("\(appHost)/husky_experience/")
        
        // override navigation title
        self.navigationItem.title = "Husky Experience Toolkit"
    }
    
}
